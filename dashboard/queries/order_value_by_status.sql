SELECT
  o.order_status,
  COUNT(DISTINCT o.order_id) AS orders,
  ROUND(SUM(oi.price + oi.freight_value), 2) AS total_order_value,
  ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY total_order_value DESC;
