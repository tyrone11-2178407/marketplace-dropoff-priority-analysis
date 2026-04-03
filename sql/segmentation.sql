-- Segment risk by product category.
WITH category_orders AS (
  SELECT DISTINCT
    o.order_id,
    COALESCE(p.product_category_name, 'unknown') AS segment,
    o.order_status,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  LEFT JOIN products p ON oi.product_id = p.product_id
)
SELECT
  segment AS product_category,
  COUNT(DISTINCT c.order_id) AS orders,
  ROUND(100.0 * SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) / COUNT(DISTINCT c.order_id), 2) AS cancellation_rate_pct,
  ROUND(
    100.0 * SUM(CASE WHEN order_status = 'delivered' AND order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) /
    NULLIF(SUM(CASE WHEN order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL THEN 1 ELSE 0 END), 0),
    2
  ) AS late_delivery_rate_pct,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score), 2) AS low_review_rate_pct
FROM category_orders c
LEFT JOIN reviews r ON c.order_id = r.order_id
GROUP BY segment
HAVING COUNT(DISTINCT c.order_id) >= 200
ORDER BY low_review_rate_pct DESC, late_delivery_rate_pct DESC
LIMIT 15;

-- Segment risk by seller.
WITH seller_orders AS (
  SELECT DISTINCT
    o.order_id,
    oi.seller_id AS segment,
    o.order_status,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
)
SELECT
  segment AS seller_id,
  COUNT(DISTINCT s.order_id) AS orders,
  ROUND(100.0 * SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) / COUNT(DISTINCT s.order_id), 2) AS cancellation_rate_pct,
  ROUND(
    100.0 * SUM(CASE WHEN order_status = 'delivered' AND order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) /
    NULLIF(SUM(CASE WHEN order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL THEN 1 ELSE 0 END), 0),
    2
  ) AS late_delivery_rate_pct,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score), 2) AS low_review_rate_pct
FROM seller_orders s
LEFT JOIN reviews r ON s.order_id = r.order_id
GROUP BY segment
HAVING COUNT(DISTINCT s.order_id) >= 50
ORDER BY late_delivery_rate_pct DESC, low_review_rate_pct DESC
LIMIT 15;

-- Segment risk by customer state.
SELECT
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS orders,
  ROUND(100.0 * SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) / COUNT(DISTINCT o.order_id), 2) AS cancellation_rate_pct,
  ROUND(
    100.0 * SUM(CASE WHEN o.order_status = 'delivered' AND o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) /
    NULLIF(SUM(CASE WHEN o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL AND o.order_estimated_delivery_date IS NOT NULL THEN 1 ELSE 0 END), 0),
    2
  ) AS late_delivery_rate_pct,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score), 2) AS low_review_rate_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN reviews r ON o.order_id = r.order_id
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 500
ORDER BY low_review_rate_pct DESC, late_delivery_rate_pct DESC;

-- Segment risk by payment type.
SELECT
  p.payment_type,
  COUNT(DISTINCT o.order_id) AS orders,
  ROUND(100.0 * SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) / COUNT(DISTINCT o.order_id), 2) AS cancellation_rate_pct,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score), 2) AS low_review_rate_pct
FROM orders o
JOIN payments p ON o.order_id = p.order_id
LEFT JOIN reviews r ON o.order_id = r.order_id
GROUP BY p.payment_type
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY low_review_rate_pct DESC, orders DESC;

-- New versus repeat customer proxy.
WITH delivered_orders AS (
  SELECT
    o.order_id,
    c.customer_unique_id,
    CASE
      WHEN COUNT(*) OVER (PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) = 1
      THEN 'new_customer_order'
      ELSE 'repeat_customer_order'
    END AS customer_segment,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
)
SELECT
  customer_segment,
  COUNT(DISTINCT d.order_id) AS delivered_orders,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score), 2) AS low_review_rate_pct,
  ROUND(
    100.0 * SUM(CASE WHEN d.order_delivered_customer_date > d.order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(DISTINCT d.order_id),
    2
  ) AS late_delivery_rate_pct
FROM delivered_orders d
LEFT JOIN reviews r ON d.order_id = r.order_id
GROUP BY customer_segment
ORDER BY delivered_orders DESC;
