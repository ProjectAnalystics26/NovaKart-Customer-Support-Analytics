Select * from SLA_Master_Cleaned
Select * from Tickets_Cleaned
Select * from Agent_Master_Cleaned


--“How many customer support tickets did we receive during the six-month analysis period?”
SELECT COUNT(*) AS Total_Tickets
FROM Tickets_Cleaned;

--How many tickets are there for each Ticket_Status — Closed, Open and Pending?
select ticket_status, count(ticket_status) as Total_Count
from tickets_Cleaned
group by ticket_status

-- How many tickets are there by Priority? and Which priority has the highest number of tickets?
SELECT Top 1
    Priority,
    COUNT(*) AS Total_Count
FROM Tickets_Cleaned
GROUP BY Priority
order by Total_count desc

--Which Category has the highest number of tickets?
SELECT TOP 1 WITH TIES
    Category,
    COUNT(*) AS Total_Count
FROM Tickets_Cleaned
GROUP BY Category
ORDER BY Total_Count DESC;

--Which Channel receives the most customer tickets?
select Top 1 with ties
channel,
count(*) as Total_count
from tickets_cleaned
group by channel
order by Total_count desc

--What is the average resolution time for closed tickets?
SELECT 
    ROUND(AVG(Resolution_Hours), 2) AS Avg_Resolution_Hours
FROM Tickets_Cleaned
WHERE Ticket_Status = 'Closed';

/* What is the average resolution time for each Category, considering only Closed tickets,
sorted from highest average resolution time to lowest? */
select category, round(avg(resolution_hours), 2) as AVG_resolution_hours
from tickets_cleaned
where ticket_status = 'Closed'
group by category
order by AVG_resolution_hours desc

--Which 3 categories have the highest average resolution time among Closed tickets?

select Top 3 with ties
    Category,
    ROUND(AVG(Resolution_Hours), 2) AS AVG_Resolution_Hours
FROM Tickets_Cleaned
WHERE Ticket_Status = 'Closed'
GROUP BY Category
ORDER BY AVG_Resolution_Hours DESC;

-- What is the average CSAT_Score for each Category, considering only rows where CSAT is actually available?
select category, round(avg(CSAT_score), 2) as AVG_CSAT_Score
from tickets_cleaned
where CSAT_Score is not null
group by category

-- Which category has the lowest average CSAT?
select Top 1 with ties
category, 
round(avg(CSAT_score), 2) as AVG_CSAT_Score
from tickets_cleaned
group by category
Order by AVG_CSAT_Score asc

-- Which category has the highest escalation rate?
select 
    category,
    round(100.0 * sum(case 
        when escalated = 'Yes' then 1 
        Else 0
        End)/count(*), 2) as Escalated_rate
from tickets_cleaned
group by category
order by Escalated_rate desc

--Which category has the highest reopen rate?
select 
    category,
    round(100.0 *
    sum(case
        when reopened = 'Yes' then 1 
        Else 0
        end)/ count(*), 2) as Reopened_rate
from tickets_cleaned
group by category 
order by  Reopened_rate desc

--For each category, show: Total Tickets, Escalation Rate, Reopen Rate
select 
    category, 
    count(*) as Total_tickets,
    round(100.0 * sum(case when escalated = 'Yes' then 1 else 0 end)/count(*), 2) as Escalation_Rate,
    round(100.0 * sum(case when Reopened = 'Yes' then 1 else 0 end)/count(*), 2) as Reopened_Rate
from tickets_cleaned
group by category

-- For every closed ticket, did we meet or breach the resolution SLA?
select 
    t.Ticket_ID,
    t.Priority,
    t.Resolution_Hours,
    s.Resolution_Target_Hours,
    case when Resolution_Hours <= Resolution_Target_Hours then 'Met' Else 'Not_Met' end as SLA_Status
From tickets_cleaned t
left join SLA_master_Cleaned s
on t.priority = s.priority
where t.ticket_status = 'Closed'

--What percentage of closed tickets met the Resolution SLA?
select 
    Cast(round(100.0 * Sum(case when Resolution_Hours <= Resolution_Target_Hours then 1 Else 0 end)/Count(*), 2) as Decimal(5,2)) as SLA_Compliance_rate
From tickets_cleaned t
left join SLA_master_Cleaned s
on t.priority = s.priority
where t.ticket_status = 'Closed'

--For each Category, show: total closed tickets, SLA compliance rate, SLA breach rate
select
    category,
    Count(*) as Total_closed_tickets,
    cast(round(100.0 * sum(case when resolution_hours <= Resolution_target_hours then 1 else 0 end)/count(*), 2) as decimal(5,2)) as SLA_compliance_rate,
    cast(round(100.0 * sum(case when resolution_hours > Resolution_target_hours then 1 else 0 end)/count(*), 2) as decimal(5,2)) as SLA_breach_rate
from tickets_cleaned t
left join SLA_Master_cleaned s
on t.priority = s.priority
where t.ticket_status = 'Closed'
group by t.category
Order by SLA_breach_rate desc

--Which categories contribute the most actual SLA-breached tickets?
Select 
    Category,
    Count(*) as Total_closed_tickets,
    sum(case when resolution_hours > Resolution_target_hours then 1 else 0 end) as Breached_tickets,
    cast(round(100.0 * sum(case when resolution_hours > Resolution_target_hours then 1 else 0 end)/count(*), 2) as decimal(5,2)) as SLA_breach_rate
