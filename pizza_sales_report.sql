--- Basic:

-- 1.Retrieve the total number of orders placed.
SELECT 
    *
FROM
    orders;
    
SELECT 
    COUNT(*) AS total_no_orders
FROM
    orders;



-- 2.Calculate the total revenue generated from pizza sales.

SELECT 
    round(SUM(order_details.quantity * pizzas.price),2)AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;



-- 3.Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;



-- 4.Identify the most common pizza size ordered.

select 
     pizzas.size,
     count(order_details.order_details_id)as order_count
     from pizzas 
     join order_details
     on pizzas.pizza_id = order_details.pizza_id
     group by pizzas.size
     order by order_count desc limit 1;




-- 5.List the top 5 most ordered pizza types along with their quantities.
 
SELECT 
    SUM(order_details.quantity) AS most_ordered,
    pizza_types.name
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY most_ordered DESC
LIMIT 5;
 
 
 
 
 
 
 
 
-- Intermediate:

-- 1.Join the necessary tables to find the total quantity of each pizza category ordered.
  
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;
          






-- 2.Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time)as hour_time, COUNT(order_id) as distribution_of_orders
FROM
    orders
GROUP BY hour_time;



-- 3.Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, 
    COUNT(*) AS ditribution_of_pizzas
FROM
    pizza_types
GROUP BY category;

     




-- 4.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(total_quantity), 2) as average_pizza_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS total_quantity
    FROM
        orders
    JOIN order_details ON order_details.order_id = orders.order_id
    GROUP BY orders.order_date) AS order_quantity;





-- 5.Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price),
            0) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY total_revenue DESC
LIMIT 3;



-- Advanced:

-- 1.Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    concat(ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,2),"%") AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC
LIMIT 3;



-- 2.Analyze the cumulative revenue generated over time.
 
 select order_date,
 round(sum(revenue) over(order by order_date),2) as cum_revenue
 from
  (select orders.order_date,
 round(sum(order_details.quantity * pizzas.price),2)as revenue
    from order_details 
         join pizzas 
             on order_details.pizza_id = pizzas.pizza_id
		join orders 
            on orders.order_id = order_details.order_id
         group by orders.order_date) as sales;




-- 3.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,revenue from
   (select category,name,revenue,
      rank() over(partition by category order by revenue desc) as rn
	from 
      (select pizza_types.category , pizza_types.name,
      sum((order_details.quantity) * pizzas.price) as revenue
      from pizza_types join pizzas
      on pizza_types.pizza_type_id=pizzas.pizza_type_id
       join order_details
       on order_details.pizza_id = pizzas.pizza_id
       group by pizza_types.category, pizza_types.name ) as a)as b
       where rn <=3
       order by revenue desc limit 3;
