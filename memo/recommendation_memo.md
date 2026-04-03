# Recommendation Memo

## Problem
The marketplace is not just facing isolated customer complaints. It is leaking value after purchase through delivery friction, concentrated segment-level pain, and a smaller but still meaningful pool of canceled orders. The business risk is both financial and experiential: orders are still being completed at a high rate, but late fulfillment materially lowers satisfaction and reduces the chance of repeat behavior.

## What The Analysis Found
- Order completion is high at 97.02 percent, but cancellations still represent 625 orders and about 105,885.72 in leaked order value.
- Delivery friction is the strongest customer pain signal. Late deliveries affect 8.11 percent of delivered orders, put about 1,351,624.96 in delayed order value at risk, and drag review scores sharply lower. On-time orders average 4.29, while orders delayed 4 to 7 days average 2.32 and orders delayed 8 or more days average 1.73.
- Operational pain is concentrated, not evenly spread. Ten sellers with at least 50 delivered orders have late-delivery rates above 20 percent, and three categories with at least 200 orders have low-review rates above 20 percent. `moveis_escritorio` is the clearest category pain point at 22.71 percent low reviews.

## Priority Actions
1. Improve delivery reliability in the highest-friction seller and category segments.
2. Add seller-level operational controls for repeat late-delivery offenders.
3. Audit the highest-pain categories to fix packaging, fulfillment, and expectation-setting issues before scaling more demand.

## Why These Matter
Late delivery is the strongest combination of business impact and frequency in this dataset. It affects a meaningful share of delivered orders and has a large downstream effect on satisfaction. Seller and category friction are the most practical ways to operationalize that finding because the pain is concentrated rather than marketplace-wide. Cancellations are less frequent, but they still create direct revenue leakage and should remain a monitored secondary workstream.

## Recommended Owners
- Logistics / Ops: improve delivery SLA performance and exception handling
- Seller Operations: coach and monitor high-friction sellers
- Product / Checkout: monitor payment-type friction and improve support messaging
- Customer Support: watch low-review segments and escalate recurring pain themes

## Metrics To Monitor
- cancellation rate
- canceled order value
- late delivery rate
- delayed order value
- average review score
- low review score rate
- seller late-delivery rate
- category low-review rate

## Rollout Order
Start with delivery reliability because it is both frequent and strongly linked to lower satisfaction. Next, operationalize seller scorecards and escalation thresholds. Then audit high-pain categories and tighten monitoring on cancellation-heavy segments and payment paths with weaker customer outcomes.
