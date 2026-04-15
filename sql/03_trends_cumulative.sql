--CHANGE OVER TIME(TRENDS)

--Changes happend in sales,customers and quantity over time
SELECT
DATETRUNC(month,order_date) as Order_date,
Sum(sales_amount) as total_sales,
Count(Distinct customer_key) as total_customers,
Sum(quantity) as total_quantity
FROM gold.fact_sales
where order_date is not null
group by DATETRUNC(month,order_date)
order by DATETRUNC(month,order_date);

--CUMMULATIVE ANALYSIS

--Calculate the total sales per month
--and running total of sales over time
SELECT
order_date,
total_sales,
Sum(total_sales) over(partition by order_date order by order_date) as running_total_sales,
Avg(avg_price) over(partition by order_date order by order_date) as Moving_avg_price
FROM(
SELECT
DATETRUNC(month,order_date) as order_date,
Sum(sales_amount) as total_sales,
Avg(price) as avg_price
FROM gold.fact_sales
Where order_date is not null
Group By DATETRUNC(month,order_date)
)t;

--PERFORMANCE ANALYSIS

/*Analyzing the yearly performance of products by camparing each products sales to both its average
sales performance and to the previous year sales*/
With yearly_sales As (
SELECT
YEAR(s.order_date) as order_year,
p.product_name,
Sum(s.sales_amount) as Current_sales
FROM gold.fact_sales as s
LEFT JOIN gold.dim_products as p
on s.product_key=p.product_key
where order_date is not null
group by YEAR(s.order_date),p.product_name
)
SELECT
order_year,
product_name,
current_sales,
Avg(current_Sales) over(partition by product_name) as avg_sales,
current_sales-Avg(current_sales) over(partition by product_name) as sales_difference,
CASE WHEN current_sales-Avg(current_sales) over(partition by product_name) >0 THEN 'Above Average'
	 WHEN current_sales-Avg(current_sales) over(partition by product_name)<0 THEN 'Below Average'
	 ELSE 'Average'
	 END Avg_change,
LAG(current_sales) over(partition by product_name order by order_year) prev_sales,
Current_sales - LAG(current_sales) over(partition by product_name order by order_year) as difference_prev_year,
CASE WHEN current_sales-LAG(current_sales) over(partition by product_name order by order_year) > 0 THEN 'Increase'
	 WHEN Current_sales - LAG(current_sales) over(partition by product_name order by order_year) < 0 THEN 'Decrease'
	 ELSE 'No Change'
	 END Prev_change
FROM yearly_sales
order by product_name,order_year;

--PART TO WHOLE ANALYSIS'

--Which category contribute to most to overall sales?
WITH Category_sales as(
SELECT
category,
Sum(sales_amount) as total_sales
FROM gold.fact_sales as s
LEFT JOIN gold.dim_products as p
on s.product_key=p.product_key
Group By category
)
SELECT
category,
total_sales,
Sum(total_sales) over()as overall_sales,
Concat(Round((CAST(total_sales as FLoat) / Sum(total_sales) over())*100,2),'%') as percent_sales
From Category_sales
order by total_sales desc;