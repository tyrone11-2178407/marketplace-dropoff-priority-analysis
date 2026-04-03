-- Row counts for the core analysis tables.
SELECT 'orders' AS table_name, COUNT(*) AS total_rows FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers;

-- Order status distribution.
SELECT order_status, COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Distinct order coverage across the main fact-like tables.
SELECT 'orders' AS source_table, COUNT(DISTINCT order_id) AS distinct_orders FROM orders
UNION ALL
SELECT 'order_items', COUNT(DISTINCT order_id) FROM order_items
UNION ALL
SELECT 'payments', COUNT(DISTINCT order_id) FROM payments
UNION ALL
SELECT 'reviews', COUNT(DISTINCT order_id) FROM reviews;

-- Null checks for key IDs and dates used in analysis.
SELECT
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase_ts,
  SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS null_estimated_delivery_ts,
  SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivered_customer_ts
FROM orders;

SELECT
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
  SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id
FROM order_items;

SELECT
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type
FROM payments;

SELECT
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS null_review_score
FROM reviews;

-- Duplicate checks for expected identifiers.
SELECT 'orders.order_id' AS check_name, COUNT(*) AS duplicate_keys
FROM (
  SELECT order_id
  FROM orders
  GROUP BY order_id
  HAVING COUNT(*) > 1
);

SELECT 'customers.customer_id' AS check_name, COUNT(*) AS duplicate_keys
FROM (
  SELECT customer_id
  FROM customers
  GROUP BY customer_id
  HAVING COUNT(*) > 1
);

SELECT 'order_items.order_id + order_item_id' AS check_name, COUNT(*) AS duplicate_keys
FROM (
  SELECT order_id, order_item_id
  FROM order_items
  GROUP BY order_id, order_item_id
  HAVING COUNT(*) > 1
);

SELECT 'reviews.review_id' AS check_name, COUNT(*) AS duplicate_keys
FROM (
  SELECT review_id
  FROM reviews
  GROUP BY review_id
  HAVING COUNT(*) > 1
);

-- Delivery readiness checks for post-purchase analysis.
SELECT
  COUNT(*) AS delivered_orders_with_dates,
  ROUND(AVG(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)), 2) AS avg_delivery_days,
  ROUND(
    100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS late_delivery_rate_pct
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL;
