/*
===============================
--REPORTING
===============================
--Building customer report
purpose:
This report consolidates key customer metrics and behaviours

Highlights:
1. Gather essential fields such as names,ages and transaction details.
2. Segment customers into categories (VIP,REGULAR,NEW) and age groups.
3. Aggregate customer level metrics:
-total orders
-total sales
-total quantity purchased
-total products
-lifespan (in months)
4.calculates valuable KPIs:
-recency (months since last order)
-average order value
-average monthly spend
===================================================================================
*/
CREATE VIEW gold.report_customers AS
With base_query as (
/*---------------------------------------------------------------------------------
1) Base query:Retrives core columns from tables
-----------------------------------------------------------------------------------*/
SELECT
s.order_number,
s.product_key,
s.order_date,
s.sales_amount,
s.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name,' ',c.last_name) as Customer_name,
Datediff(Year,c.birthdate,getdate()) as Age
FROM gold.fact_sales as s
LEFT JOIN gold.dim_customers as c
on s.customer_key=c.customer_key
Where s.order_date is not null)
,Customer_aggregation as(
/*
3. Aggregate customer level metrics:
-total orders
-total sales
-total quantity purchased
-total products
-lifespan (in months)*/
SELECT 
customer_key,
customer_number,
Customer_name,
Age,
COUNT(DISTINCT order_number) as total_orders,
SUM(sales_amount) as total_sales,
SUm(quantity) as total_quantity,
COUNT(Distinct product_key) as total_products,
MAX(order_date) as last_order_date,
DATEDIFF(month,MIN(order_date),MAX(order_date)) as lifespan
FROM base_query
GROUP BY  
customer_key,
customer_number,
Customer_name,
Age
)

SELECT 
customer_key,
customer_number,
Customer_name,
Age,
--2. Segment customers into categories (VIP,REGULAR,NEW) and age groups.
CASE WHEN Age <20  THEN 'Under 20'
	 WHEN Age between 20 and 29 THEN '20-29'
	 WHEN Age between 30 and 39 THEN '30-39'
	 WHEN Age between 40 and 49 THEN '40-49'
	 ELSE '50 And Above'
END as Age_group,
CASE WHEN lifespan >=12 and total_sales>5000 THEN 'VIP'
	 WHEN lifespan >=12 and total_sales<=5000 THEN 'Regular'
	 ELSE 'New'
END customer_segment,
last_order_date,
DATEDIFF(month,last_order_date,getdate()) as recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
-- Compute average order value
CASE WHEN total_sales=0 THEN 0
ELSE Total_sales/Total_orders
END as avg_order_value,
--Average monthly spend
CASE WHEN lifespan=0 THEN total_sales
ELSE Total_sales/lifespan
END as avg_monthly_spend
FROM Customer_aggregation;

--Building Product Report

SELECT
p.product_key,
p.product_number,
p.Product_name,
category,
subcategory,
Sum(cost) as total_cost,
Sum(s.sales_amount) as Total_sales,
Min(s.order_date) as Last_order_Date,
Sum(s.quantity) as total_quantity,
Count(s.customer_key) as total_customers,
start_date
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products as p
on s.product_key=p.product_key
group by
p.product_key,
p.product_number,
p.Product_name,category,
subcategory,start_date;

CREATE VIEW gold.report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------------
1) Join product + sales (core dataset)
-----------------------------------------------------------------------------------*/
SELECT
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.product_line,
    p.cost,
    s.order_number,
    s.order_date,
    s.sales_amount,
    s.quantity

FROM gold.dim_products p
LEFT JOIN gold.fact_sales s
    ON p.product_key = s.product_key
WHERE s.order_date IS NOT NULL
),

product_aggregation AS (
/*---------------------------------------------------------------------------------
2) Aggregate product-level metrics
-----------------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    product_line,

    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,

    COUNT(DISTINCT order_date) AS active_days,

    MIN(order_date) AS first_sale_date,
    MAX(order_date) AS last_sale_date,

    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan

FROM base_query
GROUP BY 
    product_key,
    product_name,
    category,
    subcategory,
    product_line
)

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    product_line,

    total_orders,
    total_sales,
    total_quantity,
    lifespan,

-- Recency (VERY IMPORTANT KPI)
DATEDIFF(month, last_sale_date, GETDATE()) AS recency,

--Avg order value
ROUND(COALESCE(CAST(total_sales AS FLOAT) / NULLIF(total_orders, 0), 0), 2) AS avg_order_value,
--Avg monthly sales
ROUND(COALESCE(CAST(total_sales AS FLOAT) / NULLIF(lifespan, 0), total_sales), 2) AS avg_monthly_sales,

/*---------------------------------------------------------------------------------
3) Product Segmentation (like customer segmentation)
-----------------------------------------------------------------------------------*/

-- Revenue-based segmentation
CASE 
    WHEN total_sales > 50000 THEN 'Top Performer'
    WHEN total_sales BETWEEN 10000 AND 50000 THEN 'Mid Performer'
    ELSE 'Low Performer'
END AS product_segment,

-- Demand segmentation
CASE 
    WHEN total_orders > 100 THEN 'High Demand'
    WHEN total_orders BETWEEN 20 AND 100 THEN 'Medium Demand'
    ELSE 'Low Demand'
END AS demand_segment

FROM product_aggregation;