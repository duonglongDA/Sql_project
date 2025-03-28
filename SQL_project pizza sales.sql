--Retrieve the total number of orders placed.

select DISTINCT count(order_id) as Total_orders
from dbo.orders


--Calculate the total revenue generated from pizza sales.

Select round(sum(quantity*price),2) as Total_revenue
from dbo.order_details as a 
left join dbo.pizzas as b on a.pizza_id=b.pizza_id

-- Identify the highest-priced pizza.
select top 1 name,price
from dbo.pizzas as a 
left join dbo.pizza_types as b on a.pizza_type_id=b.pizza_type_id
order by price desc

--Identify the most common pizza size ordered.

select size, count(order_id) as Count_orderid

from dbo.order_details as a 
left join dbo.pizzas as b on a.pizza_id=b.pizza_id
group by size
order by count(order_id) desc


--List the top 5 most ordered pizza types along with their quantities.

select top 5 c.name, sum(quantity) as Quantity

from dbo.order_details as a 
left join dbo.pizzas as b on a.pizza_id=b.pizza_id
left join dbo.pizza_types as c on c.pizza_type_id=b.pizza_type_id
group by c.name
order by Quantity desc


-- Join the necessary tables to find the total quantity of each pizza category ordered.
select  c.category, sum(quantity) as Quantity

from dbo.order_details as a 
left join dbo.pizzas as b on a.pizza_id=b.pizza_id
left join dbo.pizza_types as c on c.pizza_type_id=b.pizza_type_id
group by c.category
order by Quantity desc

--Determine the distribution of orders by hour of the day.
select DATEPART(HOUR,order_time) as hourtime, count(order_id) as total_order_id
from dbo.orders
group by DATEPART(HOUR,order_time)
order by DATEPART(HOUR,order_time) asc

--Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) as count_name
from dbo.pizza_types
group by category


-- and calculate the average number of pizzas ordered per day.
select round(avg(total_quantity),2) as Avg_ordered_per_day
from(
SELECT order_date, sum(quantity) as total_quantity
from dbo.orders as a 
left join dbo.order_details as b on a.order_id=b.order_id
group by order_date) as order_quantity

--Group the orders by date
SELECT order_date, sum(quantity) as total_quantity
from dbo.orders as a 
left join dbo.order_details as b on a.order_id=b.order_id
group by order_date
order by order_date asc


--Determine the top 3 most ordered pizza types based on revenue.

select top 3  c.name, round(sum(quantity*price),2) as revenue
from dbo.order_details as a 
left join dbo.pizzas as b on a.pizza_id=b.pizza_id
left join dbo.pizza_types as c on c.pizza_type_id=b.pizza_type_id
group by  c.name
order by revenue desc


--Calculate the percentage contribution of each pizza type to total revenue.


select  c.category, round(sum(quantity*price),2) as revenue, round(round(sum(quantity*price),2)/ (
select   round(sum(quantity*price),2)*0.01
from dbo.order_details as a 
left join dbo.pizzas as b on a.pizza_id=b.pizza_id
left join dbo.pizza_types as c on c.pizza_type_id=b.pizza_type_id),2) as percentage_revenue

from dbo.order_details as a 
left join dbo.pizzas as b on a.pizza_id=b.pizza_id
left join dbo.pizza_types as c on c.pizza_type_id=b.pizza_type_id
group by  c.category
order by revenue desc



--Analyze the cumulative revenue generated over time.


select order_date,sum(revenue) over (order by order_date) as cumulative_revenue
from
(SELECT order_date,  round(sum(quantity*price),2) as revenue
from orders as a 
left join order_details as b on a.order_id=b.order_id
left join pizzas as c on c.pizza_id=b.pizza_id
group by order_date) as sales



--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name, revenue
from(
select category, name, revenue,
rank() over (PARTITION by category order by revenue desc) as rn
from
(
select category, c.name, round(sum(quantity*price),2) as revenue
FROM order_details as a 
left join pizzas as b on a.pizza_id=b.pizza_id
left join pizza_types as c on c.pizza_type_id=b.pizza_type_id
group by category, c.name) as sales) as b
where rn <=3;