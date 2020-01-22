
### Hive
```sql
create database recipes_database;
use recipes_database;
CREATE TABLE COURSE
(
Course_ID Int,
Course_Name Varchar(10)
);

Insert into COURSE values (1,'SQL');
Insert into COURSE values (2,'Python');
Insert into COURSE values (3,'SQL');
Insert into COURSE values (4,'C');
```
### Impala
```
# impala-shell -i localhost --quiet

create database experiments;
use experiments;
create table t1 (x int);
insert into t1 values (1), (3), (2), (4);
select x from t1 order by x desc;
select min(x), max(x), sum(x), avg(x) from t1;
create table t2 (id int, word string);
insert into t2 values (1, "one"), (3, "three"), (5, 'five');
select word from t1 join t2 on (t1.x = t2.id);
```
