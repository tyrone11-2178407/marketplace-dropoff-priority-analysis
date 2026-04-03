WITH total_value AS (
  SELECT ROUND(SUM(price + freight_value), 2) AS total_order_value
  FROM order_items
),
canceled AS (
  SELECT ROUND(SUM(oi.price + oi.freight_value), 2) AS value_at_risk
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'canceled'
),
delayed AS (
  SELECT ROUND(SUM(oi.price + oi.freight_value), 2) AS value_at_risk
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
    AND o.order_delivered_customer_date > o.order_estimated_delivery_date
)
SELECT
  'canceled_orders' AS issue,
  c.value_at_risk,
  ROUND(100.0 * c.value_at_risk / t.total_order_value, 2) AS share_of_total_value_pct
FROM canceled c
CROSS JOIN total_value t
UNION ALL
SELECT
  'late_deliveries',
  d.value_at_risk,
  ROUND(100.0 * d.value_at_risk / t.total_order_value, 2)
FROM delayed d
CROSS JOIN total_value t;
