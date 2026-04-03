# Dashboard Visual Mock

This is a visual wireframe for the 5-page Looker Studio dashboard. It is designed to be simple, recruiter-friendly, and easy to build from the CSV files in `dashboard/exports/`.

Use a light background, one accent color for neutral context, and one warning color for friction and risk.

Suggested palette:
- background: white
- text: dark gray
- neutral charts: slate blue
- risk charts: orange or red
- positive charts: muted green

Suggested page size:
- standard Looker Studio landscape layout
- keep generous spacing
- avoid squeezing more than 4 to 6 visuals per page

---

## Page 1: Executive Overview
Business question: Where is the marketplace losing the most customer value?

### Layout mock

```text
+----------------------------------------------------------------------------------+
| Marketplace Drop-Off, Revenue Leakage, and Operational Friction                 |
| Executive Overview                                                               |
+----------------------------------------------------------------------------------+
| Total Orders | Completion Rate | Cancellation Rate | Late Delivery Rate         |
| 99,441       | 97.02%          | 0.63%             | 8.11%                      |
+----------------------------------------------------------------------------------+
| Avg Review Score | Low Review Rate | Canceled Order Value | Delayed Order Value |
| 4.09             | 14.69%          | 105,885.72          | 1,351,624.96         |
+------------------------------------------------------+---------------------------+
| Order Status Distribution                             | Review Score by Delay    |
| horizontal bar chart                                  | small comparison chart   |
| delivered dominates, canceled tiny but real           | on_time vs late buckets  |
+------------------------------------------------------+---------------------------+
| Bottom callout:                                                               |
| "Late delivery is the highest-friction issue because it is frequent, puts     |
| meaningful value at risk, and sharply lowers customer satisfaction."          |
+----------------------------------------------------------------------------------+
```

### What it should feel like
- very clean
- top-line business scorecards first
- one strong chart on volume
- one strong chart on satisfaction impact

### Charts
- 8 KPI scorecards from `executive_kpis.csv`
- 1 horizontal bar chart from `order_status_distribution.csv`
- 1 bar chart from `review_by_delay_bucket.csv`

---

## Page 2: Funnel and Conversion
Business question: Where does the marketplace lose customers in the order journey?

### Layout mock

```text
+----------------------------------------------------------------------------------+
| Funnel and Conversion                                                            |
+------------------------------------------+---------------------------------------+
| Funnel Stage Counts                      | Order Status Distribution             |
| purchased -> approved -> shipped         | delivered, shipped, canceled, etc.   |
| -> delivered -> reviewed                 | horizontal bar chart                 |
+------------------------------------------+---------------------------------------+
| Order Value by Status                                                            |
| wide horizontal bar chart showing delivered vs canceled vs other statuses        |
+----------------------------------------------------------------------------------+
| Bottom note:                                                                     |
| "The marketplace has high completion overall, but value leakage still appears    |
| in cancellations and downstream post-purchase friction."                         |
+----------------------------------------------------------------------------------+
```

### What it should feel like
- one page that explains the journey simply
- no clutter
- clear difference between volume loss and value loss

### Charts
- funnel chart or ordered vertical bar chart from `funnel_stage_counts.csv`
- horizontal bar chart from `order_status_distribution.csv`
- horizontal or vertical bar chart from `order_value_by_status.csv`

---

## Page 3: Revenue and Segment Performance
Business question: Which segments create the largest revenue leakage?

### Layout mock

```text
+----------------------------------------------------------------------------------+
| Revenue and Segment Performance                                                  |
+------------------------------------------+---------------------------------------+
| Revenue Leakage Summary                  | Canceled Value by Seller State        |
| canceled_orders vs late_deliveries       | horizontal bar chart                  |
| side-by-side bar chart                   | SP, MG, SC, RJ, PR...                |
+------------------------------------------+---------------------------------------+
| Canceled Value by Category                                                       |
| wide horizontal bar chart                                                        |
| cool_stuff, esporte_lazer, informatica_acessorios, etc.                          |
+----------------------------------------------------------------------------------+
| Optional supporting table                                                        |
| top 10 risky categories with orders, cancellation rate, late rate, low reviews  |
+----------------------------------------------------------------------------------+
```

### What it should feel like
- financially oriented
- segment-oriented
- should make it obvious that delayed deliveries are the larger value-at-risk issue

