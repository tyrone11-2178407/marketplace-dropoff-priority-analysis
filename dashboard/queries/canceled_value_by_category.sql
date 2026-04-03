SELECT
  COALESCE(p.product_category_name, 'unknown') AS product_category,
  COUNT(DISTINCT o.order_id) AS canceled_orders,
  ROUND(SUM(oi.price + oi.freight_value), 2) AS canceled_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'canceled'
GROUP BY COALESCE(p.product_category_name, 'unknown')
ORDER BY canceled_order_value DESC
LIMIT 15;
