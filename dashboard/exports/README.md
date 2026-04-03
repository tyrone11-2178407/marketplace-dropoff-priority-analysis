# Dashboard Exports

This folder holds the CSV files you upload into Looker Studio.

Generate them from the SQL files in `dashboard/queries/` with commands like:

```bash
sqlite3 -header -csv data/olist.db < dashboard/queries/executive_kpis.sql > dashboard/exports/executive_kpis.csv
```

Recommended CSV files:
- `executive_kpis.csv`
- `funnel_stage_counts.csv`
- `order_status_distribution.csv`
- `order_value_by_status.csv`
- `revenue_leakage_summary.csv`
- `canceled_value_by_category.csv`
- `canceled_value_by_seller_state.csv`
- `delivery_overview.csv`
- `delivery_delay_buckets.csv`
- `late_delivery_by_category.csv`
- `late_delivery_by_seller.csv`
- `review_distribution.csv`
- `review_by_delay_bucket.csv`
- `low_review_by_category.csv`
- `low_review_by_payment_type.csv`
- `priority_table.csv`
