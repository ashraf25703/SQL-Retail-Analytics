# Data Warehouse Analytics — SQL Project

## Overview
A SQL-based analytics project built on a retail sales data warehouse using Microsoft SQL Server.
The project covers exploratory analysis, trend tracking, customer and product segmentation,
and business reporting views.

## Database Schema
Three tables in the `gold` schema following a star schema design:

| Table | Description |
|---|---|
| `gold.dim_customers` | Customer details — name, country, gender, birthdate |
| `gold.dim_products` | Product details — category, subcategory, cost, product line |
| `gold.fact_sales` | Transactional sales data — orders, quantities, amounts, dates |

**Relationships:**
- `fact_sales.customer_key` → `dim_customers.customer_key`
- `fact_sales.product_key` → `dim_products.product_key`

## Business Questions Answered
- What are the overall business KPIs — total revenue, orders, customers?
- Which product categories generate the most revenue?
- How have monthly sales, quantity and customer counts trended over time?
- What is the running total of sales across the entire period?
- How do products perform year-over-year compared to their own average?
- Which customers are VIP, Regular, or New based on spending behaviour?
- What is each category's percentage contribution to overall revenue?

## Project Structure
DataWarehouseAnalytics/
├── README.md
├── sql/
│   ├── 01_setup.sql
│   ├── 02_exploratory.sql
│   ├── 03_trends_cumulative.sql
│   ├── 04_segmentation.sql
│   └── 05_reports.sql
├── datasets/
│   └── csv-files/
│       ├── gold.dim_customers.csv
│       ├── gold.dim_products.csv
│       └── gold.fact_sales.csv
└── screenshots/
    ├── key_metrics.png
    ├── customer_segmentation.png
    ├── monthly_trends.png
    └── product_performance.png
