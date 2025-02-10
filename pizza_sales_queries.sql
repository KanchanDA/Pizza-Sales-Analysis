SELECT count(*)
  FROM [Pizza hut].[dbo].[order_details]


-- 1) Retrieve the total number of order placed
SELECT count(*) as total_orders
  FROM [Pizza hut].[dbo].[orders];

-- 2) Calculate the total revenue generated from pizza sales.
select 
round(sum([order_details].quantity*[pizzas].price),2) as total_revenue
from [order_details] 
join [pizzas] on [order_details].pizza_id = [pizzas].[pizza_id];

-- 3) Identify the highest price pizza

select top 1 [pizza_types].[name], round(pizzas.price,2) as price
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc;

-- 4) Identify the most commo pizza size ordered

select top 1 pizzas.size, count(order_details.order_details_id) as order_count
from pizzas 
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by order_count desc;


-- 5) List the top 5 most ordered pizza types along with their types
select top 5 pizza_types.name, sum(order_details.quantity) as quantity
from pizza_types 
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by quantity desc;


-- 6) Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, sum(order_details.quantity) as quantity
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by quantity desc;


--Intermediate
-- 7) Determine the distribution of orders by hour of the day
SELECT DATEPART(HOUR, [orders].[time]) AS order_hour, 
       COUNT(order_id) AS order_count
FROM [orders]
GROUP BY DATEPART(HOUR, [orders].[time])
ORDER BY order_hour;  

-- 8) Join the relevant table to find the category wise distribution of pizzas
select category, count(name) 
from pizza_types
group by category;

-- 9) Group the orders by date and calculate the average number of pizzas ordered per day
select round(avg(quantity),0)
from
(select orders.[date], sum(order_details.quantity) as quantity
from orders
join order_details on orders.order_id = order_details.order_id
group by orders.[date]) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
select  top 3 pizza_types.[name],
round(sum(order_details.quantity*pizzas.price),2) as revenue
from pizza_types 
join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.[name]
order by revenue desc;

-- calculate the percentage contribution of each pizza type to total revenue
select pizza_types.category,
ROUND(sum(order_details.quantity*pizzas.price)/
(select round(sum(order_details.quantity*pizzas.price),2) as total_sales
from order_details
join
pizzas on pizzas.pizza_id = order_details.pizza_id)*100,2) as revenue
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by revenue desc;


-- Analyze the cumulative revenue generated over time
select [date],
SUM(revenue) over(order by [date]) as cum_revenue
from
(select orders.[date],
sum(order_details.quantity*pizzas.price) as revenue
from order_details 
join pizzas on order_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_details.order_id
group by orders.[date]) as sales;


-- Determine the top 3 most ordered pizza type based on revenue for each category
select category, [name] , revenue from
(select category,[name] , revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types 
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category,pizza_types.[name]) as a) as b
where rn<=3;