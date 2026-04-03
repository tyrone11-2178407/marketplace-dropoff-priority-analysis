# Simple Schema Diagram

This project uses a lightweight schema view instead of a formal ERD.

`customers -> orders -> order_items -> products`
`orders -> payments`
`orders -> reviews`
`order_items -> sellers`

## Main Grain
- `orders` = one row per order
- `order_items` = one row per item within an order
- `payments` = one or more payment records per order
- `reviews` = review records joined back at the order level
- `customers`, `products`, and `sellers` provide segment attributes for analysis

## Core Joins
- `orders.order_id = order_items.order_id`
- `orders.order_id = payments.order_id`
- `orders.order_id = reviews.order_id`
- `orders.customer_id = customers.customer_id`
- `order_items.product_id = products.product_id`
- `order_items.seller_id = sellers.seller_id`

## Modeling Notes
- The project uses order-status analysis, not clickstream funnel analysis.
- Repeat purchase is a proxy built from `customer_unique_id`.
- `review_id` is not unique in this dataset, so review analysis treats `order_id` as the reliable join key.
- Geolocation is optional and not required for the core business story.
