
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
```sql
impala-shell -i localhost --quiet

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

```sql

Impala Shell Command

impala-shell -i knox-workshop-2.knox-workshop.root.hwx.site -d default -k --ssl --ca_cert=/var/run/cloudera-scm-agent/process/319-impala-IMPALAD/cm-auto-global_cacerts.pem

Ranger Policies:
=============
Ranger HDFS Policy
-----------------------
RWX - impala -  /tenants/cloudera_admin  - Recursive

Ranger Hadoop SQL Policy
--------------------------------
ALL - impala - URL - hdfs://nameservice1/tenants/cloudera_admin/hdfs/raw - Recursive

Ranger Hadoop SQL Policy
-------------------------------
ALL - impala - DB - cloudera_admin_internal

Create External Table (Impala):
-------------------------------------

cat cars.csv
"chevrolet chevelle malibu",18,8,307,130,3504,12,1970-01-01,A
"buick skylark 320",15,8,350,165,3693,11.5,1970-01-01,A
"plymouth satellite",18,8,318,150,3436,11,1970-01-01,A
"amc rebel sst",16,8,304,150,3433,12,1970-01-01,A
"ford torino",17,8,302,140,3449,10.5,1970-01-01,A

hdfs dfs -mkdir hdfs://nameservice1/tenants/cloudera_admin/hdfs/raw/tmp_testing_impala_load/
hdfs dfs -copyFromLocal cars.csv hdfs://nameservice1/tenants/cloudera_admin/hdfs/raw/tmp_testing_impala_load/


CREATE EXTERNAL TABLE IF NOT EXISTS cloudera_admin_internal.cars(
        Name STRING,
        Miles_per_Gallon INT,
        Cylinders INT,
        Displacement INT,
        Horsepower INT,
        Weight_in_lbs INT,
        Acceleration DECIMAL,
        Year DATE,
        Origin CHAR(1))
    COMMENT 'Data about cars from a public database'
    ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ','
    STORED AS TEXTFILE
    location '/tenants/cloudera_admin/hdfs/raw/cars';


LOAD DATA INPATH 'hdfs://nameservice1/tenants/cloudera_admin/hdfs/raw/tmp_testing_impala_load/cars.csv' OVERWRITE INTO TABLE cloudera_admin_internal.cars;
```
