#Create a database named employee, then import data_science_team.csv proj_table.csv and emp_record_table.csv 
#into the employee database from the given resources.


create database SQL_Projects;
show databases;
use sql_projects;

#1st Table

create table emp_record_table(EMP_ID int primary key, FIRST_NAME varchar(30),LAST_NAME varchar(30), GENDER varchar(10), ROLE_ varchar(40), 
DEPT varchar(40),EXP int, COUNTRY varchar(25), CONTINENT varchar(40), SALARY int, EMP_RATING int,
MANAGER_ID text, PROJ_ID text);

insert into emp_record_table(EMP_ID, FIRST_NAME,LAST_NAME, GENDER, ROLE_,DEPT,EXP, COUNTRY, CONTINENT, SALARY, EMP_RATING,MANAGER_ID, PROJ_ID) 
values('E021','Arthur','Black','M','President','All',20,'USA','North America',16500,5,'','');
select *from emp_record_table;

#2nd Table

create table Proj_table(PROJECT_ID varchar(10) primary key, PROJ_Name varchar(40), DOMAIN varchar(30), 
START_DATE text, CLOSURE_DATE text, DEV_QTR varchar(10),STATUS_ varchar(20));

insert into Proj_table(PROJECT_ID, PROJ_Name, DOMAIN,START_DATE, CLOSURE_DATE, DEV_QTR,STATUS_) 
values('P103', 'Drug Discovery', 'HEALTHCARE', '04-06-2021', '6/20/2021', 'Q1', 'DONE');

select *from Proj_table;

#3rd table

create table Data_science_team(EMP_ID varchar(10) primary key, FIRST_NAME varchar(30), LAST_NAME varchar(30), GENDER varchar(10), 
ROLE_ varchar(50), DEPT varchar(30), EXP int, COUNTRY varchar(30), CONTINENT varchar(55));

insert into Data_science_team(EMP_ID, FIRST_NAME, LAST_NAME, GENDER, ROLE_, DEPT, EXP, COUNTRY, CONTINENT) 
values('E005', 'Eric', 'Hoffman', 'M', 'LEAD DATA SCIENTIST', 'FINANCE', '11', 'USA', 'NORTH AMERICA');

select *from Data_science_team;

show tables;


# Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table, 
#and make a list of employees and details of their department.

select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT from emp_record_table ;


#Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is: 

#less than two
#greater than four 
#between two and four

select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, EMP_RATING from emp_record_table where emp_rating<2;

select EMP_ID,FIRST_NAME,LAST_NAME,GENDER,DEPT from emp_record_table where emp_rating>4;

select EMP_ID,FIRST_NAME,LAST_NAME,GENDER,DEPT,EMP_RATING from emp_record_table where EMP_RATING between 2 and 4;

#Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in the 
#Finance department from the employee table and then give the resultant column alias as NAME.

select concat(FIRST_NAME,' ',LAST_NAME) as _NAME_ from emp_record_table where DEPT = 'Finance';

select *from emp_record_table;

#Write a query to list only those employees who have someone reporting to them. Also, show the number of reporters (including the President).

SELECT e1.EMP_ID, COUNT(e2.EMP_ID) AS num_reporters
FROM emp_record_table e1
JOIN emp_record_table e2 ON e1.EMP_ID = e2.Manager_id
GROUP BY e1.EMP_ID
HAVING COUNT(e2.EMP_ID) > 0;



#Write a query to list down all the employees from the healthcare and finance departments using union. Take data from the employee record table.

select *from emp_record_table where DEPT='HEALTHCARE'
union
select *from emp_record_table where DEPT='FINANCE' ;



#Write a query to list down employee details 
#such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept. 
#Also include the respective employee rating along with the max emp rating for the department.

select EMP_ID,FIRST_NAME,LAST_NAME,GENDER,ROLE_,DEPT,EMP_RATING,max(EMP_RATING) 
over(partition by DEPT)
as max_dept_rating from emp_record_table
group by DEPT,EMP_ID, FIRST_NAME, LAST_NAME, GENDER, ROLE_, EMP_RATING;



#Write a query to calculate the minimum and the maximum salary of the employees in each role. Take data from the employee record table.


