-- Q1 Write an SQL query to report the managers with at least five direct reports.

SELECT Name FROM q1 
WHERE Id IN 
(SELECT ManagerId FROM q1
GROUP BY ManagerId
HAVING count(Id) >= 5);

-- Q2 Write an SQL query to report the nth highest salary from the Employee table. If there is no nth highest salary, the query should report null.

select * from ((select * from q2 
ORDER BY salary DESC limit 2 ) AS T) 
ORDER BY T.salary ASC limit 1;

-- Q3 Write an SQL query to find the people who have the most friends and the most friends number

select id, count(*) as num from (
    select requester_id as id from q3
    union all
    select accepter_id from q3
) as f_cnt
group by id
order by num desc limit 1;

-- Q4 Write an SQL query to swap the seat id of every two consecutive students. If the number of students is odd, the id of the last student is not swapped.

SELECT ( CASE
            WHEN id%2 != 0 AND id != counts THEN id+1  -- for odd ids
            WHEN id%2 != 0 AND id = counts THEN id	-- special case for last seat
            ELSE id-1	-- For even ids
        END) AS id, name
FROM q4, (select count(*) as counts from q4) 
AS seat_counts
ORDER BY id ASC;


-- Q5 Write an SQL query to report the customer ids from the Customer table that bought all the products in the Product table

SELECT
    customer_id
FROM q5_customer
GROUP BY customer_id
HAVING COUNT( DISTINCT product_key) = (SELECT COUNT(*) FROM q5_product);



-- Q6 Write an SQL query to find for each user, the join date and the number of orders they made as a buyer in 2019.

select user_id as buyer_id, join_date, 
    sum(case when order_id is not null then 1 else 0 end) as orders_in_2019
from q6_users
left join q6_orders on q6_users.user_id = q6_orders.buyer_id 
and year(order_date) = 2019
group by user_id, join_date
order by buyer_id;


-- Q7 Write an SQL query to reports for every date within at most 90 days from today, the number of users that logged in for the first time on that date. Assume today is 2019-06-30.

SELECT login_date, COUNT(user_id) user_count
FROM 
    (SELECT user_id,activity_date as login_date
    FROM q7
    WHERE activity='login'
    GROUP BY user_id) as t
WHERE DATEDIFF('2019-06-30', login_date) <= 90
GROUP BY login_date;

-- Q8 Write an SQL query to find the prices of all products on 2019-08-16. Assume the price of all products before any change is 10.

select * from (
    select product_id, new_price as price from q8
        where (product_id, change_date) in (
            select product_id, max(change_date) from q8
                where change_date <= '2019-08-16'
                group by product_id
        )
    union
        select distinct product_id, 10 as price from q8
            where product_id not in (
                select product_id from q8
                    where change_date <= '2019-08-16'
            )
    ) union_result;


-- Q9 Write an SQL query to find for each month and country: the number of approved transactions and their total amount, the number of chargebacks, and their total amount.


select month, country,
    sum(case when type='approved' then 1 else 0 end) as approved_count,
    sum(case when type='approved' then amount else 0 end) as approved_amount,
    sum(case when type='chargeback' then 1 else 0 end) as chargeback_count,
    sum(case when type='chargeback' then amount else 0 end) as chargeback_amount
from (
    (
    select left(t.trans_date, 7) as month, t.country, amount,'approved' as type
    from q9_transaction as t
    where state='approved'
    ) 
    union all (
    select left(c.trans_date, 7) as month, t.country, amount,'chargeback' as type
    from q9_transaction as t join q9_chargeback as c
    on t.id = c.trans_id
    )
) as tt
group by tt.month, tt.country;


-- Q 10  Write an SQL query that selects the team_id, team_name and num_points of each team in the tournament after all described matches.


select q10_teams.team_id, q10_teams.team_name, 
    sum(case when team_id=host_team and host_goals>guest_goals then 3 else 0 end) +
    sum(case when team_id=host_team and host_goals=guest_goals then 1 else 0 end) +
    sum(case when team_id=guest_team and host_goals<guest_goals then 3 else 0 end) +
    sum(case when team_id=guest_team and host_goals=guest_goals then 1 else 0 end) as num_points
from q10_teams left join q10_matches
on q10_teams.team_id = q10_matches.host_team or q10_teams.team_id = q10_matches.guest_team
group by q10_teams.team_id
order by num_points desc, q10_teams.team_id asc;