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
