/*
PROJECT OBJECTIVE
The objective of this project is to manage:
-Employees
-Projects
-Tasks
-Task assignments
-Task progress
This Project Management System efficiently manages projects, tasks, and employees.
It uses SQL joins, group by, stored procedures, and triggers to automate and analyze project progress.
*/

CREATE DATABASE Project_Management;

USE Project_Management;

-- Employees table(stores employees details):
CREATE TABLE Employees (
  EmpID INT PRIMARY KEY,
  EmpName VARCHAR(50),
  Department VARCHAR(50)
);

-- Insert values Employees:
INSERT INTO Employees VALUES
(1,'Arun','Development'),
(2,'Sita','Testing'),
(3,'Ravi','Development'),
(4,'Neha','UI/UX');

-- Projects table(stores project details):
CREATE TABLE Projects (
  ProjectID INT PRIMARY KEY,
  ProjectName VARCHAR(100)
);

-- Insert values(projects):
INSERT INTO Projects VALUES
(101,'Online Banking System'),
(102,'HR Management System');

-- Tasks table(stores tasks details):
CREATE TABLE Tasks (
  TaskID INT PRIMARY KEY,
  ProjectID INT,
  TaskName VARCHAR(100),
  Status VARCHAR(30),
  Deadline DATE
);

-- Insert values (tasks):
INSERT INTO Tasks VALUES
(1001,101,'UI Design','Completed','2025-01-20'),
(1002,101,'Backend Development','In Progress','2025-03-15'),
(1003,101,'Testing','Pending','2025-04-10'),
(1004,102,'Requirement Analysis','Pending','2025-02-15');

-- Tasks_Assingnments table(stores task_assignments deatils):
CREATE TABLE Task_Assignments (
  TaskID INT,
  EmpID INT,
  PRIMARY KEY (TaskID, EmpID)
);

-- Insert values(tasks_assignments):
INSERT INTO Task_Assignments VALUES
(1001,4),
(1002,1),
(1002,3),
(1003,2),
(1004,1);

-- display all projects with tasks
SELECT p.ProjectName, t.TaskName, t.Status
FROM Projects p
JOIN Tasks t ON p.ProjectID = t.ProjectID;

-- total number of tasks in each project
SELECT ProjectID, COUNT(*) AS TotalTasks
FROM Tasks
GROUP BY ProjectID;

-- completed tasks in each project
SELECT ProjectID,
SUM(CASE WHEN Status='Completed' THEN 1 ELSE 0 END) AS CompletedTasks
FROM Tasks
GROUP BY ProjectID;

-- employee-wise workload
SELECT e.EmpName, COUNT(ta.TaskID) AS TaskCount
FROM Employees e
JOIN Task_Assignments ta ON e.EmpID = ta.EmpID
GROUP BY e.EmpName;

-- employees working on project Online Banking System list
SELECT DISTINCT e.EmpName
FROM Employees e
JOIN Task_Assignments ta ON e.EmpID = ta.EmpID
JOIN Tasks t ON ta.TaskID = t.TaskID
WHERE t.ProjectID = 101;

-- overdue tasks
SELECT TaskName, Deadline
FROM Tasks
WHERE Deadline < CURDATE()
  AND Status <> 'Completed';

-- Stored Procedure
DELIMITER //

CREATE PROCEDURE Assign_Task (
    IN p_TaskID INT,
    IN p_EmpID INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Task_Assignments
        WHERE TaskID = p_TaskID
          AND EmpID = p_EmpID
    ) THEN
        INSERT INTO Task_Assignments (TaskID, EmpID)
        VALUES (p_TaskID, p_EmpID);
    END IF;
END //

DELIMITER ;

CALL Assign_Task(1003, 1);

SELECT * FROM Task_Assignments;

-- Trigger log table
DROP TABLE IF EXISTS Task_Update_Log;
CREATE TABLE Task_Update_Log (
  LogID INT AUTO_INCREMENT PRIMARY KEY,
  TaskID INT,
  OldStatus VARCHAR(30),
  NewStatus VARCHAR(30),
  UpdateTime DATETIME
);

DELIMITER //

CREATE TRIGGER Task_Update_Trigger
AFTER UPDATE ON Tasks
FOR EACH ROW
BEGIN
  IF IFNULL(OLD.Status,'') <> IFNULL(NEW.Status,'') THEN
    INSERT INTO Task_Update_Log
    (TaskID, OldStatus, NewStatus, UpdateTime)
    VALUES
    (NEW.TaskID, OLD.Status, NEW.Status, NOW());
  END IF;
END //

DELIMITER ;

UPDATE Tasks
SET Status = 'In Progress'
WHERE TaskID = 1003;

UPDATE Tasks
SET Status = 'Completed'
WHERE TaskID = 1003;

SELECT * FROM Task_Update_Log;








