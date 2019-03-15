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
```

##### Setup Mysql
```sql
mysql -u root -proot
grant all privileges on *.* to 'root'@'c174-node2.squadron-labs.com' identified by 'root' with grant option;
```

##### MySql Dump and Restoration

```sql
mysqldump -U ambari -p ambari > /tmp/ambari.original.mysql
cp /tmp/ambari.original.mysql /tmp/ambari.innodb.mysql
sed -ie 's/MyISAM/INNODB/g' /tmp/ambari.innodb.mysql
mysql -u ambari -p ambari
DROP DATABASE ambari;
CREATE DATABASE ambari;
mysql -u ambari "-pbigdata" --force ambari < /tmp/ambari.innodb.mysql
```
##### MYSQL SSL
`mysql_ssl_rsa_setup --uid=mysql`



