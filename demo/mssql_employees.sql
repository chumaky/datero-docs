create database hr;
go
use hr;
go

create table employees (id int, name varchar(100), job_id int);
go

insert
  into employees
values (1, 'John', 1)
     , (2, 'Bob', 2)
     , (3, 'Lisa', 3)
;
go
