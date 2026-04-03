SELECT
  p.payment_type,
  COUNT(DISTINCT p.order_id) AS orders,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(r.review_score), 2) AS low_review_rate_pct
FROM payments p
LEFT JOIN reviews r ON p.order_id = r.order_id
GROUP BY p.payment_type
HAVING COUNT(DISTINCT p.order_id) >= 100
ORDER BY low_review_rate_pct DESC, orders DESC;
