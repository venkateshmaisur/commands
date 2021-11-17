Please find the below steps to encrypt the password. A complete set of logs are available in "815610_encrypt_password_Workaround.txt".

Step 1: `Cloudera Manager -> Services -> Hive on Tez -> Configuration` -> and then search for property `"GENERATE_JCEKS_PASSWORD"`, if the option is checked, please uncheck the same and restart HiveServer2.

Step 2: Please check the "Securing Password" section of the below URL, where you can encrypt the password using the below steps
https://cwiki.apache.org/confluence/display/Hive/JDBC+Storage+Handler

You may have to run the below query as HDFS user and make sure the path "/tmp/test.jceks" has enough permission for the user who is accessing it.


`hadoop credential create host1.password -provider jceks:///tmp/test.jceks -v <password>`

Step 3: Create a table with the exact schema to sys.dbs

```sql  
CREATE EXTERNAL TABLE blabla.dbs1 (
  DB_ID            bigint,
  DB_LOCATION_URI  string,
  NAME             string,
  OWNER_NAME       string,
  OWNER_TYPE       string )
STORED BY 'org.apache.hive.storage.jdbc.JdbcStorageHandler'
TBLPROPERTIES (
  'hive.sql.database.type' = 'MYSQL',
  'hive.sql.jdbc.driver'   = 'com.mysql.jdbc.Driver',
  'hive.sql.jdbc.url'      = 'jdbc:mysql://c2547-node4.coelab.cloudera.com:3306/hive',
  'hive.sql.dbcp.username' = 'hive',
  'hive.sql.dbcp.password.keystore' = 'jceks:///tmp/test.jceks',
  'hive.sql.dbcp.password.key' = 'host1.password',
  'hive.sql.query' = 'SELECT DB_ID, DB_LOCATION_URI, NAME, OWNER_NAME, OWNER_TYPE FROM DBS'
);
```
Step 4: `select * from blabla.dbs1 ;`
