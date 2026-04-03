# Dashboard Plan

## Goal
Build a 5-page executive-friendly dashboard that shows where the marketplace loses customers, revenue, and trust, then connects those issues to a ranked action plan.

This project is set up to be built in Looker Studio with manual CSV uploads. Use the export-ready SQL files in `dashboard/queries/` and the step-by-step instructions in `dashboard/looker_studio_build_guide.md`.

## Page 1: Executive Overview
Business question: Where is the marketplace losing the most customer value?

Primary KPIs:
- total orders
- order completion rate
- cancellation rate
- late delivery rate
- average review score
- low review score rate
- canceled order value
- delayed order value

Recommended visuals:
- KPI cards for the eight core metrics
- order status bar chart from `sql/funnel.sql`
- small callout showing on-time vs late review score gap from `sql/customer_pain.sql`

Decision takeaway:
- show immediately that late delivery is the highest-friction post-purchase problem

## Page 2: Funnel and Conversion
Business question: Where does the marketplace lose customers in the order journey?

Primary visuals:
- order lifecycle funnel using purchased, approved, shipped, delivered, reviewed
- order status distribution
- order value by status

Source SQL:
- `sql/funnel.sql`

Decision takeaway:
- separate direct order loss through cancellation from downstream friction after purchase

## Page 3: Revenue and Segment Performance
Business question: Which segments create the largest revenue leakage?

Primary visuals:
- canceled versus delayed value at risk
- canceled value by category
- canceled value by seller state
- highest-risk segment table by category or seller

Source SQL:
- `sql/revenue_leakage.sql`
- `sql/segmentation.sql`

Decision takeaway:
- highlight where revenue leakage is concentrated instead of treating it as evenly distributed

## Page 4: Operations and Delivery Pain
Business question: Which operational bottlenecks create customer pain?

Primary visuals:
- average delivery days and late delivery rate
- delivery delay bucket chart
- worst categories by late delivery rate
- worst sellers by late delivery rate

Source SQL:
- `sql/delivery_delay.sql`

Decision takeaway:
- tie operational issues to specific seller and category segments that need intervention

## Page 5: Customer Pain and Priority
Business question: What should the company fix first?

Primary visuals:
- review score by delay bucket
- low review rate by category
- low review rate by payment type
- priority table with issue, score, owner, and action

Source SQL:
- `sql/customer_pain.sql`
- `sql/priority_system.sql`

Decision takeaway:
- close the story with a ranked action plan instead of stopping at descriptive analysis

## Design Guardrails
- keep to 4-5 pages maximum
- each page should answer one business question
- every chart should support a business decision
- avoid clutter and use labels that a recruiter or hiring manager can scan quickly
