# Marketplace Drop-Off, Revenue Leakage, and Operational Friction

## Overview
This project is a frontend-first marketplace case study built on the Olist Brazilian E-Commerce dataset. It investigates where the business loses revenue and customer trust after purchase, then turns those findings into a ranked action plan. The finished deliverable is an interactive storytelling site in `docs/`, supported by SQL analysis, a recommendation memo, and lightweight project documentation.

## Why This Matters
The marketplace does not have a top-line demand problem first. Order completion is strong, but post-purchase friction is still eroding value:
- completion rate: `97.02%`
- cancellation rate: `0.63%`
- late delivery rate: `8.11%`
- delayed order value at risk: `1,351,624.96`

That makes the project useful for product, analytics, and operations roles at the same time. It connects metrics to customer pain, operational bottlenecks, and concrete business recommendations.

## Frontend Preview
The main portfolio artifact is the static storytelling frontend in [`docs/`](docs/). It is designed for GitHub Pages and walks through:
- marketplace health
- post-purchase funnel performance
- revenue leakage
- delivery-driven customer pain
- concentrated seller and category friction
- a final priority system for what the business should fix first

Local preview:

```bash
python3 -m http.server 8000
```

Then open `http://localhost:8000/docs/`

## Key Findings
- Most orders complete, but post-purchase friction still creates meaningful business risk.
- Late deliveries are the biggest visible source of value at risk, far outweighing canceled-order value.
- Customer satisfaction drops sharply as delivery delays increase, from `4.29` for on-time orders to `1.73` for orders delayed `8+` days.
- Pain is concentrated enough to act on: a smaller set of sellers and categories drives a disproportionate share of late deliveries and low reviews.

## Recommendation Summary
1. Improve delivery reliability in the highest-friction seller and category segments first.
2. Add tighter seller operational controls for repeat late-delivery offenders.
3. Monitor cancellation leakage, category pain, and payment-related friction with recurring segment-level reporting.

## Repo Guide
```text
marketplace-dropoff-priority-analysis/
├── docs/                    # Primary portfolio frontend for GitHub Pages
├── sql/                     # Analysis workstreams and priority system
├── scripts/                 # SQLite load + SQL runner helpers
├── memo/                    # Recommendation memo
├── dashboard/               # Archived export/query artifacts from earlier dashboard workflow
├── project_brief.md         # Business framing
├── schema_diagram.md        # Simple schema notes
└── README.md
```

## Technical Workflow
This repo uses a simple Python + SQLite workflow:
- `scripts/load_csv_to_sqlite.py` loads raw Olist CSVs into `data/olist.db`
- `scripts/run_sql.py` runs saved SQL files from `sql/`
- SQL outputs were shaped into static frontend data for the `docs/` site
- the project does not depend on a VS Code database extension or a live BI connection

Example:

```bash
python3 scripts/run_sql.py sql/datachecks.sql
python3 scripts/run_sql.py sql/priority_system.sql
```

## Supporting Assets
- [`project_brief.md`](project_brief.md) explains the business question and goals
- [`schema_diagram.md`](schema_diagram.md) documents the lightweight schema used in the analysis
- [`memo/recommendation_memo.md`](memo/recommendation_memo.md) summarizes the business recommendations
- [`sql/`](sql/) contains the analysis workstreams behind the story

## Tools
- Python
- SQLite
- pandas
- SQL
- plain HTML, CSS, and JavaScript
- Chart.js

## Publish Notes
The repo is set up for GitHub Pages publishing from `docs/`. Keep asset paths relative and keep `docs/.nojekyll` in place when publishing.