### Charts
- bar chart from `revenue_leakage_summary.csv`
- horizontal bar chart from `canceled_value_by_seller_state.csv`
- horizontal bar chart from `canceled_value_by_category.csv`
- optional supporting table from `low_review_by_category.csv`

---

## Page 4: Operations and Delivery Pain
Business question: Which operational bottlenecks create customer pain?

### Layout mock

```text
+----------------------------------------------------------------------------------+
| Operations and Delivery Pain                                                     |
+----------------------------------------------------------------------------------+
| Delivered Orders with Dates | Avg Delivery Days | Late Delivery Rate | Avg Days |
| 96,470                      | 12.56             | 8.11%              | 9.55     |
|                                                                     | Late      |
+------------------------------------------+---------------------------------------+
| Delivery Delay Buckets                    | Late Delivery by Category            |
| on_time, 1-3 late, 4-7 late, 8+ late     | horizontal bar chart                 |
| vertical bar chart                        | audio, moveis_escritorio, etc.       |
+------------------------------------------+---------------------------------------+
| Late Delivery by Seller                                                           |
| wide horizontal bar chart                                                         |
| seller IDs with highest late delivery rates                                       |
+----------------------------------------------------------------------------------+
| Bottom note:                                                                     |
| "Delivery friction is concentrated in a smaller set of sellers and categories,   |
| which makes it more actionable than a marketplace-wide issue."                   |
+----------------------------------------------------------------------------------+
```

### What it should feel like
- operational
- diagnostic
- should visually connect process friction to specific segments

### Charts
- 4 KPI scorecards from `delivery_overview.csv`
- vertical bar chart from `delivery_delay_buckets.csv`
- horizontal bar chart from `late_delivery_by_category.csv`
- horizontal bar chart from `late_delivery_by_seller.csv`

---

## Page 5: Customer Pain and Priority
Business question: What should the company fix first?

### Layout mock

```text
+----------------------------------------------------------------------------------+
| Customer Pain and Priority                                                       |
+------------------------------------------+---------------------------------------+
| Review Distribution                      | Review by Delay Bucket                |
| 1 to 5 review score bar chart            | avg review and low-review rate        |
+------------------------------------------+---------------------------------------+
| Low Review Rate by Category              | Low Review Rate by Payment Type       |
| horizontal bar chart                     | small bar chart                       |
+----------------------------------------------------------------------------------+
| Priority Table                                                                   |
| issue | priority_score | owner | metric_to_monitor | recommended_action          |
| Late delivery | 20 | Logistics / Ops | late_delivery_rate_pct | ...             |
+----------------------------------------------------------------------------------+
| Bottom callout:                                                                   |
| "The project does not stop at identifying pain points. It ranks what the        |
| business should fix first."                                                      |
+----------------------------------------------------------------------------------+
```

### What it should feel like
- conclusive
- recommendation-focused
- should end the story, not restart the analysis

### Charts
- bar chart from `review_distribution.csv`
- bar chart from `review_by_delay_bucket.csv`
- horizontal bar chart from `low_review_by_category.csv`
- bar chart from `low_review_by_payment_type.csv`
- table from `priority_table.csv`

---

## Styling Rules

### Titles
- Use short page titles.
- Add one short subtitle under each title with the business question.

### Scorecards
- Put scorecards at the top of pages.
- Keep labels short.
- Use consistent number formatting:
  - percentages with 2 decimals
  - currency with commas and 2 decimals
  - counts as integers

### Charts
- Prefer horizontal bar charts for categories, sellers, and states.
- Sort descending by the key metric.
- Avoid legends when direct labels are clearer.
- Show data labels only when they add readability.

### Tables
- Use the priority table only on the final page.
- Keep no more than 5 rows visible at once if the text is long.
- Let `recommended_action` be the widest column.

### Spacing
- Leave enough white space between charts.
- Align cards and charts cleanly.
- Avoid squeezing too many visuals on one page.

---

## Build Order
Use this order when building in Looker Studio:

1. Page 1
2. Page 2
3. Page 4
4. Page 5
5. Page 3

Why this order:
- Page 1 gives you the core formatting system
- Page 2 is easy once the first page is styled
- Page 4 and 5 are the strongest insight pages
- Page 3 is easiest to polish after the rest is stable

---

## Minimum Viable Version
If you want a faster first pass, build only:
- Page 1
- Page 4
- Page 5

That still tells the strongest story:
- what is happening
- why it is happening
- what to fix first
