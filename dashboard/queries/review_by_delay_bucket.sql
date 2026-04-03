WITH delivered_orders AS (
  SELECT
    order_id,
    CASE
      WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'on_time'
      WHEN julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date) <= 3 THEN '1_to_3_days_late'
      WHEN julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date) <= 7 THEN '4_to_7_days_late'
      ELSE '8_plus_days_late'
    END AS delay_bucket
  FROM orders
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL
)
SELECT
  d.delay_bucket,
  COUNT(DISTINCT d.order_id) AS orders,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score), 2) AS low_review_rate_pct
FROM delivered_orders d
LEFT JOIN reviews r ON d.order_id = r.order_id
GROUP BY d.delay_bucket
ORDER BY orders DESC;
