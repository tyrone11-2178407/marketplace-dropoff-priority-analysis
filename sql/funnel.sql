-- Order status distribution and share of total orders.
SELECT
  order_status,
  COUNT(*) AS orders,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS share_of_orders_pct
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- Order lifecycle funnel using timestamps and review coverage.
SELECT 'purchased' AS funnel_stage, COUNT(*) AS orders FROM orders
UNION ALL
SELECT 'approved', COUNT(*) FROM orders WHERE order_approved_at IS NOT NULL
UNION ALL
SELECT 'shipped', COUNT(*) FROM orders WHERE order_delivered_carrier_date IS NOT NULL
UNION ALL
SELECT 'delivered', COUNT(*) FROM orders WHERE order_delivered_customer_date IS NOT NULL
UNION ALL
SELECT 'reviewed', COUNT(DISTINCT r.order_id)
FROM reviews r
JOIN orders o ON r.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL;

-- Delivered and canceled counts with core rates.
SELECT
  COUNT(*) AS total_orders,
  SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders,
  SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) AS canceled_orders,
  ROUND(100.0 * SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) / COUNT(*), 2) AS completion_rate_pct,
  ROUND(100.0 * SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancellation_rate_pct
FROM orders;

-- Order value tied to each status.
SELECT
  o.order_status,
  COUNT(DISTINCT o.order_id) AS orders,
  ROUND(SUM(oi.price + oi.freight_value), 2) AS total_order_value,
  ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY total_order_value DESC;
