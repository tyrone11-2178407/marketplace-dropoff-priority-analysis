SELECT 'purchased' AS funnel_stage, 1 AS stage_order, COUNT(*) AS orders FROM orders
UNION ALL
SELECT 'approved', 2, COUNT(*) FROM orders WHERE order_approved_at IS NOT NULL
UNION ALL
SELECT 'shipped', 3, COUNT(*) FROM orders WHERE order_delivered_carrier_date IS NOT NULL
UNION ALL
SELECT 'delivered', 4, COUNT(*) FROM orders WHERE order_delivered_customer_date IS NOT NULL
UNION ALL
SELECT 'reviewed', 5, COUNT(DISTINCT r.order_id)
FROM reviews r
JOIN orders o ON r.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
ORDER BY stage_order;
