select * from self.dbo.hr_dataset as hr_dataset

'''
	1. Top 3 Departments by Highest Attrition Rate
	Write a SQL query to find the top 3 departments with the highest attrition rate. 
	For each department, calculate the total number of employees, the number of employees
	who left the company (left = 1), and the attrition rate as a percentage. Sort the result
	in descending order of attrition rate.
'''

with total_left_cte as (
	select department
	,count(1) as total_emp_of_dept
	,SUM(case when [left]=1 then 1 else 0 end) total_left
	,ROUND(SUM(case when [left]=1 then 1 else 0 end)*1.0 / count(1),2) attr
	--,rank()over(order by SUM(case when [left]=1 then 1 else 0 end) desc) rank
	from self.dbo.hr_dataset
	group by departments
)
,attrition_cte as(
	select *
	,dense_rank()over(order by attr desc,total_emp_of_dept desc) rank
	from total_left_cte
)
select department
from attrition_cte
where rank<4;

----------------------------------------------------------------------------
'''
	2.Employees Who Worked Above-Average Hours and Left
'''
with avg_hr as(
	select ROUND(avg(average_monthly_hours),2) hourss
	from self.dbo.hr_dataset
)
select *
from self.dbo.hr_dataset h
inner join avg_hr a on h.average_monthly_hours > a.hourss
where h.[left]=1 and h.salary='low';


----------------------------------------------------------------------------
"""
	3. Attrition  Rate by Salary Level
		(Identify if low salary correlates with higher attrition)
"""
select salary
,count(*) total_emp_with_salary
,round(SUM(case when [left]=1 then 1 else 0 end)*100.0/count(*),2) attr
from self.dbo.hr_dataset
group by salary
order by attr desc;

----------------------------------------------------------------------------
"""
	4. attrtion rate by Average Monthly Hours
	   (Understand if overworking is a factor in attrition.)
"""
--min96  max310

with encoded_cte as(
	select *
	, case 
		when average_monthly_hours<175 then 'low'
		when average_monthly_hours<250 then 'medium'
		when average_monthly_hours<311 then 'high' end as enc_avg_monthly_hour
	from self.dbo.hr_dataset
)
select enc_avg_monthly_hour
,round(SUM(case when [left]=1 then 1 else 0 end)*100.0/count(*),2) attr
from encoded_cte
group by enc_avg_monthly_hour
order by attr desc



------------------------------------------------------------
'''
	5. Satisfaction Distribution Between Left vs Stayed
		(Compare how satisfaction levels differ)
'''
SELECT 
  "left",
  ROUND(AVG(satisfaction_level), 2) AS avg_satisfaction
FROM self.dbo.hr_dataset
GROUP BY "left";

-------------------------------------------------------------------------------
'''
	6. Tenure Impact on Attrition
		(Check if attrition increases with more years spent at the company)
'''
SELECT 
  time_spend_company,
  COUNT(*) AS total,
  SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) AS left_count,
  ROUND(100.0 * SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM self.dbo.hr_dataset
GROUP BY time_spend_company
ORDER BY time_spend_company;


-------------------------------------------------------------------------------
'''
	7. Attrition by Number of Projects
		(Discover if under or overworked employees leave more often.)
'''
SELECT 
  number_project,
  COUNT(*) AS total,
  SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) AS left_count,
  ROUND(100.0 * SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM self.dbo.hr_dataset
GROUP BY number_project
ORDER BY number_project;

-------------------------------------------------------------------------------
'''
	9. Promotion Impact on Attrition
	Check if promoting employees helps reduce attrition.
'''
SELECT 
  promotion_last_5years,
  COUNT(*) AS total,
  SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) AS left_count,
  ROUND(100.0 * SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM self.dbo.hr_dataset
GROUP BY promotion_last_5years;

-----------------------------------------------------------------------------
'''
	10. Top 10 Longest-Serving Employees Who Left
	Explore employees who stayed long but still left.
'''
SELECT top 10 *
FROM self.dbo.hr_dataset
WHERE "left" = 1
ORDER BY time_spend_company DESC
