# Zepplein Cheats

##### JDBC Interpreter



```mysql
%jdbc(hive)
CREATE DATABASE books;
USE books;
CREATE TABLE authors (id INT, name VARCHAR(20), email VARCHAR(20));
SHOW TABLES;
INSERT INTO authors (id,name,email) VALUES(1,"Vivek","xuz@abc.com");
INSERT INTO authors (id,name,email) VALUES(2,"Priya","p@gmail.com");
INSERT INTO authors (id,name,email) VALUES(3,"Tom","tom@yahoo.com");
SELECT * FROM authors;
```

##### Livy Interpreter

```
%livy
sc.version
```
