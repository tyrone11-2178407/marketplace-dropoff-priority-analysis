-- Review distribution.
SELECT
  review_score,
  COUNT(*) AS review_count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS share_of_reviews_pct
FROM reviews
GROUP BY review_score
ORDER BY review_score;

-- Overall customer pain metrics.
SELECT
  ROUND(AVG(review_score), 2) AS avg_review_score,
  ROUND(100.0 * SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS low_review_rate_pct
FROM reviews;

-- Review score by delivery delay bucket.
WITH delivered_orders AS (
  SELECT
    order_id,
    CASE
      WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'on_time'
      WHEN julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date) <= 3 THEN '1_to_3_days_late'
      WHEN julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date) <= 7 THEN '4_to_7_days_late'
      ELSE '8_plus_days_late'
    END AS delay_bucket
  FROM orders
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL
)
SELECT
  d.delay_bucket,
  COUNT(DISTINCT d.order_id) AS orders,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score), 2) AS low_review_rate_pct
FROM delivered_orders d
LEFT JOIN reviews r ON d.order_id = r.order_id
GROUP BY d.delay_bucket
ORDER BY orders DESC;

-- Customer pain by category.
WITH category_orders AS (
  SELECT DISTINCT
    o.order_id,
    COALESCE(p.product_category_name, 'unknown') AS product_category
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  LEFT JOIN products p ON oi.product_id = p.product_id
)
SELECT
  c.product_category,
  COUNT(DISTINCT c.order_id) AS orders,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score), 2) AS low_review_rate_pct
FROM category_orders c
LEFT JOIN reviews r ON c.order_id = r.order_id
GROUP BY c.product_category
HAVING COUNT(DISTINCT c.order_id) >= 200
ORDER BY low_review_rate_pct DESC, orders DESC
LIMIT 15;

-- Customer pain by seller.
WITH seller_orders AS (
  SELECT DISTINCT
    o.order_id,
    oi.seller_id
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
)
SELECT
  s.seller_id,
  COUNT(DISTINCT s.order_id) AS orders,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score), 2) AS low_review_rate_pct
FROM seller_orders s
LEFT JOIN reviews r ON s.order_id = r.order_id
GROUP BY s.seller_id
HAVING COUNT(DISTINCT s.order_id) >= 50
ORDER BY low_review_rate_pct DESC, orders DESC
LIMIT 15;

-- Customer pain by payment type.
SELECT
  p.payment_type,
  COUNT(DISTINCT p.order_id) AS orders,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score), 2) AS low_review_rate_pct
FROM payments p
LEFT JOIN reviews r ON p.order_id = r.order_id
GROUP BY p.payment_type
HAVING COUNT(DISTINCT p.order_id) >= 100
ORDER BY low_review_rate_pct DESC, orders DESC;
