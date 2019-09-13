# Ranger Commands


![Ranger Troubleshooting](https://github.com/bhagadepravin/commands/blob/master/Ranger%20troubleshooting.png)

## Ranger installation RHEL 6
```sh
yum install mysql-server mysql-connector-java -y
/etc/init.d/mysqld start
chkconfig mysqld on
/usr/bin/mysqladmin -u root password 'root'
```

## Ranger installation RHEL 7
```sh
yum install mysql-server mysql-connector-java -y
systemctl start mysqld
mysql_secure_installation

yum install mariadb-server -y 
systemctl start mariadb
systemctl enable mariadb
systemctl status mariadb
mysql_secure_installation

```

## Setup Ambari
```shell
yum install mysql-connector-java -y
ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar
```

## Setup Mysql
```sql
mysql -u root -proot
grant all privileges on *.* to 'root'@'c174-node2.squadron-labs.com' identified by 'root' with grant option;
```

## MySql Dump and Restoration

```sql
mysqldump -U ambari -p ambari > /tmp/ambari.original.mysql
cp /tmp/ambari.original.mysql /tmp/ambari.innodb.mysql
sed -ie 's/MyISAM/INNODB/g' /tmp/ambari.innodb.mysql
mysql -u ambari -p ambari
DROP DATABASE ambari;
CREATE DATABASE ambari;
mysql -u ambari "-pbigdata" --force ambari < /tmp/ambari.innodb.mysql
```
## MYSQL SSL
`mysql_ssl_rsa_setup --uid=mysql`


## Useful Cmds

`egrep -a2 -i "ranger.ldap.ad.domain|ranger.ldap.ad.url|ranger.ldap.ad.base.dn|ranger.ldap.ad.bind.dn|ranger.ldap.ad.bind.password|ranger.ldap.ad.referral" /etc/ranger/admin/conf/ranger-admin-site.xml`

```sql
SET FOREIGN_KEY_CHECKS=0;
delete from ranger.x_portal_user where first_name = 'amb_ranger_admin';
SET FOREIGN_KEY_CHECKS=1;
```

`/usr/hdp/current/ranger-admin/ews/ranger-admin-services.sh`



## Ranger Quicklinks

```
1. Login into Ambari enter username and password.

2. Open a new tab and paste below URL and enter.
http://<ambari-server-hostname>:8080/api/v1/stacks/HDP/versions/2.3/services/RANGER/quicklinks/quicklinks.json
Paste the output here.

3. Check below properties:
ranger.service.https.attrib.ssl.enabled = true {should be true for HTPPS}
ranger.service.http.enabled = false

4. If above two properties are not set properly then we need to modify metainfo.xml.
Edit " /var/lib/ambari-server/resources/common-services/RANGER/0.5.0/quicklinks/quicklinks.json "
Set the properties accordingly and save.
ranger.service.https.attrib.ssl.enabled = true
ranger.service.http.enabled = false
 
5. Restart Ambari Server
ambari-server restart
```

## Postgress Setup

```
echo "CREATE DATABASE ranger2;" | sudo -u postgres psql -U postgres

echo "CREATE USER rangerdba WITH PASSWORD 'rangerdba';" | sudo -u postgres psql -U postgres
echo "CREATE USER rangeradmin WITH PASSWORD 'rangerdba';" | sudo -u postgres psql -U postgres
echo "CREATE USER root WITH PASSWORD 'root';" | sudo -u postgres psql -U postgres
echo "GRANT ALL PRIVILEGES ON DATABASE ranger2 TO rangerdba;" | sudo -u postgres psql -U postgres 



/usr/jdk64/jdk1.8.0_112/bin/java  -cp /usr/hdf/current/ranger-admin/ews/lib/postgresql-jdbc.jar:/usr/hdf/current/ranger-admin/jisql/lib/* org.apache.util.sql.Jisql -driver postgresql -cstring jdbc:postgresql://c274-node2.squadron-labs.com:5432/ranger2 -u rangeradmin -p 'rangerdba' -noheader -trim -c \; -query "SELECT 1\;"
```

## Reset Ranger admin password to default:
##### Ranger admin login issue HDP 3.x

```
1- Change password to default admin/admin using below sql query. 

mysql> update ranger.x_portal_user set password = 'ceb4f32325eda6142bd65215f4c0f371' where login_id = 'admin'; 

2- Now you will be able to login to Ranger UI with default username & password i.e. admin/admin 

If you want to further change password from the default credentials kindly check below steps : 

Goto admin user profile in Ranger UI 
Select Change password tab 
Put password of your choice and save 

This step will update new password in ranger db. 

3 - Update new password in ranger configuration, save the changes and restart stale services 
In Ambari, you need to update both "admin_password" and "Ranger Admin user's password for Ambari" with the same values you used in Ranger UI in previous step. 
a - Go to Ambari UI ==> Ranger ==> Configs ==> Advanced ranger-env 
admin_password 
b - Go to Ambari UI ==> Ranger ==> Configs ==> Admin Settings 
ranger_admin_password
```

##### Reset rangerusersync user's password

```sh
1. Login to RangerUI --> settings --> users/groups --> change the password for the rangerusersync user. 
2. Login to AmbariUI --> Ranger --> configs --> Advanced --> Admin settings --> Change Rangerusersync user password to the same password you changed above. 
3. update the password using the password manager script. 

$ cd /usr/hdf/<version>/ranger-usersync/ 
$ python /usr/hdf/<version>/ranger-usersync/updatepolicymgrpassword.py 
```

# Ranger Usersync

```sh
Execute below cmd on Usersync node and attach the tar file 

# top -b -c -n 1 -p `cat /var/run/ranger/usersync.pid` > /tmp/usersync-top.txt 
# ps aux | grep usersync > /tmp/usersync-process.txt 
# tar cvzf rangerusersync-config-logs.tar.gz /etc/ranger/usersync/conf/* /var/log/ranger/usersync/usersync.log /tmp/usersync-process.txt /tmp/usersync-top.txt 
```

##### Analysis
```sh
 grep "completed with user count:" usersync.log
 grep "group count" usersync.log
 grep "Updating user count:" usersync.log
 egrep -A1 ranger.usersync.[ldap\|group] etc/ranger/usersync/conf/ranger-ugsync-site.xml | tr -d " "
```

##### mysql lock
```sh
SHOW PROCESSLIST
SHOW OPEN TABLES WHERE In_use > 0;
SHOW OPEN TABLES WHERE `Table` LIKE '%[TABLE_NAME]%' AND `Database` LIKE '[DBNAME]' AND In_use > 0;

will show all process currently running, including process that has acquired lock on tables.
```

##### Ranger Mysql DB DUMP
```mysql
mysqldump --databases ranger -u USERNAME -p > /tmp/ranger.original.mysql
env GZIP=-9 tar cvzf  ranger-db.tar.gz /tmp/ranger.original.mysql
 
# ls -ltrh ranger-db.tar.gz

# Restore
mysql -u root -proot
create database ranger1;
mysqldump -u root -proot ranger1 < ranger-db.sql
```

