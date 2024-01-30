create database project3;
show databases;
use project3;
create table job_data(ds date,
job_id int not null,
actor_id int not null,
`event` varchar(15) not null,
`language` varchar(15) not null,
time_spent int not null,
org char(2) not null);
insert into job_data (ds, job_id, actor_id, `event`, `language`, time_spent, org)
values('2020-11-30', 21, 1001, 'skip', 'English', 15, 'A'),
('2020-11-30', 22, 1006, 'transfer', 'Arabic', 25, 'B'),
('2020-11-29', 23, 1003, 'decision', 'Persian', 20, 'C'),
('2020-11-28', 23, 1005, 'transfer', 'Persian', 22, 'D'),
('2020-11-28', 25, 1002, 'decision', 'Hindi', 11, 'B'),
('2020-11-27', 11, 1007, 'decision', 'French', 104, 'D'),
('2020-11-26', 23, 1004, 'skip', 'Persian', 56, 'A'),
('2020-11-25', 20, 1003, 'transfer', 'Italian', 45, 'C');

select * from job_data;

/* Task 1:  Write an SQL query to calculate the number of jobs reviewed per hour for each day in November 2020.*/
select ds as date, 
round((count(job_id)/sum(time_spent))*3600) as "number of jobs reviewd per hour per day" from job_data 
where ds between "2020-11-01" and "2020-11-30" group by ds;

/* Task 2:  Write an SQL query to calculate the 7-day rolling average of throughput.*/
select round((count(event)/sum(time_spent)),2) as weekly_throughput 
from job_data;
#calculate daily metric throughput
select ds as date, round((count(event)/sum(time_spent)),2) as daily_metric 
from job_data group by date;


     /* Task 3: Write an SQL query to calculate the percentage share of each language over the last 30 days.*/
     select language, round(((count(language)/8)*100),2) as share_of_languages 
     from job_data group by language;

/* Task 4: Write an SQL query to display duplicate rows from the job_data table.*/
select * from 
(select *, row_number()over(partition by job_id) as rownum
from job_data)a 
where rownum>1;


/* Task 5: Write an SQL query to calculate the weekly user engagement.*/
select * from events_table;
select extract(week from occurred_at) as weeks, 
count(distinct user_id) as no_of_users from events_table 
where event_type="engagement"
group by weeks order by weeks;



/* Task 6: Write an SQL query to calculate the user growth for the product.*/
select week_num, year_num,
sum(active_users) over (order by week_num, year_num 
rows between unbounded preceding and current row) as cumulative_sum
from (
select extract(week from activated_at) as week_num,
extract(year from activated_at) as year_num,
count(distinct user_id) as active_users from users_table
where state= "active"
group by year_num, week_num
order by year_num, week_num) as alias;




/* Task 7:  Write an SQL query to calculate the weekly retention of users based on their sign-up cohort.*/
select * from events_table;
select extract(week from occurred_at) as weeks, 
count(distinct user_id) as no_of_users from events_table
where event_type="signup_flow" and event_name="complete_signup" 
group by weeks order by weeks;




/* Task 8: Write an SQL query to calculate the weekly engagement per device.*/
select * from events_table;
select device, extract(week from occurred_at) as weeks, 
count(distinct user_id) as no_of_users from events_table 
where event_type="engagement"
group by device, weeks order by weeks; 




/* Task 9: Write an SQL query to calculate the email engagement metrics.*/
select * from email_events_table;
select count(action) as action_count, action from email_events_table group by action;
select 
(sum(case when 
email_category="email_opened" then 1 else 0 end)/sum(case when email_category="email_sent" then 1 else 0 end))*100 as open_rate,
(sum(case when 
email_category="email_clickthrough" then 1 else 0 end)/sum(case when email_category="email_sent" then 1 else 0 end))*100 as click_rate
from (
	select *, 
	case 
		when action in ("sent_weekly_digest", "sent_reengagement_email") then ("email_sent")
		when action in ("email_open") then ("email_opened")
		when action in ("email_clickthrough") then ("email_clickthrough")
	end as email_category
	from email_events_table) as alias;


