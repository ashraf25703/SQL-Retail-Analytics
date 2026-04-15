--DATA SEGMENTATION

/* Segment products into cost ranges and count how many products fall
into each segment*/
WITH prod_segment AS(
SELECT
Product_key,
Product_name,
cost,
CASE WHEN cost <100 THEN 'Below 100'
	 WHEN cost between 100 and 500 THEN '100-500'
	 WHEN cost between 500 and 1000 THEN '500-1000'
	 ELSE 'Above 1000'
	 END as Cost_range
FROM gold.dim_products
)
SELECT
cost_range,
COUNT(product_key) as total_product
FROM prod_segment
Group By cost_range
Order By total_product DESC;

/* Group customers onto three segment based on their spending behaviour:
-VIP: Who have atleast 12 month of history and spending more than 5000.
-Regular: who have atleast 12 months of history but spend 5000 and less.
-New: who have lifespawn of less than 12 months.
And find total number of customer in each group*/
WITH cust_spending AS(
SELECT
c.customer_key,
SUM(s.sales_amount) as total_spend,
MIN(order_date) as first_order,
MAX(order_date) as last_order,
DATEDIFF(month,MIN(order_date),MAX(order_date)) as lifespawn
FROM gold.fact_sales as s
LEFT JOIN gold.dim_customers as c
on s.customer_key=c.customer_key
group by c.customer_key
)

SELECT
customer_segment,
COUNT(customer_key) as total_customers
FROM
( SELECT
customer_key,
total_spend,
lifespawn,
CASE WHEN lifespawn >=12 and total_spend>5000 THEN 'VIP'
	 WHEN lifespawn >=12 and total_spend<=5000 THEN 'Regular'
	 ELSE 'New'
	 END customer_segment
FROM cust_spending)t
Group By customer_segment
Order By total_customers DESC;