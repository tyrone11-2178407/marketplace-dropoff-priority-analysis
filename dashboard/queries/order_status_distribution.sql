SELECT
  order_status,
  COUNT(*) AS orders,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS share_of_orders_pct
FROM orders
GROUP BY order_status
ORDER BY orders DESC;
