SELECT
  s.seller_state,
  COUNT(DISTINCT o.order_id) AS canceled_orders,
  ROUND(SUM(oi.price + oi.freight_value), 2) AS canceled_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'canceled'
GROUP BY s.seller_state
ORDER BY canceled_order_value DESC;
