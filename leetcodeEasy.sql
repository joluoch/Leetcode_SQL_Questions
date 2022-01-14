/*Case when and then
Often it's useful to look at a numerical field not as raw data, 
but instead as being in different categories or groups.

You can use CASE with WHEN, THEN, ELSE, and END to define a new grouping field.
*/
SELECT name, continent, code, surface_area,
    -- First case
    CASE WHEN surface_area > 2000000 THEN 'large'
        -- Second case
        WHEN surface_area >= 350000 THEN 'medium'
        -- Else clause + end
        ELSE 'small' END
        -- Alias name
        AS geosize_group
-- From table
FROM countries;

-- Player analysis 1 
-- get the first log in date for a user 
SELECT player_id , min(event_date) as first_login 
FROM activity 
GROUP BY player_id;

-- player analysis 2 
-- get the first device to 
SELECT player_id, device_id 
FROM activity
WHERE (player_id,event_date) IN 
(SELECT player_id , min(event_date) as first_login 
FROM activity 
GROUP BY player_id);

-- customer with largest order 
select customer_number from Orders group by customer_number order by count(order_number) desc LIMIT 1;

-- Write an SQL query to report all the consecutive available seats in the cinema.
/*To solve this problem, first, we need to do join the cinema table to itself using a self-join. 
And to find the consecutive seats we have to use abs(t1.seat_id - t2.seat_id) = 1 
because the value of the t1.seat_id will be one more or less than the value of the t2.seat_id and 
we also have to make sure that the seat is available by using another condition for joining the table as t1.free = 1 AND t2.free = 1.*/
SELECT DISTINCT t1.seat_id 
FROM Cinema AS t1 
JOIN Cinema AS t2 
ON abs(t1.seat_id - t2.seat_id) = 1 
AND t1.free = 1 AND t2.free = 1 
ORDER BY 1


/*
Write an SQL query to report the names of all the salespersons 
who did not have any orders related to the company with the name "RED".*/
select s.name
from salesperson s
where s.sales_id not in 
    (select o.sales_id
    from orders o
    left join company c on o.com_id = c.com_id
    where c.name = 'RED')

-- Triangle judgement problem
-- if the two short lines are greater than the larger number then it is a triangle
select *, 
    if(x+y>z and x+z>y and y+z>x, 'Yes', 'No') as triangle
from triangle

-- shortest distance in a line
select t1.x-t2.x as shortest 
from point as t1 
join point as t2 
where t1.x > t2.x
order by(t1.x - t2.x)
limit 1

--important 
/*Write a SQL query for a report that provides the pairs (actor_id, director_id) 
where the actor has cooperated with the director at least three times.*/
SELECT actor_id, director_id
FROM ActorDirectors
GROUP BY actor_id, director_id
HAVING COUNT(*) >=3

--product sales analysis 1 
Select p.product_name,s.year,s.price
from product as p join sales as s
on p.product_id = s.product_id

--- project employement 1 #important
/*Write an SQL query that reports the average experience years of all the employees for each project, rounded to 2 digits.*/
select p.project_id,round(sum(e.experience_years)/count(p.project_id), 2) as average_years
from Project p 
left join Employee e
on p.employee_id = e.employee_id
group by p.project_id

-- project employement 2 #important 
-- Write an SQL query that reports all the projects that have the most employees.
SELECT project_id 
FROM Project 
GROUP BY project_id
HAVING COUNT(*) = (
    SELECT COUNT(employee_id) AS cnt 
    FROM Project 
    GROUP BY project_id 
    ORDER BY cnt DESC 
    LIMIT 1);

--sales analysis 1


--sales analysis 2 
select distinct s.buyer_id
from Product p
join Sales s
on p.product_id=s.product_id
group by buyer_id
having sum(p.product_name='S8') > 0 and sum(p.product_name = 'iPhone') = 0


-- sales analysis 3 
SELECT s.product_id, p.product_name
FROM Sales as s
JOIN Product as p
ON s.product_id = p.product_id
GROUP BY s.product_id
HAVING MIN(s.sale_date) >= '2019-01-01' AND
       MAX(s.sale_date) <= '2019-03-31'

--reported posts #impottant 
select extra as report_reason, 
    count(distinct post_id) as report_count
from Actions
where action = 'report' and
    action_date = '2019-07-04' 
group by extra
order by report_reason

-- user activity in the past 30 days 1 #important 
select activity_date as day, count(distinct user_id) as active_users 
from Activity
where activity_date between date_add('2019-07-27', interval -29 day) and '2019-07-27'
group by  activity_date

-- article views 1 # important
select author_id as id
from views 
where author_id = viewer_id
group by id
order by id

-- immediate food delivery 1 
select round(100*d2.immediate_orders/count(d1.delivery_id), 2) as immediate_percentage
from Delivery d1,
    (select count(order_date) as immediate_orders
    from Delivery 
    where (order_date = customer_pref_delivery_date)) d2

-- student and examination #important 
select t.student_id, t.student_name, t.subject_name, 
    if(e.attended_exams is null, 0, e.attended_exams) as attended_exams
from
    (select *
    from Students
    cross join Subjects) t
left join 
    (select *, count(*) as attended_exams
    from Examinations
    group by student_id, subject_name) e
on t.student_id = e.student_id and t.subject_name = e.subject_name
order by student_id, subject_name

-- ads performance 
select ad_id,
    ifnull(round(sum(action ='Clicked')/sum(action !='ignored') *100,2),0) ctr
from ads
group by ad_id
order by ctr desc, ad_id

-- number of comments per post 
select s1.sub_id as post_id,
    count(distinct s2.sub_id) as number_of_comments
from Submissions s1
left join Submissions s2
on s2.parent_id = s1.sub_id
where s1.parent_id is null
group by s1.sub_id

-- not boring movie problem 
select *
from cinema
where mod(id, 2) = 1 and description != 'boring'
order by rating DESC

-- friendlymovie steamed last month 
select distinct title
from Content 
join TVProgram using(content_id)
where kids_content = 'Y' 
	and content_type = 'Movies' 
	and (month(program_date), year(program_date)) = (6, 2020)
