-- 7: Change Over Time

select
year(order_date) as order_date,
month(order_date) as order_month,
sum(sales_amount) as sales_amount,
count(distinct customer_key) as total_customers,          -- Analyse sales performance over time
sum(sales_quantity) as total_quantity
from gold.fact_sales
where order_Date is not null
group by year(order_date),month(order_date)
order by year(order_date),month(order_date);
SELECT
date_FORMAT(order_date, '%Y-%m-%d') AS order_date,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,              -- Date Format
SUM(sales_quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY date_FORMAT(order_date, '%Y-%m-%d')
ORDER BY date_FORMAT(order_date, '%Y-%m-%d');

-- 8: Cummulative Analysis


select
order_date,
total_sales,
sum(total_sales) over (order by order_Date )as running_total,
avg(avg_price) over (order by order_Date )as average_price
from                                                                  -- Calculate the total sales per month                                                                      
(                                                                     -- and the running total of sales over time 
select                                                              
date_format(order_date,'%Y') as order_date,
sum(sales_amount) as total_sales,
avg(price) as avg_price
from gold.fact_sales
where order_date is not null
group by date_format(order_date,'%Y')
)t
order by date_format(order_date,'%Y-%m') 
;

-- 9: Performance Analysis

with yearly_product_sales as(
select
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales                  -- the average sales performance of the product and the previous years sales
from gold.fact_sales f
left join gold.dim_products p
on 		f.product_key=p.product_key
where order_date is not null
group by year(f.order_date),
p.product_name 
)												   													
select                                                 -- Analyze the yearly performance of products by comparing their sales to both
order_year,
product_name,
current_sales,
avg(current_sales) over (partition by product_name) avg_sales,
current_sales - avg(current_sales) over (partition by product_name) diff_avg,
case when current_sales - avg(current_sales) over (partition by product_name) > 0 then 'Above Avg'
	   when current_sales - avg(current_sales) over (partition by product_name) < 0 then 'Below Avg'
else 'Avg'
end avg_change,
lag(current_sales) over (partition by product_name order by order_year) as py_sales,
current_sales -lag(current_sales) over (partition by product_name order by order_year) as diff_py,
case when current_sales -lag(current_sales) over (partition by product_name order by order_year) > 0 then 'Increase'
	   when current_sales -lag(current_sales) over (partition by product_name order by order_year) < 0 then 'Decrease'
else 'No Change'
end py_change
from yearly_product_sales;
  
-- 10: Part To Whole Comparisons

with category_sales as
(select
category,
sum(sales_amount) as total_sales
from gold.fact_sales f
left join gold.dim_products p
on 		p.product_key=f.product_key                     -- Which categories contribute the most to overall sales?
group by category
)
select
category,
total_sales,
sum(total_sales) over() overall_sales,
round(total_sales/sum(total_sales) over()*100,2 )as percentage_as_total
from category_sales;

-- 11: Data Segmentation

(
with customer_spending as
(select
c.customer_key,
sum(f.sales_amount) as total_spending,
min(order_Date) as first_order,                                 -- Segment products into cost ranges and count how many products fall into each segment
max(order_Date) as last_order,
timestampdiff(month,min(order_Date) ,max(order_Date)) as lifespan
from gold.fact_sales f
left join gold.dim_customers c
on   f.customer_key=c.customer_key
group by c.customer_key)

select
customer_status,
count(customer_key) as total_customers
from(
select
customer_key,                                                          -- Group customers into three segments based on their spending behavior:
case when lifespan >= 12 and total_spending > 5000 then 'VIP'          -- VIP: Customers with at least 12 months of history and spending more than €5,000.
	   when lifespan >= 12 and total_spending <= 5000 then 'Regular'     -- Regular: Customers with at least 12 months of history but spending €5,000 or less.
else 'New'                                                             -- New: Customers with a lifespan less than 12 months.
end as customer_status                                                 -- Find the total number of customers by each group
from customer_spending) t
group by customer_status
order by total_customers desc
  
)
