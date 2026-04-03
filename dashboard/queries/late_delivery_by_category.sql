WITH category_orders AS (
  SELECT DISTINCT
    o.order_id,
    COALESCE(p.product_category_name, 'unknown') AS product_category,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  LEFT JOIN products p ON oi.product_id = p.product_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
  product_category,
  COUNT(DISTINCT order_id) AS delivered_orders,
  ROUND(
    100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(DISTINCT order_id),
    2
  ) AS late_delivery_rate_pct
FROM category_orders
GROUP BY product_category
HAVING COUNT(DISTINCT order_id) >= 200
ORDER BY late_delivery_rate_pct DESC, delivered_orders DESC
LIMIT 15;
