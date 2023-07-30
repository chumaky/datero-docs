create table salaries(user_id int, salary numeric);

alter table salaries add constraint sal_pk primary key (user_id);

insert into salaries values (1, 100);
insert into salaries values (2, 200);
insert into salaries values (3, 500);

