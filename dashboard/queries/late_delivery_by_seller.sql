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
  COUNT(DISTINCT order_id) AS delivered_orders,
  ROUND(
    100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(DISTINCT order_id),
    2
  ) AS late_delivery_rate_pct
FROM seller_orders
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) >= 50
ORDER BY late_delivery_rate_pct DESC, delivered_orders DESC
LIMIT 15;
