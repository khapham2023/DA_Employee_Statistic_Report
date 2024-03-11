#create database
create database SQL_project;
#expand the newly created sql_project database, right click on the table, and select table data import wizard
use sql_project;
select * from hr limit 10;
#change name of the first column for more readable
alter table hr change column ï»¿id id text;
alter table hr modify column id varchar(30);
describe hr;

#format the brithdate column as the data was created in various format, the new format will be Y-m-d
#in case there's  restriction in reset the data format, we can "set sql_safe_updates = 0" to bypass the restriction. Once done, we're required to set this back to 1
select birthdate from hr;
update hr set birthdate = case
	when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
    else null
end;
select count(*) from hr where birthdate is null; 
alter table hr modify column birthdate date;

#do the same cleaning with hiredate
select hire_date from hr;
update hr set hire_date = case
	when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
    else null
end;
alter table hr modify column hire_date date;

#termdate column has timestamp and we dont need this timestamp
select termdate from hr;
#as the character m was used by month, for the minute, we used i in replace 
update hr set termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC')) where termdate is not null and termdate !='';
alter table hr modify column termdate date default null;
UPDATE hr
SET termdate = NULL
WHERE termdate = '';
describe hr;

#add the age column to the table
alter table hr add column age int; 
update hr set age = timestampdiff(year,birthdate,curdate());
select birthdate,age from hr;
select count(*) from hr where age < 18;

#1.	What is the gender breakdown of employees in the company? termdate is null -> still working for the company
select gender, count(*) from hr 
where age >= 18 and termdate is null
group by gender;

#2.	What is the race/ethnicity breakdown of employees in the company?
select race, count(*) from hr 
where age >= 18 and termdate is null
group by race;

#3.	What is the age distribution of employees in the company?
select min(age), max(age) from hr where age >= 18 and termdate is null;
select case
when age>=18 and age<30 then '18-29'
when age>=30 and age<40 then '30-39'
when age>=40 and age<50 then '40-49'
when age>=50 and age<59 then '50-59'
else '60+'
end as age_group,count(*)
from hr
where age >= 18 and termdate is null
group by age_group
order by age_group;

#4.	How many employees work at headquarters versus remote locations?
select location, count(*) from hr
where age >= 18 and termdate is null
group by location;

#5.	What is the average length of employment for employees who have been terminated?
select round(avg(datediff(termdate,hire_date))/365,2) as avg_day_employment from hr
where termdate is not null and termdate<=curdate();

#6.	How does the gender distribution vary across departments and job titles?
select gender,department,jobtitle,count(*) from hr 
where age >= 18 and termdate is null
group by gender,department,jobtitle;

#7.	What is the distribution of job titles across the company?
select jobtitle,count(*) from hr
where age >= 18 and termdate is null
group by jobtitle;

#8.	Which department has the highest turnover rate?
with cte1 as 
(
select department, total_employee, ex_employee, ex_employee/total_employee as turn_over_rate from 
(
select department, count(*) as total_employee,
sum(case when termdate is not null and termdate<curdate() then 1 else 0 end) as ex_employee
from hr
where age >=18
group by department
) t1
)
select department from cte1
order by turn_over_rate desc limit 1;

#9.	What is the distribution of employees across locations by state?
select location_state, count(*) from hr
where age >= 18 and termdate is null
group by 1;