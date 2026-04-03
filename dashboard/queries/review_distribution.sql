SELECT
  review_score,
  COUNT(*) AS review_count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS share_of_reviews_pct
FROM reviews
GROUP BY review_score
ORDER BY review_score;
