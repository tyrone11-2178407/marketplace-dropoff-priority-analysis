SELECT COUNT(*) AS total_orders
FROM orders;

SELECT order_status, COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;