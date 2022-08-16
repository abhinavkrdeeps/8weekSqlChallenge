-- link -> https://8weeksqlchallenge.com/case-study-1/

use prep;

create database sqlchallenge;

use sqlchallenge;
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date,product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
  
  
CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
select * from sales;

select * from menu;

select * from members;
  
--  What is the total amount each customer spent at the restaurant?

select customer_id,  sum(price) as total_amount_spent from sales inner join menu on sales.product_id=menu.product_id group by customer_id;

'A', '76'
'B', '74'
'C', '36'

-- How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date) as days_visited from sales group by customer_id;
# customer_id, days_visited
'A', '4'
'B', '6'
'C', '2'

-- What was the first item from the menu purchased by each customer?
with temp_cte as (
select customer_id,order_date,sales.product_id,product_name,
 dense_rank() over(partition by customer_id order by order_date) as rnk

 from sales inner join menu on sales.product_id=menu.product_id
 ) select customer_id,product_name from temp_cte where rnk=1;

# customer_id, product_name
A, sushi
A, curry
B, curry
C, ramen
C, ramen

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_name,num_time_puchased from(
select sales.product_id, product_name, count(1) as num_time_puchased from sales inner join menu on sales.product_id=menu.product_id
  group by sales.product_id,product_name ) temp order by num_time_puchased desc limit 1;

# product_name, num_time_puchased
'ramen', '8'


-- Which item was the most popular for each customer?
select * from sales;

with temp_cte as (
select customer_id,product_id , count(product_id) as cnt 
from sales group by customer_id, product_id order by customer_id
) , ranks as (
select * , dense_rank()over(partition by customer_id order by cnt desc) as rnk from temp_cte
)select customer_id, product_name from ranks inner join menu on ranks.product_id=menu.product_id where rnk=1 order by customer_id;


-- Which item was purchased first by the customer after they became a member?

with get_is_after_join as (
select sales.customer_id,order_date,product_id , join_date,
case when cast(order_date as date) > cast(join_date as date) then 1 else 0 end as is_after_join
from sales inner join members on sales.customer_id=members.customer_id
), get_ranks as ( select *, dense_rank() over(partition by customer_id order by order_date asc) as rnk from get_is_after_join where is_after_join=1) 
select customer_id,product_id,order_date,join_date from get_ranks where rnk=1;


-- Which item was purchased just before the customer became a member?
with get_is_before_joining as(
select sales.customer_id,order_date,product_id,join_date,
case when cast(order_date as date) < cast(join_date as date) then 1 else 0 end as is_before_joining
from sales inner join members on sales.customer_id=members.customer_id
) , create_ranks as (
select *, dense_rank() over(partition by customer_id order by order_date desc) as rnk from get_is_before_joining where is_before_joining=1
) select customer_id,product_id,order_date,join_date from create_ranks where rnk=1;

-- What is the total items and amount spent for each member before they became a member?
with find_non_members as (
select sales.customer_id,product_id,order_date,join_date,
case when cast(order_date as date) < cast(join_date as date) then 1 else 0 end as not_member
 from sales inner join members
on sales.customer_id = members.customer_id
), get_price as (
select find_non_members.customer_id,find_non_members.product_id, menu.product_name,menu.price,not_member from find_non_members inner join menu on find_non_members.product_id=menu.product_id where not_member=1
)select *, count(distinct product_id) as cnt, sum(price) as total_price from get_price group by customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier -
--  how many points would each customer have?
select sales.customer_id,
sum(case when product_name="sushi" then 2*10*price else 10*price end ) as total_points
from sales inner join menu on sales.product_id = menu.product_id group by customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
 -- not just sushi - how many points do customer A and B have at the end of January?
 
 with find_memberhip_date as (
 select sales.customer_id,product_id,
 case when cast(order_date as date) >= cast(join_date as date) then 1 else 0 end as is_member,
 order_date,join_date from sales inner join members on sales.customer_id = members.customer_id
 )
 select customer_id, order_date, extract(month from order_date) as months, sum(2*10*price) over(partition by customer_id, extract(month from order_date)) as points from find_memberhip_date  inner join menu where is_member=1;

















  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  