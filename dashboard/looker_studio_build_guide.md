# Looker Studio Build Guide

This guide shows how to turn the SQL outputs in this repo into a 5-page Looker Studio dashboard using manual CSV uploads.

## Why This Workflow
- Looker Studio works well with uploaded CSV files.
- Your project already has clean SQLite SQL outputs.
- Uploading summary CSVs is less error-prone than trying to wire a live local SQLite connection into a cloud BI tool.

## What You Will Use
- SQLite database: `data/olist.db`
- Export-ready dashboard SQL files: `dashboard/queries/`
- Output CSV folder: `dashboard/exports/`
- Dashboard screenshots folder: `dashboard/screenshots/`

## Folder Map
```text
dashboard/
├── dashboard_plan.md
├── looker_studio_build_guide.md
├── queries/
├── exports/
└── screenshots/
```

## Step 1: Export CSV Files
Run each query file with `sqlite3` and save the output as CSV.

General command pattern:

```bash
sqlite3 -header -csv data/olist.db < dashboard/queries/<query_name>.sql > dashboard/exports/<file_name>.csv
```

Use these exact commands:

```bash
sqlite3 -header -csv data/olist.db < dashboard/queries/executive_kpis.sql > dashboard/exports/executive_kpis.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/funnel_stage_counts.sql > dashboard/exports/funnel_stage_counts.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/order_status_distribution.sql > dashboard/exports/order_status_distribution.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/order_value_by_status.sql > dashboard/exports/order_value_by_status.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/revenue_leakage_summary.sql > dashboard/exports/revenue_leakage_summary.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/canceled_value_by_category.sql > dashboard/exports/canceled_value_by_category.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/canceled_value_by_seller_state.sql > dashboard/exports/canceled_value_by_seller_state.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/delivery_overview.sql > dashboard/exports/delivery_overview.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/delivery_delay_buckets.sql > dashboard/exports/delivery_delay_buckets.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/late_delivery_by_category.sql > dashboard/exports/late_delivery_by_category.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/late_delivery_by_seller.sql > dashboard/exports/late_delivery_by_seller.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/review_distribution.sql > dashboard/exports/review_distribution.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/review_by_delay_bucket.sql > dashboard/exports/review_by_delay_bucket.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/low_review_by_category.sql > dashboard/exports/low_review_by_category.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/low_review_by_payment_type.sql > dashboard/exports/low_review_by_payment_type.csv
sqlite3 -header -csv data/olist.db < dashboard/queries/priority_table.sql > dashboard/exports/priority_table.csv
```

## Step 2: Open Looker Studio
1. Go to [Looker Studio](https://lookerstudio.google.com/).
2. Click `Create`, then `Report`.
3. Choose `File Upload` as the data source.
4. Upload one CSV at a time from `dashboard/exports/`.
5. Rename each uploaded data source so it matches the CSV name.

## Step 3: Check Field Types
After each upload, confirm:
- IDs, categories, issue names, and states are `Text`
- counts are `Number`
- percentages and rates are `Percent` or `Number` with percent formatting
- money fields are `Currency` or `Number` with 2 decimals

If a field is wrong, edit the data source before building charts.

## Step 4: Build the Dashboard Pages

### Page 1: Executive Overview
Business question: Where is the marketplace losing the most customer value?

Add these scorecards from `executive_kpis.csv`:
- total_orders
- completion_rate_pct
- cancellation_rate_pct
- late_delivery_rate_pct
- avg_review_score
- low_review_rate_pct
- canceled_order_value
- delayed_order_value

Add these visuals:
- horizontal bar chart from `order_status_distribution.csv`
- small scorecard or table using `review_by_delay_bucket.csv` for on-time vs late average review score

### Page 2: Funnel and Conversion
Business question: Where does the marketplace lose customers in the order journey?

Add these visuals:
- ordered bar chart or funnel-style chart from `funnel_stage_counts.csv`
- order status bar chart from `order_status_distribution.csv`
- bar chart for `order_value_by_status.csv`

Sort funnel stages manually in this order:
- purchased
- approved
- shipped
- delivered
- reviewed

### Page 3: Revenue and Segment Performance
Business question: Which segments create the largest revenue leakage?

Add these visuals:
- side-by-side bar chart from `revenue_leakage_summary.csv`
- horizontal bar chart from `canceled_value_by_category.csv`
- horizontal bar chart from `canceled_value_by_seller_state.csv`
- optional supporting table using `low_review_by_category.csv` if you want one extra segment view

### Page 4: Operations and Delivery Pain
Business question: Which operational bottlenecks create customer pain?

Add these scorecards from `delivery_overview.csv`:
- delivered_orders_with_dates
- avg_delivery_days
- late_delivery_rate_pct
- avg_days_late_when_late

Add these visuals:
- bar chart from `delivery_delay_buckets.csv`
- horizontal bar chart from `late_delivery_by_category.csv`
- horizontal bar chart from `late_delivery_by_seller.csv`

### Page 5: Customer Pain and Priority
Business question: What should the company fix first?

Add these visuals:
- review distribution bar chart from `review_distribution.csv`
- bar chart from `review_by_delay_bucket.csv`
- horizontal bar chart from `low_review_by_category.csv`
- bar chart from `low_review_by_payment_type.csv`
- table from `priority_table.csv`

For the priority table, include:
- issue
- priority_score
- owner
- metric_to_monitor
- recommended_action

## Design Rules
- Keep each page focused on one business question.
- Use horizontal bars for categories, states, and sellers.
- Keep colors consistent:
  - neutral gray or blue for context
  - orange or red for friction and risk
  - green only for on-time or healthy metrics
- Avoid clutter.
- Use at most 4 to 6 visuals per page.

## Validation Checklist
Compare your final dashboard values to the SQL outputs.

Important checks:
- completion_rate_pct = 97.02
- cancellation_rate_pct = 0.63
- late_delivery_rate_pct = 8.11
- delayed_order_value = 1351624.96
- avg_review_score for on_time = 4.29
- avg_review_score for 4_to_7_days_late = 2.32
- avg_review_score for 8_plus_days_late = 1.73

## Save Screenshots
After the report looks right:
1. Take one screenshot per page.
2. Save the images into `dashboard/screenshots/`.
3. Use those screenshots later in the README or portfolio write-up.

## Official References
- [Upload CSV files to Looker Studio](https://docs.cloud.google.com/looker/docs/studio/upload-csv-files-to-looker-studio?hl=es)
- [Add data to a Looker Studio report](https://docs.cloud.google.com/looker/docs/studio/add-data-to-a-report)
