drop table "sql_challenges"."plans";
CREATE TABLE "sql_challenges"."plans"( "plan_id" INTEGER NULL,"plan_name" VARCHAR NULL,"price" VARCHAR NULL ) ENCODE AUTO;

drop table "sql_challenges"."subscriptions";
CREATE TABLE "sql_challenges"."subscriptions"( "customer_id" VARCHAR NULL,"plan_id" VARCHAR NULL,"start_date" VARCHAR NULL ) ENCODE AUTO;

copy "sql_challenges"."plans"
from 's3://data-unprocessed/plans_data.csv'
CSV
delimiter ','
IGNOREHEADER 1
QUOTE '\''
iam_role 'arn:aws:iam::692192405321:role/redshift-s3-access'

select * from "sql_challenges"."plans";





copy "sql_challenges"."subscriptions"
from 's3://data-unprocessed/subscriptions.csv'
delimiter ','
IGNOREHEADER 1
iam_role 'arn:aws:iam::692192405321:role/redshift-s3-access'

select * from "sql_challenges"."subscriptions_raw";

select * from "sql_challenges"."plans";

drop table "sql_challenges"."subscriptions_raw";

create table "sql_challenges"."subscriptions_raw" as (
select replace(customer_id, '"', '') as customer_id,
replace(plan_id, '"', '') as plan_id,
replace(start_date, '"', '') as start_date
from "sql_challenges"."subscriptions");

select * from "sql_challenges"."subscriptions_raw";


select * from "sql_challenges"."plans";

select * from "sql_challenges"."subscriptions_raw";

-- How many customers has Foodie-Fi ever had?
select count(distinct customer_id) as num_customers from "sql_challenges"."subscriptions_raw";

-- What is the monthly distribution of trial plan start_date values for our dataset.
select customer_id, cast(plan_id as int) as plan_id,
start_date, cast(start_date as date) dt
from "sql_challenges"."subscriptions_raw" where cast(plan_id as int) = 0;

-- What plan start_date values occur after the year 2020 for our dataset? 
-- Show the breakdown by count of events for each plan_name

select 5/10;

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
with get_total_count as (
select cast(count(distinct customer_id) as decimal)as total_customer_cnt , 1 as join_col from "sql_challenges"."subscriptions_raw"
  )
,get_churned_count as (
select cast(count(customer_id) as decimal) as churned_customer_count, 1 as join_col
from "sql_challenges"."subscriptions_raw" where cast(plan_id as int)=4
)select total_customer_cnt,churned_customer_count, 
(churned_customer_count/total_customer_cnt)*100  as churned_percentage
from get_churned_count t1
inner join get_total_count t2 on t1.join_col = t2.join_col;

-- How many customers have churned straight after their initial free trial - 
-- what percentage is this rounded to the nearest whole number?
select * from "sql_challenges"."subscriptions_raw" order by cast(customer_id as int);











