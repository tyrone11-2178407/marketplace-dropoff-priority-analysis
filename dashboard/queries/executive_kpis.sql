WITH order_summary AS (
  SELECT
    COUNT(*) AS total_orders,
    ROUND(100.0 * SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) / COUNT(*), 2) AS completion_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancellation_rate_pct
  FROM orders
),
delivery_summary AS (
  SELECT
    ROUND(
      100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*),
      2
    ) AS late_delivery_rate_pct
  FROM orders
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL
),
review_summary AS (
  SELECT
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(100.0 * SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS low_review_rate_pct
  FROM reviews
),
revenue_summary AS (
  SELECT
    ROUND(SUM(CASE WHEN o.order_status = 'canceled' THEN oi.price + oi.freight_value ELSE 0 END), 2) AS canceled_order_value,
    ROUND(SUM(CASE
      WHEN o.order_status = 'delivered'
       AND o.order_delivered_customer_date IS NOT NULL
       AND o.order_estimated_delivery_date IS NOT NULL
       AND o.order_delivered_customer_date > o.order_estimated_delivery_date
      THEN oi.price + oi.freight_value
      ELSE 0
    END), 2) AS delayed_order_value
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
)
SELECT
  o.total_orders,
  o.completion_rate_pct,
  o.cancellation_rate_pct,
  d.late_delivery_rate_pct,
  r.avg_review_score,
  r.low_review_rate_pct,
  rev.canceled_order_value,
  rev.delayed_order_value
FROM order_summary o
CROSS JOIN delivery_summary d
CROSS JOIN review_summary r
CROSS JOIN revenue_summary rev;
