# Ranger Commands

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
