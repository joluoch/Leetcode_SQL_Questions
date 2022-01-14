--second most recent assctivity 
/*Write an SQL query to show the second most recent activity of each user.

If the user only has one activity, return that one.

A user can’t perform more than one activity at the same time. Return the result table in any order.*/
select distinct username, activity, startDate, endDate
from
    (select u.*,
           rank() over (partition by username order by startDate desc) as rnk,
           count(activity) over (partition by username) as num
    from UserActivity u) t
where (num <> 1 and rnk = 2) or (num = 1 and rnk = 1)



--game analysis 5 
select t1.install_date as install_dt, count(t1.install_date) as installs,
    round(count(t2.event_date) / count(*), 2) as Day1_retention
from (
    select player_id, min(event_date) as install_date
    from Activity
    group by 1
) t1
left join Activity t2 
on date_add(t1.install_date, interval 1 day) = t2.event_date
    and t1.player_id = t2.player_id
group by 1
order by 1

/*We define the install date of a player to be the first login day of that player.

We also define day 1 retention of some date X to be the number of players whose install date is X and they logged back in on the day right after X, divided by the number of players whose install date is X, rounded to 2 decimal places.

Write an SQL query that reports for each install date, the number of players that installed the game on that day and the day 1 retention.*/

