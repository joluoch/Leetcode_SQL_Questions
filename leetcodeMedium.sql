-- movie rating 
(select name results
from Users
left join Movie_Rating
using (user_id)
group by user_id
order by count(rating) desc, name
limit 1)

union

(select title
from Movies
left join Movie_Rating
using(movie_id)
where left(created_at,7) = '2020-02'
group by movie_id
order by avg(rating) desc, title
limit 1)

--- Game Analysis 3 
select a1.player_id, a1.event_date, 
    sum(a2.games_played) as games_played_so_far
from Activity a1
inner join Activity a2
on a1.player_id = a2.player_id and a2.event_date <= a1.event_date
group by a1.event_date, a1.player_id

--- Game Anlysis 4 
select round(a_frac.playerCount / count(distinct a_full.player_id), 2) as fraction
from Activity a_full,
    (select count(distinct a1.player_id) as playerCount
    from Activity a1
    inner join
        (select player_id, min(event_date) as first_login
        from Activity 
        group by player_id) a2
    on a1.player_id = a2.player_id and datediff(a1.event_date, a2.first_login) = 1) a_frac
/*The third select statement gets all the first login dates. 
    The second select statement gets players who login the day after their first login dates. 
    The first select statement calculates the fraction.

*/

-- count studentnumber in department 
select dept_name, count(student_id) as student_number
from department
left outer join student 
on department.dept_id = student.dept_id
group by department.dept_name
order by student_number desc, department.dept_name

--- employee problem 3
select project_id, employee_id
from Project
join Employee
using (employee_id)
where (project_id, experience_years) in (
    select project_id, max(experience_years)
    from Project
    join Employee
    using (employee_id)
    group by project_id)

--- Article view 2 
/*Write an SQL query to find all the people who viewed more than one article on the same date, 
sorted in ascending order by their id.*/
select id 
from (select distinct viewer_id as id, 
            count(distinct article_id) as count_view
      from views 
      group by view_date, viewer_id) sub
where sub.count_view > 1
order by sub.id 

--- reported post 2 
/*Write an SQL query to find the average for daily percentage of posts that got removed after being reported as spam, 
rounded to 2 decimal places.*/
select round(avg(daily_count), 2) as average_daily_percent
from (select count(distinct b.post_id)/count(distinct a.post_id)*100 as daily_count
    from actions a
    left join removals b
    on a.post_id = b.post_id
    where extra = 'spam'
    group by action_date
    ) b


-- unpopular books
/*Write an SQL query that reports the books that have sold less than 10 copies in the last year, 
excluding books that have been available for less than 1 month from today. Assume today is 2019-06-23*/
select book_id, name 
from books
where book_id not in (
    select book_id 
    from orders 
    where (dispatch_date between date_sub('2019-06-23',interval 1 year) and '2019-06-23') 
    group by (book_id) 
    having sum(quantity) >= 10)
and 
    available_from < date_sub('2019-06-23', interval 1 month)

-- page recommendation
/*Write an SQL query to recommend pages to the user with user_id = 1 using the pages that your friends liked. 
It should not recommend pages you already liked.*/
select distinct l.page_id as recommended_page
from Likes l
left join Friendship f1
on f1.user2_id = l.user_id
left join Friendship f2
on f2.user1_id = l.user_id
where (f1.user1_id = 1 or f2.user2_id = 1) and 
    l.page_id not in 
        (select page_id 
         from Likes 
         where user_id = 1)

--most recent three orders 
select a.name as customer_name, b.customer_id, b.order_id, b.order_date
from customers a
join (
    select customer_id, order_id, order_date, 
        rank() over(partition by customer_id order by order_date desc) as ranking
    from orders
) b
on a.customer_id = b.customer_id
where ranking <= 3
order by a.name, b.customer_id, b.order_date desc
