create database employee_Management_db;

use employee_Management_db;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

select * from JobDepartment;


-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from SalaryBonus;


-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

select * from Employee;



-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
select * from Qualification;


-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from Leaves;



-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

select * from Payroll;

# Problem Statement:
# The objective of this project is to design and implement an Employee Management System that efficiently stores and manages employee-related data within an organization. The system needs to track various aspects of employee information, including personal details, job roles, salary structures, qualifications, leave records, and payroll data. The system should ensure the integrity and consistency of data by using relational tables with appropriate foreign keys and cascading actions.
# 3 The system should allow for easy management and querying of employee data, providing insights such as payroll calculation, leave tracking, and department-specific job roles. The goal is to streamline HR operations, ensuring that all relevant employee data is accessible and accurately updated across different modules.
# Analysis Questions


# 1. EMPLOYEE INSIGHTS
# a) How many unique employees are currently in the system?
select count(distinct emp_id) as total_unique_employees
from employee;

# b)Which departments have the highest number of employees?
select jd.jobdept as department_name,
      count(e.emp_id)as employ_count
      from employee e 
      join jobdepartment jd
      on e.job_id = jd.job_id
      group by jd.jobdept
      order by employ_count desc;

# c)What is the average salary per department?
select 
     jd.jobdept as Department_name,
     avg(sb.amount)as Avg_salary
     from jobdepartment jd
     join salarybonus sb
     on jd.job_id = sb.job_id
     group by jd.jobdept
     order by Avg_salary desc;


# d)Who are the top 5 highest-paid employees?
select 
    e.emp_id,e.firstname,e.lastname,jd.jobdept as department,
    sb.amount as salary
    from employee e
    join jobdepartment jd
    on e.job_id = jd.job_id
    join salarybonus sb
    on jd.job_id = sb.job_id
    order by salary desc;


# e)What is the total salary expenditure across the company?
select 
    sum(amount) as total_salary
    from salarybonus;



# 2. JOB ROLE AND DEPARTMENT ANALYSIS
# a)How many different job roles exist in each department?
select 
     jobdept as department,
     count(distinct name) as number_roles
     from jobdepartment
     group by jobdept;
# b)What is the average salary range per department?
select 
    jobdept ,group_concat(distinct salaryrange) as salary_range
    from jobdepartment
    group by jobdept;
SELECT 
    jobdept AS Department,
    AVG(
        (
          CAST(REPLACE(SUBSTRING_INDEX(salaryrange,'-',1),',','') AS DECIMAL(10,2)) +
          CAST(REPLACE(SUBSTRING_INDEX(salaryrange,'-',-1),',','') AS DECIMAL(10,2))
        ) / 2
    ) AS salary_range
FROM JobDepartment
GROUP BY jobdept;
# c)Which job roles offer the highest salary?
select jd.name as job_roles,
       jd.jobdept as department,
       sb.amount as salary
       from jobdepartment jd
       join salarybonus sb
       order by salary desc;

# d)Which departments have the highest total salary allocation?
select 
      jd.jobdept as department,
      sum(sb.amount) as total_salary
      from jobdepartment jd
      join salarybonus sb
      on sb.job_id = jd.job_id
      group by jd.jobdept
      order by total_salary desc;
      
      
      
# 3. QUALIFICATION AND SKILLS ANALYSIS
# a)How many employees have at least one qualification listed?
select count(distinct emp_id)as employee_with_qulification
 from employee ;
# b)Which positions require the most qualifications?
select 
      position,
       count(qualid)as most_qualifications
       from qualification
       group by position 
       order by most_qualifications desc;
# c)Which employees have the highest number of qualifications?
select 
     e.emp_id,
     e.firstname,
     e.lastname,
     count(q.qualid) as Highest_qualification
     from employee e 
     join qualification q 
     on e.emp_id = q.emp_id
     group by e.emp_id,e.firstname,e.lastname
     order by Highest_qualification desc;
     
     

# 4. LEAVE AND ABSENCE PATTERNS
# a)Which year had the most employees taking leaves?
select 
     year(date) as leave_year,
     count(emp_id) as employe_on_leave
     from leaves
     group by year(date)
     order by employe_on_leave desc;
# b)What is the average number of leave days taken by its employees per department?
SELECT 
    jd.jobdept AS department,
    COUNT(l.leave_ID) / COUNT(DISTINCT e.emp_ID) AS avg_leave_days
FROM Employee e
JOIN JobDepartment jd
    ON e.Job_ID = jd.Job_ID
LEFT JOIN Leaves l
    ON e.emp_ID = l.emp_ID
GROUP BY jd.jobdept;
# c)Which employees have taken the most leaves?
select 
     e.emp_id,
     e.firstname,
     e.lastname,
     count(l.leave_id) as total_leaves
     from employee e 
     join leaves l 
     on e.emp_id = l.emp_id
     group by e.emp_id,e.firstname,e.lastname
     order by total_leaves desc;
# d)What is the total number of leave days taken company-wide?
select count(leave_id) as total_leaves
from leaves;
# e)How do leave days correlate with payroll amounts?
select * from payroll;SELECT 
    e.emp_ID,
    e.firstname,
    e.lastname,
    COUNT(l.leave_ID) AS total_leaves,
    SUM(p.total_amount) AS total_payroll
FROM Employee e
LEFT JOIN Leaves l
    ON e.emp_ID = l.emp_ID
LEFT JOIN Payroll p
    ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname
ORDER BY total_leaves DESC;



# 5. PAYROLL AND COMPENSATION ANALYSIS
# a)What is the total monthly payroll processed?
select 
     month(date) as monthly_payroll,
     sum(total_amount) as monthly_amount
     from payroll
     group by month(date)
     ORDER BY MONTH(date);
# b)What is the average bonus given per department?
select 
    jd.jobdept as department,
    avg(sb.bonus) as avg_bonus
    from jobdepartment jd
    join salarybonus sb
    on jd.job_id = sb.job_id
    group by jd.jobdept
    order by avg_bonus desc;
# c)Which department receives the highest total bonuses?
select 
      jd.jobdept as department,
      sum(sb.bonus)as total_bonuses
      from jobdepartment jd
      join salarybonus sb
      on jd.job_id = sb.job_id
      group by jd.jobdept
      order by total_bonuses desc;
# d)What is the average value of total_amount after considering leave deductions?
SELECT 
    jd.jobdept AS department,
    AVG(p.total_amount - (lv.leave_count * 100)) 
        AS avg_amount_after_deduction
FROM JobDepartment jd
JOIN Employee e
    ON jd.job_id = e.job_id
JOIN Payroll p
    ON e.emp_id = p.emp_id
LEFT JOIN (
        SELECT 
            emp_id,
            COUNT(leave_id) AS leave_count
        FROM Leaves
        GROUP BY emp_id
     ) lv
ON e.emp_id = lv.emp_id
GROUP BY jd.jobdept
ORDER BY avg_amount_after_deduction DESC;

# . List employees along with their qualifications and skills?

SELECT 
    e.emp_ID,
    e.firstname,
    e.lastname,
    q.Position AS qualification,
    q.Requirements
FROM Employee e
LEFT JOIN Qualification q
       ON e.emp_ID = q.Emp_ID;


