/* Create Database */
CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
 /* Case Study Questions */
 /* 
A. Pizza Metrics
1.How many pizzas were ordered?
2.How many unique customer orders were made?
3.How many successful orders were delivered by each runner?
4.How many of each type of pizza was delivered?
5.How many Vegetarian and Meatlovers were ordered by each customer?
6.What was the maximum number of pizzas delivered in a single order?
7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8.How many pizzas were delivered that had both exclusions and extras?
9.What was the total volume of pizzas ordered for each hour of the day?
10.What was the volume of orders for each day of the week?
*/

/* 1.How many pizzas were ordered? */
SELECT COUNT(*) AS total_pizzas
FROM customer_orders;

/* 2.How many unique customer orders were made? */
SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders;

/* 3.How many successful orders were delivered by each runner? */ 
SELECT runner_id, COUNT(*) AS successful_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

/* 4.How many of each type of pizza was delivered? */
SELECT pn.pizza_name, COUNT(*) AS total_delivered
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY pn.pizza_name;

/* 5.How many Vegetarian and Meatlovers were ordered by each customer? */
SELECT co.customer_id, pn.pizza_name, COUNT(*) AS total_ordered
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY co.customer_id, pn.pizza_name;

/* 6.What was the maximum number of pizzas delivered in a single order? */
SELECT MAX(order_count) AS max_pizzas
FROM (
  SELECT order_id, COUNT(*) AS order_count
  FROM customer_orders
  GROUP BY order_id
) AS max_pizzas_subquery;

/* 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes? */
SELECT co.customer_id,
       SUM(CASE WHEN co.exclusions <> '' OR co.extras <> '' THEN 1 ELSE 0 END) AS pizzas_with_changes,
       SUM(CASE WHEN co.exclusions = '' AND co.extras = '' THEN 1 ELSE 0 END) AS pizzas_without_changes
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id;

/* 8.How many pizzas were delivered that had both exclusions and extras? */
SELECT COUNT(*) AS pizzas_with_exclusions_and_extras
FROM customer_orders
WHERE exclusions <> '' AND extras <> '';

/* 9.What was the total volume of pizzas ordered for each hour of the day? */
SELECT DATE_TRUNC('hour', order_time) AS hour_of_day, COUNT(*) AS total_pizzas
FROM customer_orders
GROUP BY hour_of_day
ORDER BY hour_of_day;

/* 10.What was the volume of orders for each day of the week? */
SELECT EXTRACT(DOW FROM order_time) AS day_of_week, COUNT(*) AS total_orders
FROM customer_orders
GROUP BY day_of_week
ORDER BY day_of_week;

/* 
B. Runner and Customer Experience
1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
4.What was the average distance travelled for each customer?
5.What was the difference between the longest and shortest delivery times for all orders?
6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
7.What is the successful delivery percentage for each runner?
*/

/* 1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) */
SELECT
    DATE_TRUNC('week', registration_date) AS week_start,
    COUNT(DISTINCT runner_id) AS num_runners
FROM
    runners
GROUP BY
    week_start
ORDER BY
    week_start;
	
/* 2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? */
SELECT
    runner_id,
    AVG(EXTRACT(EPOCH FROM pickup_time::timestamp - co.order_time::timestamp) / 60) AS avg_time_minutes
FROM
    runner_orders ro
    JOIN customer_orders co ON ro.order_id = co.order_id
WHERE
    pickup_time IS NOT NULL
    AND co.order_time IS NOT NULL
    AND pickup_time <> 'null'
GROUP BY
    runner_id;
	
/* 3.Is there any relationship between the number of pizzas and how long the order takes to prepare? */
SELECT co.order_id, COUNT(pt.topping_id) AS total_toppings, ro.duration
FROM customer_orders co
JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON pt.topping_id = ANY(string_to_array(pr.toppings, ', ')::integer[])
JOIN runner_orders ro ON co.order_id = ro.order_id
GROUP BY co.order_id, ro.duration
ORDER BY total_toppings;
	
/* 4.What was the average distance travelled for each customer? */
SELECT
  co."customer_id",
  AVG(CAST(NULLIF(COALESCE(regexp_replace(ro."distance", '[^\d.]', '', 'g'), ''), '') AS NUMERIC)) AS average_distance
FROM
  customer_orders co
JOIN
  runner_orders ro ON co."order_id" = ro."order_id"
GROUP BY
  co."customer_id";

/* 5.What was the difference between the longest and shortest delivery times for all orders? */
SELECT
  MAX(CAST(duration AS INTERVAL)) - MIN(CAST(duration AS INTERVAL)) AS delivery_time_difference
FROM
  runner_orders
WHERE
  duration IS NOT NULL
  AND duration <> 'null';
  
