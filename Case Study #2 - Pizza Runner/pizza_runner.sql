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


 use sqlchallenge;

select * from runners;
select * from customer_orders;
select * from runner_orders order by runner_id;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;

-- pizza metrics
-- How many pizzas were ordered?  -- count(pizz_id)
select count(pizza_id) as total_pizza_ordered
from customer_orders;

-- How many successful orders were delivered by each runner?
with get_is_cancelled as (
select order_id,
runner_id,
case when cancellation="Restaurant Cancellation" then 1 
when cancellation="Customer Cancellation" then 1
else 0 end as is_cancelled
from runner_orders
) select 
runner_id, count(order_id) as ordered_delievered
from get_is_cancelled
where is_cancelled=0
group by runner_id ;

-- How many of each type of pizza was delivered?
with get_is_cancelled as (
select order_id,
runner_id,
case when cancellation="Restaurant Cancellation" then 1 
when cancellation="Customer Cancellation" then 1
else 0 end as is_cancelled
from runner_orders
), 
get_pizza_ids as (
select 
temp.order_id,
c_o.pizza_id
from get_is_cancelled temp
inner join 
customer_orders c_o
on temp.order_id = c_o.order_id
where is_cancelled=0
),
get_pizzas_del as (
select order_id,
ids.pizza_id,
pizza_name
from get_pizza_ids ids
inner join
pizza_names names1 on ids.pizza_id = names1.pizza_id
)select 
pizza_name,
count(pizza_name) as num_del
from get_pizzas_del 
group by pizza_name;

-- How many Vegetarian and Meatlovers were ordered by each customer?
with temp_cte as (
select 
customer_id,
count(order_id) over(partition by customer_id, pizza_name) as cnt,
pizza_name
from customer_orders co
inner join pizza_names pn
on co.pizza_id = pn.pizza_id
),
get_orders_count as (
select customer_id,
case when pizza_name = "Meatlovers" then cnt else 0 end as ml_ordered,
case when pizza_name = "Vegetarian" then cnt else 0 end as veg_ordered
from temp_cte
) select customer_id, 
max(ml_ordered) as ml_ordered,
max(veg_ordered) as veg_ordered
from get_orders_count
group by customer_id;

-- What was the maximum number of pizzas delivered in a single order?
select * from customer_orders;
select * from runner_orders;

with get_delievered_order_ids as 
(
select co.order_id, pizza_id,
 case 
 when cancellation="Restaurant Cancellation" then "cancelled" 
 when cancellation="Customer Cancellation" then "cancelled" 
 else "delieverd" end as fn_status
 from runner_orders ro
 inner join customer_orders co 
 on ro.order_id = co.order_id
), 
get_count_in_each_order as 
(
 select order_id, count(pizza_id) as cnt
 from get_delievered_order_ids where fn_status = "delieverd" group by order_id 
)
select cnt as max_num_pizza from get_count_in_each_order order by cnt desc limit 1;


-- For each customer, 
-- how many delivered pizzas had at least 1 change and how many had no changes?
select * from customer_orders;

with get_change_status as (
select customer_id, order_id,
case when (exclusions="" and extras="") then "unchanged" 
 when (exclusions=null and extras=null) then "unchanged" 
 when (exclusions="null" and extras="null") then "unchanged" 
else "changed" end as is_change
from customer_orders
),
filter_delievered_orders as (
select order_id,
case 
 when cancellation="Restaurant Cancellation" then "cancelled" 
 when cancellation="Customer Cancellation" then "cancelled" 
 else "delieverd" end as fn_status
 from runner_orders ro
), get_results as (
select cs.order_id,cs.customer_id,is_change
from get_change_status cs
 inner join filter_delievered_orders fo
 on cs.order_id = fo.order_id 
 where fo.fn_status="delieverd"
)
 select customer_id, count(order_id) as cnt, is_change from get_results group by customer_id, is_change;

-- How many pizzas were delivered that had both exclusions and extras?
create or replace view delieverd_orders as (
select order_id,
case 
 when cancellation="Restaurant Cancellation" then "cancelled" 
 when cancellation="Customer Cancellation" then "cancelled" 
 else "delieverd" end as fn_status
 from runner_orders ro
);

create or replace view extra_exclusion_info as
(
select order_id,customer_id,order_time,pizza_id,
case when exclusions = "" then 0 
when exclusions = "null" then 0 
when exclusions = null then 0 else 1 end as is_exclusion,

case when extras = "" then 0 
when extras = "null" then 0 
when extras is  NULL then 0 else 1 end as is_extras
 from customer_orders
);

select order_id,customer_id,pizza_id from (
select del.order_id,pizza_id,customer_id,is_extras,is_exclusion,
(is_extras+is_exclusion ) as sum_extra_exclusion
from extra_exclusion_info eei
inner join 
delieverd_orders del
on eei.order_id = del.order_id
where fn_status="delieverd"
) temp where sum_extra_exclusion=2;

