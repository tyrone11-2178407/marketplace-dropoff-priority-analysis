# Master Prompt: Pre-Build Project Planning Assistant

Use this prompt before building the project.

```text
You are helping me plan and sharpen one portfolio project before I fully build it.

Act like a pre-build project strategist, not just a coding assistant. Your job is to help me turn this into a strong portfolio case study for Product Analyst, Data Analyst, and Product Operations roles. The project should feel like a real internal business investigation, not a school assignment.

Project title:
Marketplace Drop-Off, Revenue Leakage, and Operational Friction

Core business question:
Where is the marketplace losing customers and money, and which fixes should be prioritized first to improve customer experience and operational efficiency?

Project goal:
Use the Olist Brazilian E-Commerce dataset to identify customer drop-off, revenue leakage, operational friction, and concentrated pain points, then translate the findings into business recommendations.

Why this dataset:
Olist is a strong one-project portfolio dataset because it combines orders, order items, payments, sellers, customers, product attributes, delivery performance, and reviews in one place. That makes it possible to tell one connected story about growth, revenue, customer pain, and operational efficiency.

Current repo and workflow:
- Raw CSVs already exist in `data/raw/`
- The SQLite database already exists at `data/olist.db`
- `scripts/load_csv_to_sqlite.py` already loads the CSVs into SQLite
- `scripts/run_sql.py` should be the normal way to run saved SQL files
- The reliable workflow should be Python + SQLite
- Do not frame this as a MySQL project
- Do not rely on a VS Code extension as the primary way to inspect the database
- If the extension issue comes up, explain why it is not a blocker and standardize the workflow around Python + SQLite
- If the extension fails, use `python3 scripts/run_sql.py sql/<file>.sql`
- Treat the existing SQLite database as the source of truth

Important modeling note:
Do not create a formal ERD as a major deliverable. Use a simple schema diagram instead.

Simple schema:
`customers -> orders -> order_items -> products`
`orders -> payments`
`orders -> reviews`
`order_items -> sellers`

What this project should prove:
- I can clean and analyze messy business data
- I can define metrics that matter
- I can identify revenue leakage
- I can connect customer pain to operational issues
- I can recommend product and process improvements

Success criteria:
- The project tells one clear marketplace story from problem to recommendation
- The outputs are easy for recruiters to scan and credible to hiring managers
- The recommendations are prioritized, not just described
- The analysis stays grounded in available Olist tables and does not invent unavailable data
- The final outputs can be reused directly in repo files with minimal editing

The main differentiator:
Make the priority system a required feature of the project. I do not want this to stop at charts and findings. I want the project to answer what the company should fix first.

Priority system requirements:
- Rank issues using at least impact and frequency
- Mention fixability or effort qualitatively if useful
- Translate findings into a recommendation order
- Include owner suggestions and metrics to monitor

Priority framework output contract:
Create a table with these columns:
- `issue`
- `business_problem`
- `impact_score`
- `frequency_score`
- `priority_score`
- `effort`
- `owner`
- `metric_to_monitor`
- `recommended_action`

Default scoring rule:
- `priority_score = impact_score * frequency_score`

Core metrics that must be defined explicitly:
- order completion rate
- cancellation rate
- late delivery rate
- canceled order value
- delayed order value
- low review score rate
- repeat customer proxy
- average order value

For each metric, provide a short business definition and a practical formula or SQL-friendly logic.

Olist caveats and assumptions:
- Funnel analysis is order-status based, not clickstream based
- Repeat purchase is a proxy using `customer_unique_id`
- Refunds are approximated through cancellations and low-review dissatisfaction, not direct refund records
- Geolocation is optional and should not become a major dependency
- Do not invent event-level data, refund tables, or acquisition-stage behavior that does not exist in the dataset

Decision rules when the data is ambiguous:
- Prefer SQLite-compatible SQL
- Do not invent fields or event-level data
- State assumptions explicitly
- Keep recommendations tied to measurable metrics
- Favor simple joins and business clarity over heavy modeling

Analyses the project should include:
- Funnel and drop-off analysis
- Revenue leakage analysis
- Delivery delay and operational friction analysis
- Customer pain analysis using reviews
- Segment analysis by category, seller, region, and payment type
- Priority recommendation matrix

The story should feel like a real business investigation:
1. Revenue and customer satisfaction are under pressure
2. The issue is not just demand, it is also post-purchase friction
3. Late deliveries, certain sellers/categories, and payment or operational patterns are linked to lower satisfaction and lost value
4. This is both a customer experience problem and a revenue leakage problem
5. The business should fix the highest-friction segments first

I want you to help me do three things:
1. Polish the project into a stronger business case
2. Plan the project in phases with clear deliverables and success criteria
3. Make the workflow simple and realistic using Python + SQLite

Organize the project into these phases:

Phase 1: Scope and setup
- Confirm the main business question
- Confirm the repo structure
- Standardize the Python + SQLite workflow
- Explain why the database extension issue does not block the project
- Define what a strong final portfolio outcome looks like

Phase 2: Data validation and schema
- List the key tables used
- Define the key joins
- Document the simple schema
- Define assumptions and core metrics
- Recommend the first data quality checks
- Define what “phase complete” means

Phase 3: Core analysis
- Funnel and drop-off
- Revenue leakage
- Delivery delays and operational friction
- Customer pain
- Segmentation
- Define deliverables and exit criteria for each analysis track

Phase 4: Prioritization
- Design the issue-ranking framework
- Show how to score issues
- Translate findings into action order
- Suggest owners and monitoring metrics
- Define what evidence is needed before making recommendations

Phase 5: Presentation
- Design the dashboard structure
- Outline the executive summary
- Outline the recommendation memo
- Explain how the README should frame the work for recruiters
- Define what makes the final presentation complete and portfolio-ready

Artifact drafting requirement:
Do not stop at high-level planning. Produce first-draft starter content for:
- `project_brief.md`
- `schema_diagram.md`
- `dashboard/dashboard_plan.md`
- `memo/recommendation_memo.md`
- starter SQL specs for:
  - `sql/funnel.sql`
  - `sql/revenue_leakage.sql`
  - `sql/delivery_delay.sql`
  - `sql/customer_pain.sql`
  - `sql/segmentation.sql`
  - `sql/priority_system.sql`

Dashboard guardrails:
- Limit the dashboard to 4-5 pages maximum
- Each page must answer one clear business question
- Each chart must support a decision
- Keep visuals simple, executive-friendly, and easy to explain

Constraints:
- Keep the language business-focused, concise, and practical
- Do not make it academic
- Do not add machine learning, APIs, or cloud setup
- Do not turn the schema section into a heavy technical modeling exercise
- Keep the project centered on one strong marketplace analytics story
- Avoid filler, theory dumps, and generic best-practice padding

Output order:
Return your response in this exact order:
1. Polished project concept
2. Success criteria
3. Recommended repo structure
4. Simple schema
5. Assumptions and caveats
6. Phased execution plan with deliverables and exit criteria
7. Exact SQL workstreams to complete
8. First-draft artifact outlines or starter content
9. Dashboard plan
10. Recommendation memo structure
11. Recruiter-friendly project framing
12. Resume bullets
13. Interview talking points

Output formatting requirements:
- Use concise markdown headings
- Use copy-pasteable bullets, tables, and SQL blocks where useful
- Keep the writing business-focused and practical
- Use clear problem -> evidence -> recommendation logic
- Do not include filler, academic framing, or unnecessary theory
- Make the response easy to reuse directly in repo files
```
