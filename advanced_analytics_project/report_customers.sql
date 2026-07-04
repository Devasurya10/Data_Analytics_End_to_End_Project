create view gold.report_customers as
with base_query as
(select 
f.order_number,
f.product_key,
f.order_Date,
f.sales_amount,
f.sales_quantity,
c.customer_key,
c.customer_number,
concat(c.first_name, ' ',c.last_name) as customer_name,
timestampdiff(year,c.birthdate, current_date) as age
from gold.fact_sales f
left join gold.dim_customers c
on 	c.customer_key = f.customer_key
where order_Date is not null)

, customer_aggregation as 
(select
customer_key,
customer_number,
customer_name,
age,
count(distinct order_number) as total_orders,
sum(sales_amount) as total_sales,
sum(sales_quantity) as total_quantity,
count(distinct product_key) as total_products,
max(order_date) as last_order_date,
timestampdiff(month,min(order_Date) ,max(order_Date)) as lifespan
from base_query
group by
	customer_key,
    customer_number,
    customer_name,
    age
)

select 
customer_key,
customer_number,
customer_name,
age,
case when age <20 then 'Under 20'
	when age between 20 and 29 then '20-29'
    when age between 30 and 39 then '30-39'
    when age between 40 and 49 then '40-49'
    else'50 and Above'
end age_group,
case when lifespan >= 12 and total_sales > 5000 then 'VIP'
	 when lifespan >= 12 and total_sales <= 5000 then 'Regular'
     else 'New'
end as customer_status,
last_order_date,
timestampdiff(month, last_order_date,current_date) as recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
case when total_sales = 0 then 0
	 ELSE total_sales / total_orders
end as avg_order_value,
case when lifespan = 0 then total_sales
     else total_sales / lifespan
end as avg_monthly_spend
from customer_aggregation
