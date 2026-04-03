# Project Brief

## Project Title
Marketplace Drop-Off, Revenue Leakage, and Operational Friction

## Final Project Statement
This project investigates where an e-commerce marketplace is losing customers, revenue, and trust after purchase. Using the Olist Brazilian E-Commerce dataset, the analysis focuses on post-purchase friction, including cancellations, delivery delays, seller performance, and low customer satisfaction, then translates those findings into a prioritized action plan.

## Business Problem
A marketplace can look healthy at the top line while still leaking value through delayed deliveries, order cancellations, and negative customer experiences concentrated in a small set of categories, sellers, payment types, or regions. The goal is to identify where that friction is concentrated, measure its business cost, and recommend what the company should fix first.

## Why This Project Works
This case study is designed to demonstrate four capabilities in one portfolio piece:
- data analysis
- product thinking
- ops and process thinking
- business recommendations

It is framed like an internal business investigation rather than a school assignment.

## Locked Workflow
- Raw source files live in `data/raw/`
- SQLite is the system of record for analysis
- `scripts/load_csv_to_sqlite.py` loads CSVs into `data/olist.db`
- `scripts/run_sql.py` is the normal way to run saved SQL files
- The project does not depend on a VS Code database extension

## Phase 1 Deliverables
- project brief
- simple schema diagram
- SQL analysis files
- dashboard plan
- recommendation memo
- recruiter-facing README

## Core Metrics
- Order completion rate = delivered orders / total orders
- Cancellation rate = canceled orders / total orders
- Late delivery rate = delivered orders with actual delivery date after estimated date / delivered orders with both dates
- Canceled order value = sum of `price + freight_value` for canceled orders
- Delayed order value = sum of `price + freight_value` for late delivered orders
- Low review score rate = reviews with score `<= 2` / all reviews
- Repeat customer proxy = customers with `>= 2` delivered orders using `customer_unique_id`
- Average order value = total `price + freight_value` / distinct orders

## Success Criteria
- The project tells one clear marketplace story from problem to recommendation
- The analysis stays grounded in tables that actually exist in Olist
- The deliverables are clean enough for recruiters to scan quickly
- The memo and dashboard point to concrete business actions, not just charts
- The priority system makes it obvious what the business should fix first
