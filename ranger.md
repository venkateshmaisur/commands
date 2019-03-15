# Ranger Commands

##### Ranger installation RHEL 6
```sh
yum install mysql-server mysql-connector-java -y
/etc/init.d/mysqld start
chkconfig mysqld on
/usr/bin/mysqladmin -u root password 'root'
```

##### Ranger installation RHEL 7
```sh
yum install mysql-server mysql-connector-java -y
systemctl start mysqld
mysql_secure_installation
```

##### Setup Ambari
```shell
yum install mysql-connector-java -y
ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar

##### Setup Mysql
```sql
mysql -u root -proot
grant all privileges on *.* to 'root'@'c174-node2.squadron-labs.com' identified by 'root' with grant option;
```