SELECT ROLE_, 
MIN(SALARY) AS MIN_SALARY, 
MAX(SALARY) AS MAX_SALARY 
FROM emp_record_table
GROUP BY ROLE_;

   #(OR)#
   

select EMP_ID,FIRST_NAME,LAST_NAME,GENDER,ROLE_,dept,
max(salary) over(partition by dept) as max_salary,
min(salary) over(partition by dept) as min_salary 
from emp_record_table;



#Write a query to assign ranks to each employee based on their experience. Take data from the employee record table.

SELECT EMP_ID, FIRST_NAME, LAST_NAME, EXP, 
DENSE_RANK() OVER (ORDER BY EXP DESC) AS RANKING
FROM emp_record_table;


# Write a query to create a view that displays employees in various countries whose salary is more than six thousand. 
# Take data from the employee record table.

create view high_country_sal_view as
select emp_id,first_name,last_name,country,salary from emp_record_table where salary>6000;

select *from high_country_sal_view;


#Write a nested query to find employees with experience of more than ten years. Take data from the employee record table.

select *from emp_record_table 
where emp_id IN (
    SELECT emp_id FROM emp_record_table
    WHERE exp > 10);


#Write a query to create a stored procedure to retrieve the details of the employees 
#whose experience is more than three years. Take data from the employee record table.


delimiter //
create procedure get_exp_emp()
begin
select emp_id,first_name,last_name,exp,salary 
from emp_record_table
where exp>= 3;
end //
delimiter ;

call get_exp_emp();


select *from proj_table;
select *from emp_record_table;

#Write a query using stored functions in the project table to check whether 
#the job profile assigned to each employee in the data science team matches the organization’s set standard.

#The standard being:
#For an employee with experience less than or equal to 2 years assign 'JUNIOR DATA SCIENTIST',
#For an employee with the experience of 2 to 5 years assign 'ASSOCIATE DATA SCIENTIST',
#For an employee with the experience of 5 to 10 years assign 'SENIOR DATA SCIENTIST',
#For an employee with the experience of 10 to 12 years assign 'LEAD DATA SCIENTIST',
#For an employee with the experience of 12 to 16 years assign 'MANAGER'.

DELIMITER //
CREATE FUNCTION check_job_profile_std(start_date DATE, closure_date DATE)
RETURNS VARCHAR(50) DETERMINISTIC
BEGIN
    DECLARE job_profile VARCHAR(50);
	DECLARE exp int;
    SET exp = YEAR(closure_date) - YEAR(start_date);
        IF exp <= 2 THEN
        SET job_profile = 'JUNIOR DATA SCIENTIST';
    ELSEIF exp > 2 AND exp <= 5 THEN
        SET job_profile = 'ASSOCIATE DATA SCIENTIST';
    ELSEIF exp > 5 AND exp <= 10 THEN
        SET job_profile = 'SENIOR DATA SCIENTIST';
    ELSEIF exp > 10 AND exp <= 12 THEN
        SET job_profile = 'LEAD DATA SCIENTIST';
    ELSEIF exp > 12 AND exp <= 16 THEN
        SET job_profile = 'MANAGER';
    END IF;    RETURN job_profile;
END //
DELIMITER ;

call check_job_profile_std('04-06-2021', '6/20/2021');


#Create an index to improve the cost and performance of the query to find the employee 
#whose FIRST_NAME is ‘Eric’ in the employee table after checking the execution plan.


CREATE INDEX indx_employee_firstname ON emp_record_table(FIRST_NAME(255));
select *from emp_record_table where first_name='Eric';
select emp_id,first_name,role_,exp from emp_record_table where first_name='eric';


#Write a query to calculate the bonus for all the employees, based on their ratings and 
#salaries (Use the formula: 5% of salary * employee rating).

select *,0.05*salary*emp_rating as bonus from emp_record_table  ; 


#Write a query to calculate the average salary distribution based on the continent and country. Take data from the employee record table.

select continent,country,avg(salary) as average_salary from emp_record_table group by continent,country;




# 2nd Query is ER diagram which is can be done in reverse engineering of database option given top-left side, check the utube videos for it, its simple 


