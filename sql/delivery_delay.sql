-- Overall delivery performance.
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

-- Delivery buckets for dashboard use.
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

-- Late delivery performance by category.
WITH category_orders AS (
  SELECT DISTINCT
    o.order_id,
    COALESCE(p.product_category_name, 'unknown') AS product_category,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  LEFT JOIN products p ON oi.product_id = p.product_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
  product_category,
  COUNT(DISTINCT order_id) AS delivered_orders,
  ROUND(
    100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(DISTINCT order_id),
    2
  ) AS late_delivery_rate_pct
FROM category_orders
GROUP BY product_category
HAVING COUNT(DISTINCT order_id) >= 200
ORDER BY late_delivery_rate_pct DESC, delivered_orders DESC
LIMIT 15;

-- Late delivery performance by seller.
WITH seller_orders AS (
  SELECT DISTINCT
    o.order_id,
    oi.seller_id,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
  seller_id,
  COUNT(DISTINCT order_id) AS delivered_orders,
  ROUND(
    100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(DISTINCT order_id),
    2
  ) AS late_delivery_rate_pct
FROM seller_orders
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) >= 50
ORDER BY late_delivery_rate_pct DESC, delivered_orders DESC
LIMIT 15;

-- Late delivery performance by customer state.
SELECT
  c.customer_state,
  COUNT(*) AS delivered_orders,
  ROUND(
    100.0 * SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS late_delivery_rate_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 500
ORDER BY late_delivery_rate_pct DESC, delivered_orders DESC;
