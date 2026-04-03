SELECT
  COUNT(*) AS delivered_orders_with_dates,
  ROUND(AVG(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)), 2) AS avg_delivery_days,
  ROUND(
    100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS late_delivery_rate_pct,
  ROUND(
    SUM(
      CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date)
        ELSE 0
      END
    ) / NULLIF(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END), 0),
    2
  ) AS avg_days_late_when_late
FROM orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