/* 6.What was the average speed for each runner for each delivery and do you notice any trend for these values? */
SELECT
  r.runner_id,
  ro.order_id,
  ro.duration,
  ro.distance,
  CASE
    WHEN ro.duration ~ '^[0-9]+(\.[0-9]+)?$' AND ro.distance ~ '^[0-9]+(\.[0-9]+)?$' THEN CAST(ro.distance AS FLOAT) / CAST(ro.duration AS FLOAT)
    ELSE NULL
  END AS average_speed
FROM
  runners r
JOIN
  runner_orders ro ON r.runner_id = ro.runner_id;
  
/* 7.What is the successful delivery percentage for each runner? */ 
SELECT
  r.runner_id,
  COUNT(ro.order_id) AS total_deliveries,
  COUNT(ro.cancellation) FILTER (WHERE ro.cancellation IS NULL) AS successful_deliveries,
  CASE
    WHEN COUNT(ro.order_id) = 0 THEN '0%'
    ELSE (CAST(COUNT(ro.cancellation) FILTER (WHERE ro.cancellation IS NULL)::FLOAT / COUNT(ro.order_id)::FLOAT * 100 AS DECIMAL(5, 2)) || '%')
  END AS successful_delivery_percentage
FROM
  runners r
LEFT JOIN
  runner_orders ro ON r.runner_id = ro.runner_id
GROUP BY
  r.runner_id;
  
/* 
C. Ingredient Optimisation
1.What are the standard ingredients for each pizza?
2.What was the most commonly added extra?
3.What was the most common exclusion?
4.Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
*/

/* 1.What are the standard ingredients for each pizza? */
SELECT pn.pizza_name, pt.topping_name
FROM pizza_names pn
JOIN pizza_recipes pr ON pn.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON CAST(pt.topping_id AS TEXT) = ANY(string_to_array(pr.toppings, ', '))
ORDER BY pn.pizza_name, pt.topping_name;

/* 2.What was the most commonly added extra? */
SELECT
    extras,
    COUNT(*) AS extra_count
FROM
    customer_orders
WHERE
    extras IS NOT NULL
GROUP BY
    extras
ORDER BY
    extra_count DESC
LIMIT 1;

/* 3.What was the most common exclusion? */ 
SELECT
    exclusions,
    COUNT(*) AS exclusion_count
FROM
    customer_orders
WHERE
    exclusions IS NOT NULL
GROUP BY
    exclusions
ORDER BY
    exclusion_count DESC
LIMIT 1;

/* 4.Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers */
SELECT
  co.order_id,
  CONCAT(
    pn.pizza_name,
    CASE
      WHEN co.exclusions <> '' THEN ' - Exclude ' || pt1.topping_name
      ELSE ''
    END,
    CASE
      WHEN co.extras <> '' THEN ' - Extra ' || pt2.topping_name
      ELSE ''
    END
  ) AS order_item
FROM
  customer_orders co
JOIN
  pizza_names pn ON co.pizza_id = pn.pizza_id
LEFT JOIN
  pizza_toppings pt1 ON co.exclusions = pt1.topping_id::text
LEFT JOIN
  pizza_toppings pt2 ON co.extras = pt2.topping_id::text;

/* 5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" */
SELECT
    pn.pizza_name,
    CONCAT_WS(', ',
        CASE WHEN pr.toppings LIKE '%1%' THEN '2x Bacon' ELSE NULL END,
        CASE WHEN pr.toppings LIKE '%2%' THEN '2x BBQ Sauce' ELSE NULL END,
        CASE WHEN pr.toppings LIKE '%3%' THEN 'Beef' ELSE NULL END,
        CASE WHEN pr.toppings LIKE '%4%' THEN 'Cheese' ELSE NULL END,
        CASE WHEN pr.toppings LIKE '%5%' THEN 'Chicken' ELSE NULL END,
        CASE WHEN pr.toppings LIKE '%6%' THEN '2x Mushrooms' ELSE NULL END,
        CASE WHEN pr.toppings LIKE '%7%' THEN 'Onions' ELSE NULL END,
        CASE WHEN pr.toppings LIKE '%8%' THEN 'Pepperoni' ELSE NULL END,
        CASE WHEN pr.toppings LIKE '%9%' THEN 'Peppers' ELSE NULL END,
        CASE WHEN pr.toppings LIKE '%10%' THEN 'Salami' ELSE NULL END,
        CASE WHEN pr.toppings LIKE '%11%' THEN 'Tomatoes' ELSE NULL END,
        CASE WHEN pr.toppings LIKE '%12%' THEN 'Tomato Sauce' ELSE NULL END
    ) AS ingredient_list
FROM
    customer_orders co
    JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
    JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
ORDER BY
    pn.pizza_name;
	
/* 6.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first? */ 
SELECT
    pt.topping_name,
    COUNT(*) AS total_quantity
FROM
    pizza_recipes pr
    JOIN pizza_toppings pt ON pt.topping_id = ANY(string_to_array(pr.toppings, ', ')::int[])
    JOIN customer_orders co ON co.pizza_id = pr.pizza_id
    JOIN runner_orders ro ON ro.order_id = co.order_id