-- What was the total volume of pizzas ordered for each hour of the day?
select order_time, hour_of_day, count(order_id) as vol_order from(
select order_id,
 extract(day from order_time) as day_order_time,
 extract(month from order_time) as month_order_time,
 extract(year from order_time) as year_order_time,order_time,
 extract(hour from order_time) as hour_of_day
 from customer_orders
)temp group by day_order_time,month_order_time,year_order_time,hour_of_day,order_time;

						-- . Runner and Customer Experience
                        
-- What was the average time in minutes it took for each runner to arrive
--  at the Pizza Runner HQ to pickup the order?


select runner_id, avg(diff) as avg_time_taken from(
select co.order_id, ro.runner_id, co.order_time,
ro.pickup_time, ifnull(timestampdiff(minute,order_time,pickup_time), 0) as diff
from runner_orders ro
inner join customer_orders co
on ro.order_id = co.order_id
) temp group by runner_id
;

-- Is there any relationship between the number of pizzas 
-- and how long the order takes to prepare?

select * from customer_orders;
select * from runner_orders;


select co.order_id, ro.runner_id, co.order_time,pizza_id,
ro.pickup_time, ifnull(timestampdiff(minute,order_time,pickup_time), 0) as prep_tim
from runner_orders ro
inner join customer_orders co
on ro.order_id = co.order_id;



-- Add a column to get delievery times
with get_duration_in_min as (
select order_id, pickup_time,
 case when REGEXP_REPLACE(duration, '[a-z A-Z]+', '') = "" then 0
 else REGEXP_REPLACE(duration, '[a-z A-Z]+', '') end
 as duration_in_min 
 from runner_orders
 ), get_del_time as 
 (
  select order_id,
  pickup_time, 
  cast(duration_in_min as signed) as duration_in_min_int,
  date_add(pickup_time, interval cast(duration_in_min as signed) minute ) as delievery_time
  from get_duration_in_min
 )select * from get_del_time;
 
 -- What was the difference between the longest and shortest delivery times for all orders?
with get_duration_in_min as (
select order_id, pickup_time,
 case when REGEXP_REPLACE(duration, '[a-z A-Z]+', '') = "" then 0
 else cast(REGEXP_REPLACE(duration, '[a-z A-Z]+', '') as signed )end
 as duration_in_min 
 from runner_orders
 )select max(duration_in_min) as mx,
 min(duration_in_min) as mn,
 max(duration_in_min) - min(duration_in_min) as diff
 from get_duration_in_min where duration_in_min > 0;

-- What was the average speed for each runner for each delivery 
-- and do you notice any trend for these values?

select * from runner_orders;

create or replace view clean_runner_orders as (
select order_id,runner_id,
pickup_time,
case when REGEXP_REPLACE(distance, '[a-zA-Z]+','')="" then 0
else cast(REGEXP_REPLACE(distance, '[a-zA-Z]+','') as signed) * 1000.0 end as distance_in_meter,
case when REGEXP_REPLACE(duration, '[a-zA-Z]+','')="" then 0
else cast(REGEXP_REPLACE(duration, '[a-zA-Z]+','') as signed) * 60.0 end as duration_in_seconds,

case 
 when cancellation="Restaurant Cancellation" then "cancelled" 
 when cancellation="Customer Cancellation" then "cancelled" 
 else "delieverd" end as fn_status
 from runner_orders ro
);

select runner_id,avg((distance_in_meter/duration_in_seconds)) as avg_speed 
from clean_runner_orders;

-- What is the successful delivery percentage for each runner?
with get_del_orders as (
select order_id, runner_id,
case 
 when cancellation="Restaurant Cancellation" then 1.0  
 when cancellation="Customer Cancellation" then 1.0
 else 0 end as is_cancelled,
case 
 when cancellation="Restaurant Cancellation" then 0
 when cancellation="Customer Cancellation" then 0
 else 1.0 end as is_delievered
 
 from runner_orders ro
)select runner_id, 
(sum(is_delievered)/sum(is_delievered+is_cancelled)) as successfull_del_percentage
 from get_del_orders group by runner_id;

				-- pricings and ratings

-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges 
-- for changes - 
-- how much money has Pizza Runner made so far if there are no delivery fees?


select * from customer_orders;

select sum(prize) as total_income from (
select *,
case when lower(pizza_name)="meatlovers" then 12
else 10 end as prize
from pizza_names ) pn
inner join customer_orders co
on co.pizza_id=pn.pizza_id;


-- What if there was an additional $1 charge for any pizza extras?
select * from extra_exclusion_info;

select * from customer_orders;

create or replace view get_num_extras_added as
(
select order_id,customer_id,pizza_id,
extras,
case when extras is null or extras = "" or extras = "null" then 0
else length(extras) - length(replace(extras, ',', '')) +1  end as extras_added
from customer_orders
);

select sum(prize) as total_income from (
select *,
case when lower(pizza_name)="meatlovers" then 12
else 10 end as prize
from pizza_names ) pn
inner join get_num_extras_added co
on co.pizza_id=pn.pizza_id;

select * from get_num_extras_added;