from tickets_cleaned t
left join SLA_Master_cleaned s
on t.priority = s.priority
where t.ticket_status = 'Closed'
group by t.category
Order by Breached_tickets desc
--Which priority level has the highest SLA breach rate?
select 
    t.Priority,
    count(*) as Total_Closed_Tickets,
    sum(case when t.resolution_hours > s.Resolution_target_hours then 1 else 0 end) as Breached_tickets,
    cast(round(100.0 * sum(case when t.resolution_hours > s.Resolution_target_hours then 1 else 0 end)/count(*), 2) as decimal(5,2)) as SLA_breach_rate
from tickets_cleaned t
left join SLA_Master_cleaned s
on t.priority = s.priority
where t.ticket_status = 'Closed'
group by t.priority
order by SLA_breach_rate desc

--Which support team has the highest SLA breach rate?
select 
    a.Team,
    count(*) as Total_Closed_Tickets,
    sum(case when t.resolution_hours > s.Resolution_target_hours then 1 else 0 end) as Breached_tickets,
    cast(round(100.0 * sum(case when t.resolution_hours > s.Resolution_target_hours then 1 else 0 end)/count(*), 2) as decimal(5,2)) as SLA_breach_rate
from Tickets_cleaned t
left join SLA_Master_Cleaned s
on t.priority = s.priority
left join Agent_Master_Cleaned a
on t.agent_id = a.agent_id
where t.ticket_status = 'Closed'
group by a.team
order by SLA_breach_rate desc

--Which shift has the highest SLA breach rate?
select 
    a.shift,
    count(*) as Total_Closed_Tickets,
    sum(case when t.resolution_hours > s.Resolution_target_hours then 1 else 0 end) as Breached_tickets,
    cast(round(100.0 * sum(case when t.resolution_hours > s.Resolution_target_hours then 1 else 0 end)/count(*), 2) as decimal(5,2)) as SLA_breach_rate
from Tickets_cleaned t
left join SLA_Master_Cleaned s
on t.priority = s.priority
left join Agent_Master_Cleaned a
on t.agent_id = a.agent_id
where t.ticket_status = 'Closed'
group by a.shift
order by SLA_breach_rate desc

--Which agents have the highest SLA breach rate?
select 
    a.agent_id,
    a.agent_name,
    a.Team,
    a.Shift,
    count(*) as Total_Closed_Tickets,
    sum(case when t.resolution_hours > s.Resolution_target_hours then 1 else 0 end) as Breached_Tickets,
    cast(round(100.0 * sum(case when t.resolution_hours > s.Resolution_target_hours then 1 else 0 end)/count(*), 2) as decimal (5,2)) as SLA_Breach_Rate
from Tickets_cleaned t
left join SLA_Master_Cleaned s
on t.priority = s.priority
left join Agent_Master_Cleaned a
on t.agent_id = a.agent_id
where t.ticket_status = 'Closed'
group by 
    a.agent_id,
    a.agent_name,
    a.Team,
    a.Shift
having count(*) >= 100
order by SLA_breach_rate desc

--How many support tickets were created each month from January to June 2026?
select 
    Year(created_date) as Year,
    month(created_date) as Month_no,
    DateName(Month, created_date) as Month_name,
    count(*) as Total_tickets
from tickets_cleaned
group by 
    Year(created_date),
    month(created_date),
    DateName(Month, created_date)
order by Month_no

--Do customers whose tickets breach SLA give lower satisfaction scores than customers whose tickets meet SLA?
select
    case when t.resolution_hours <= s.Resolution_target_hours then 'Met' else 'Breached' End as SLA_Status,
    count(*) as Rated_tickets,
    Cast(avg(CAST(t.CSAT_score as decimal(4,2))) as decimal(4,2)) as Average_CSAT
from tickets_Cleaned t
left join SLA_Master_Cleaned s
on t.priority = s.priority
where t.CSAT_score is not null and t.ticket_status = 'Closed'
group by case when t.resolution_hours <= s.Resolution_target_hours then 'Met' else 'Breached' End

--Which Category + Shift combinations have the highest SLA breach rate?
with root_cause as
(select 
    t.category,
    a.shift,
    count(*) as Total_Closed_tickets,
    sum(case when t.resolution_hours > s.resolution_target_hours then 1 else 0 end) as Breached_tickets,
    cast(round(100.0 * sum(case when t.resolution_hours > s.Resolution_target_hours then 1 else 0 end)/count(*), 2) as decimal (5,2)) as SLA_Breach_Rate 
from tickets_cleaned t
left join SLA_master_cleaned s
on t.priority = s.priority
left join Agent_master_cleaned a
on t.agent_id = a.agent_id
Where t.ticket_status = 'Closed'
group by  t.category, a.shift)
select * from root_cause
order by SLA_Breach_Rate desc

--Rank agents within their own team based on SLA breach rate.
with agent_performance as
(select
    a.agent_id,
    a.agent_name,
    a.team,
    a.shift,
    count(*) as total_closed_tickets,
    cast(round(100.0 * sum(case when t.resolution_hours > s.Resolution_target_hours then 1 else 0 end)/count(*), 2) as decimal (5,2)) as SLA_Breach_Rate 
from tickets_cleaned t
left join SLA_master_cleaned s
on t.priority = s.priority
left join Agent_master_cleaned a
on t.agent_id = a.agent_id
where t.ticket_status = 'Closed'
group by 
    a.agent_id,
    a.agent_name,
    a.team,
    a.shift)
select 
    Agent_ID,
    Agent_Name,
    Team,
    Shift,
    Total_Closed_Tickets,
    SLA_Breach_Rate,
    dense_rank() over(partition by team order by SLA_Breach_rate desc) as Team_rank
from agent_performance
order by Team, Team_rank