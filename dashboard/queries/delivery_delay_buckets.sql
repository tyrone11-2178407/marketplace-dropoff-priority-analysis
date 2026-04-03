SELECT
  CASE
    WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'on_time'
    WHEN julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date) <= 3 THEN '1_to_3_days_late'
    WHEN julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date) <= 7 THEN '4_to_7_days_late'
    ELSE '8_plus_days_late'
  END AS delay_bucket,
  COUNT(*) AS delivered_orders,
  ROUND(AVG(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)), 2) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY delay_bucket
ORDER BY delivered_orders DESC;
