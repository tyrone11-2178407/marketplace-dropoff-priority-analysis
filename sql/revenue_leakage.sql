-- Revenue leakage summary by issue type.
WITH total_value AS (
  SELECT ROUND(SUM(price + freight_value), 2) AS total_order_value
  FROM order_items
),
canceled AS (
  SELECT ROUND(SUM(oi.price + oi.freight_value), 2) AS leaked_value
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'canceled'
),
delayed AS (
  SELECT ROUND(SUM(oi.price + oi.freight_value), 2) AS leaked_value
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
    AND o.order_delivered_customer_date > o.order_estimated_delivery_date
)
SELECT
  'canceled_orders' AS issue,
  c.leaked_value AS value_at_risk,
  ROUND(100.0 * c.leaked_value / t.total_order_value, 2) AS share_of_total_value_pct
FROM canceled c
CROSS JOIN total_value t
UNION ALL
SELECT
  'late_deliveries',
  d.leaked_value,
  ROUND(100.0 * d.leaked_value / t.total_order_value, 2)
FROM delayed d
CROSS JOIN total_value t;

-- Canceled order value by category.
SELECT
  COALESCE(p.product_category_name, 'unknown') AS product_category,
  COUNT(DISTINCT o.order_id) AS canceled_orders,
  ROUND(SUM(oi.price + oi.freight_value), 2) AS canceled_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'canceled'
GROUP BY COALESCE(p.product_category_name, 'unknown')
ORDER BY canceled_order_value DESC
LIMIT 15;

-- Canceled order value by seller.
SELECT
  oi.seller_id,
  s.seller_state,
  COUNT(DISTINCT o.order_id) AS canceled_orders,
  ROUND(SUM(oi.price + oi.freight_value), 2) AS canceled_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN sellers s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'canceled'
GROUP BY oi.seller_id, s.seller_state
HAVING COUNT(DISTINCT o.order_id) >= 3
ORDER BY canceled_order_value DESC, canceled_orders DESC
LIMIT 15;

-- Canceled order value by seller state.
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
