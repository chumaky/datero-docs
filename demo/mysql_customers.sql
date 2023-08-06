create table users(id int, name text);

insert
  into users
values (1, 'Tom')
     , (2, 'Kate')
     , (3, 'John')
;

alter table users add constraint primary key users_pk(id);