WHERE
    ro.cancellation IS NULL
GROUP BY
    pt.topping_name
ORDER BY
    total_quantity DESC;
	
/* 
D. Pricing and Ratings
1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2.What if there was an additional $1 charge for any pizza extras?
- Add cheese is $1 extra
3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
- customer_id
- order_id
- runner_id
- rating
- order_time
- pickup_time
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
*/

/* 1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees? */
SELECT SUM(
    CASE
        WHEN pn."pizza_name" = 'Meatlovers' THEN 12
        WHEN pn."pizza_name" = 'Vegetarian' THEN 10
        ELSE 0
    END
) AS total_revenue
FROM customer_orders co
JOIN pizza_names pn ON co."pizza_id" = pn."pizza_id";

/* 2.What if there was an additional $1 charge for any pizza extras? */
SELECT SUM(
    CASE
        WHEN pn."pizza_name" = 'Meatlovers' THEN 12
        WHEN pn."pizza_name" = 'Vegetarian' THEN 10
        ELSE 0
    END
    + (LENGTH(co."extras") - LENGTH(REPLACE(co."extras", ',', ''))) * 1
) AS total_revenue
FROM customer_orders co
JOIN pizza_names pn ON co."pizza_id" = pn."pizza_id";

/* 3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5. */
CREATE TABLE customer_ratings (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "runner_id" INTEGER,
  "rating" INTEGER,
  "order_time" TIMESTAMP,
  "pickup_time" TIMESTAMP,
  "time_between_order_pickup" INTERVAL,
  "delivery_duration" INTERVAL,
  "average_speed" FLOAT,
  "total_pizzas" INTEGER
);

INSERT INTO customer_ratings
  ("order_id", "customer_id", "runner_id", "rating", "order_time", "pickup_time", "time_between_order_pickup", "delivery_duration", "average_speed", "total_pizzas")
VALUES
  (1, 101, 1, 4, '2020-01-01 18:05:02', '2020-01-01 18:15:34', INTERVAL '10 minutes', INTERVAL '32 minutes', 20.0, 1),
  (2, 101, 1, 5, '2020-01-01 19:00:52', '2020-01-01 19:10:54', INTERVAL '10 minutes', INTERVAL '27 minutes', 26.67, 1),
  (3, 102, 1, 3, '2020-01-02 23:51:23', '2020-01-03 00:12:37', INTERVAL '21 minutes', INTERVAL '20 minutes', 40.2, 2),
  (4, 103, 2, 4, '2020-01-04 13:23:46', '2020-01-04 13:53:03', INTERVAL '29 minutes', INTERVAL '40 minutes', 35.1, 3),
  (5, 104, 3, 5, '2020-01-08 21:00:29', '2020-01-08 21:10:57', INTERVAL '10 minutes', INTERVAL '15 minutes', 40.0, 1),
  (7, 105, 2, 2, '2020-01-08 21:20:29', '2020-01-08 21:30:45', INTERVAL '10 minutes', INTERVAL '25 minutes', 24.0, 1),
  (10, 104, 1, 5, '2020-01-11 18:34:49', '2020-01-11 18:50:20', INTERVAL '15 minutes', INTERVAL '10 minutes', 60.0, 2);
  
/* 4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
- customer_id
- order_id
- runner_id
- rating
- order_time
- pickup_time
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas */

SELECT cr.customer_id, cr.order_id, cr.runner_id, cr.rating, co.order_time, ro.pickup_time,
       cr.time_between_order_pickup, cr.delivery_duration, cr.average_speed, cr.total_pizzas
FROM customer_ratings cr
JOIN customer_orders co ON cr.order_id = co.order_id
JOIN runner_orders ro ON cr.order_id = ro.order_id;

/* 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries? */
SELECT
    SUM(CASE
        WHEN pn.pizza_name = 'Meatlovers' THEN 12
        WHEN pn.pizza_name = 'Vegetarian' THEN 10
        ELSE 0
    END) AS total_pizza_cost
FROM
    customer_orders co
    JOIN pizza_names pn ON co.pizza_id = pn.pizza_id;
	
/* 
E. Bonus Questions
If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
*/
-- Add information about new pizzas to the pizza_names table
INSERT INTO pizza_names ("pizza_id", "pizza_name")
VALUES (3, 'Supreme');

-- Add information about new pizza recipes to the pizza_recipes table
INSERT INTO pizza_recipes ("pizza_id", "toppings")
VALUES(3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');

-- Add information about new pizza toppings to the pizza_toppings table
INSERT INTO pizza_toppings ("topping_id", "topping_name")
VALUES
   (13, 'Topping 13'),
   (14, 'Topping 14'),
   (15, 'Topping 15');

-- Update the new pizza recipe in the pizza_recipes table with new toppings
UPDATE pizza_recipes
SET toppings = toppings || ', 13, 14, 15'
WHERE pizza_id = 3;