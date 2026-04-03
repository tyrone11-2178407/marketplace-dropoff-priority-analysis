WITH late_delivery AS (
  SELECT
    metrics.late_rate_pct,
    value_at_risk.delayed_order_value,
    review_pain.late_avg_review,
    review_pain.on_time_avg_review
  FROM (
    SELECT
      ROUND(
        100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*),
        2
      ) AS late_rate_pct
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
  ) metrics
  CROSS JOIN (
    SELECT ROUND(SUM(oi.price + oi.freight_value), 2) AS delayed_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
      AND o.order_delivered_customer_date > o.order_estimated_delivery_date
  ) value_at_risk
  CROSS JOIN (
    SELECT
      ROUND(AVG(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN r.review_score END), 2) AS late_avg_review,
      ROUND(AVG(CASE WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN r.review_score END), 2) AS on_time_avg_review
    FROM orders o
    LEFT JOIN reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
  ) review_pain
),
cancellations AS (
  SELECT
    ROUND(100.0 * SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(SUM(CASE WHEN order_status = 'canceled' THEN item_value ELSE 0 END), 2) AS canceled_order_value
  FROM (
    SELECT
      o.order_id,
      o.order_status,
      SUM(oi.price + oi.freight_value) AS item_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.order_status
  )
),
seller_friction AS (
  SELECT
    COUNT(*) AS high_friction_sellers,
    ROUND(AVG(late_rate_pct), 2) AS avg_high_friction_seller_late_rate
  FROM (
    WITH seller_orders AS (
      SELECT DISTINCT
        o.order_id,
        oi.seller_id,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date
      FROM orders o
      JOIN order_items oi ON o.order_id = oi.order_id
      WHERE o.order_status = 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL
        AND o.order_estimated_delivery_date IS NOT NULL
    )
    SELECT
      seller_id,
      100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(DISTINCT order_id) AS late_rate_pct
    FROM seller_orders
    GROUP BY seller_id
    HAVING COUNT(DISTINCT order_id) >= 50
       AND 100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(DISTINCT order_id) >= 20
  )
),
category_friction AS (
  SELECT
    COUNT(*) AS high_pain_categories,
    ROUND(AVG(low_review_rate_pct), 2) AS avg_high_pain_category_low_review_rate
  FROM (
    WITH category_orders AS (
      SELECT DISTINCT
        o.order_id,
        COALESCE(pr.product_category_name, 'unknown') AS category
      FROM orders o
      JOIN order_items oi ON o.order_id = oi.order_id
      LEFT JOIN products pr ON oi.product_id = pr.product_id
    )
    SELECT
      c.category,
      100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score) AS low_review_rate_pct
    FROM category_orders c
    LEFT JOIN reviews r ON c.order_id = r.order_id
    GROUP BY c.category
    HAVING COUNT(DISTINCT c.order_id) >= 200
       AND 100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score) >= 20
  )
),
payment_friction AS (
  SELECT
    payment_type,
    orders,
    avg_review_score,
    low_review_rate_pct
  FROM (
    SELECT
      p.payment_type,
      COUNT(DISTINCT p.order_id) AS orders,
      ROUND(AVG(r.review_score), 2) AS avg_review_score,
      ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score), 2) AS low_review_rate_pct
    FROM payments p
    LEFT JOIN reviews r ON p.order_id = r.order_id
    GROUP BY p.payment_type
    HAVING COUNT(DISTINCT p.order_id) >= 100
    ORDER BY low_review_rate_pct DESC, orders DESC
  )
  LIMIT 1
),
issue_scores AS (
  SELECT
    'Late delivery' AS issue,
    'Delayed fulfillment is depressing customer satisfaction and putting meaningful delivered GMV at risk.' AS business_problem,
    CASE
      WHEN delayed_order_value >= 1000000 THEN 5
      WHEN delayed_order_value >= 500000 THEN 4
      ELSE 3
    END AS impact_score,
    CASE
      WHEN late_rate_pct >= 8 THEN 4
      WHEN late_rate_pct >= 4 THEN 3
      ELSE 2
    END AS frequency_score,
    'Medium' AS effort,
    'Logistics / Ops' AS owner,
    'late_delivery_rate_pct' AS metric_to_monitor,
    'Prioritize the worst seller and category lanes, tighten delivery SLAs, and monitor late-delivery exceptions weekly.' AS recommended_action
  FROM late_delivery

  UNION ALL

  SELECT
    'Cancellations',
    'Canceled orders are creating direct revenue leakage and are concentrated in a handful of categories and seller states.',
    CASE
      WHEN canceled_order_value >= 100000 THEN 4
      WHEN canceled_order_value >= 50000 THEN 3
      ELSE 2
    END,
    CASE
      WHEN cancellation_rate_pct >= 2 THEN 4
      WHEN cancellation_rate_pct >= 1 THEN 3
      ELSE 2
    END,
    'Medium',
    'Seller Operations',
    'cancellation_rate_pct',
    'Review the highest-value canceled categories and sellers first, then add early-warning checks for inventory and fulfillment breakdowns.'
  FROM cancellations

  UNION ALL

  SELECT
    'Seller friction',
    'A small group of sellers drives disproportionately high late-delivery risk, creating concentrated operational drag.',
    CASE
      WHEN high_friction_sellers >= 20 THEN 4
      WHEN high_friction_sellers >= 10 THEN 3
      ELSE 2
    END,
    CASE
      WHEN avg_high_friction_seller_late_rate >= 20 THEN 4
      WHEN avg_high_friction_seller_late_rate >= 15 THEN 3
      ELSE 2
    END,
    'Medium',
    'Seller Operations',
    'seller_late_delivery_rate_pct',
    'Set seller scorecards, trigger escalation for repeat offenders, and route operational coaching to the worst-performing sellers.'
  FROM seller_friction

  UNION ALL

  SELECT
    'Category friction',
    'A few categories show structurally poor customer experience, suggesting packaging, fulfillment, or expectation-setting issues.',
    CASE
      WHEN avg_high_pain_category_low_review_rate >= 22 THEN 4
      WHEN avg_high_pain_category_low_review_rate >= 18 THEN 3
      ELSE 2
    END,
    CASE
      WHEN high_pain_categories >= 5 THEN 4
      WHEN high_pain_categories >= 3 THEN 3
      ELSE 2
    END,
    'Medium',
    'Logistics / Ops',
    'category_low_review_rate_pct',
    'Audit the highest-pain categories for packaging, lead-time expectations, and fulfillment reliability before scaling volume.'
  FROM category_friction

  UNION ALL

  SELECT
    'Payment friction',
    'Some payment paths have slightly worse satisfaction outcomes and may need clearer communication or support handling.',
    CASE
      WHEN low_review_rate_pct >= 16 THEN 2
      ELSE 1
    END,
    CASE
      WHEN orders >= 3000 THEN 2
      ELSE 1
    END,
    'Low',
    'Product / Checkout',
    'payment_type_low_review_rate_pct',
    'Monitor the highest-friction payment type and review checkout messaging, refund expectations, and support playbooks.'
  FROM payment_friction
)
SELECT
  issue,
  business_problem,
  impact_score,
  frequency_score,
  impact_score * frequency_score AS priority_score,
  effort,
  owner,
  metric_to_monitor,
  recommended_action
FROM issue_scores
ORDER BY priority_score DESC, impact_score DESC, frequency_score DESC;
