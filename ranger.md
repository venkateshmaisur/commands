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

## RESET MYSQL Ranger passsword
```
echo -n 'PASSWORD{USERNAME}' | md5sum
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

## manual
mysql -u root -proot
create database ranger;
CREATE USER 'rangerdba'@'RANGER-HOSTNAME' IDENTIFIED BY 'admin';
grant all privileges on ranger.* to 'rangerdba'@'RANGER-HOSTNAME' identified by 'admin' with grant option;
FLUSH PRIVILEGES;
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

## Ranger kerberos troubleshooitng
LOGIN IN RANGER NODE
```
kinit -kt /etc/security/keytabs/rangeradmin.service.keytab $(klist -kt /etc/security/keytabs/rangeradmin.service.keytab |sed -n "4p"|cut -d ' ' -f7)
curl -ik --negotiate -u : 'http://$(hostname -f):6080/service/public/v2/api/service'
curl -ik --negotiate -u : 'http://$(hostname -f):6080/service/public/v2/api/service?serviceName=<CLUSTERNAME>_nifi&serviceType=nifi&isEnabled=true'
ll /etc/security/keytabs/spnego.service.keytab
klist -kt /etc/security/keytabs/spnego.service.keytab
kvno $(klist -kt /etc/security/keytabs/spnego.service.keytab |sed -n "4p"|cut -d ' ' -f7)
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

```

 File "/usr/lib/ambari-agent/lib/resource_management/libraries/script/config_dictionary.py", line 73, in __getattr__
    raise Fail("Configuration parameter '" + self.name + "' was not found in configurations dictionary!")
resource_management.core.exceptions.Fail: Configuration parameter 'xasecure.policymgr.clientssl.keystore.password' was not found in configurations dictionary!

xasecure.policymgr.clientssl.keystore=/etc/security/serverKeys/atlas-tagsync-keystore.jks
xasecure.policymgr.clientssl.keystore.credential.file=jceks://file{{atlas_tagsync_credential_file}}
xasecure.policymgr.clientssl.keystore.password=admin
xasecure.policymgr.clientssl.truststore=/etc/security/serverKeys/atlas-tagsync-mytruststore.jks
xasecure.policymgr.clientssl.truststore.credential.file=jceks://file{{atlas_tagsync_credential_file}}
xasecure.policymgr.clientssl.truststore.password=admin
```

```
Can you check the java version?
Also, if all AD Certs are added still you are facing the issue, Follow below steps:

Please make below changes and let me know the result.

On ranger admin node, go to the file /usr/hdp/current/ranger-admin/ews/ranger-admin-services.sh

Search fo the start() function and modify the nohup java line adding the string "-Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true", so this should look like this


######
start() {
SLEEP_TIME_AFTER_START=5
nohup java -Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true -Dproc_rangeradmin ${JAVA_OPTS} ${DB_SSL_PARAM} -Dservername=${SERVER_NAME} -Dlogdir=${RANGER_ADMIN_LOG_DIR} -Dcatalina.base=${XAPOLICYMGR_EWS_DIR} -cp "${XAPOLICYMGR_EWS_DIR}/webapp/WEB-INF/classes/conf:${XAPOLICYMGR_EWS_DIR}/lib/*:${RANGER_JAAS_LIB_DIR}/*:${RANGER_JAAS_CONF_DIR}:${JAVA_HOME}/lib/*:${RANGER_HADOOP_CONF_DIR}/*:$CLASSPATH" org.apache.ranger.server.tomcat.EmbeddedServer > ${RANGER_ADMIN_LOG_DIR}/catalina.out 2>&1 &
VALUE_OF_PID=$!
echo "Starting Apache Ranger Admin Service"
sleep $SLEEP_TIME_AFTER_START
if ps -p $VALUE_OF_PID > /dev/null
#####

if it still doesnt work, try to get below details:

nslookup ss0001.navair.navy.mil
openssl s_client -connect ss0001.navair.navy.mil:636 -showcerts
keytool -list -keystore /etc/ranger/admin/conf/ranger-admin-truststore.jks -v 
```
## HSM

```sh
 Luna client folder need open permission for kms account.

1. make sure libLunaAPI.so file is present under $JAVA_HOME/jre/lib/ext/
copy libLunaAPI.so from lunaclient lib folder /usr/safenet/lunaclient/jsp/lib

2. LunaProvider.jar also present right under lib

$ sudo cp -p /usr/safenet/lunaclient/jsp/lib/LunaProvider.jar /usr/lib/jvm/java/lib/

$ sudo vim /usr/lib/jvm/java/jre/lib/security/java.security
security.provider.10=com.safenetinc.luna.provider.LunaProvider
$ sudo chmod -R 655 /usr/safenet

## Set env variable:
export PATH=/usr/lib/jvm/java/bin/:$PATH 
export JAVA_HOME=/usr/lib/jvm/java
bash -x ./HSMMK2DB.sh LunaProvider HAHSMMSLA
```
 http://techdocs.broadcom.com/content/broadcom/techdocs/us/en/ca-enterprise-software/layer7-api-management/api-gateway/9-2/install-configure-upgrade/configure-the-appliance-gateway/configure-hardware-security-modules-hsm/configure-the-safenet-luna-sa-hsm.html
 
 https://cwiki.apache.org/confluence/display/RANGER/Ranger+KMS+Luna+HSM+Support
 
 ## Delete Ranger user from cli
 
 ```sh
  Note : This utility can be used to delete users or groups, To delete groups refer below given first command and to delete users refer second command.","info")
 Usage(Group delete): deleteUserGroupUtil.py -groups <group file path> -admin <ranger admin user> -url <rangerhosturl> [-force] [-sslCertPath <cert path>] [-debug]","info")
 Usage(User delete): deleteUserGroupUtil.py -users <user file path> -admin <ranger admin user> -url <rangerhosturl> [-force] [-sslCertPath <cert path>] [-debug]","info")
 -groups: Delete groups specified in the given file","info")
 -users: Delete users specified in the given file","info")
 -admin: Ranger Admin user ID","info")
 -force: Force delete users/groups, even if they are referenced in policies","info")
 -url: Ranger Admin URL","info")
 -sslCertPath: Filepath to ssl certificate to use when Ranger Admin uses HTTPS","info")
 -debug: Enables debugging","info")
 ```
 
 HDP 3.1.5
 ```sh
 [root@c174-node2 ~]# python /usr/hdp/3.1.5.0-152/ranger-admin/deleteUserGroupUtil.py -users /root/users.txt  -admin admin -url http://c174-node2.squadron.support.hortonworks.com:6080 -force -debug
Enter Ranger Admin password :
Request URL = http://c174-node2.squadron.support.hortonworks.com:6080/service/xusers/users/userName/pravin?forceDelete=true
Response    = HTTP/1.1 204 No Content
Set-Cookie: RANGERADMINSESSIONID=9615E822E6AF1F87D2F16A9D6C3B6D73; Path=/; HttpOnly
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'none'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; connect-src 'self'; img-src 'self'; style-src 'self' 'unsafe-inline';font-src 'self'
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Content-Type-Options: nosniff
Date: Wed, 12 Feb 2020 08:41:02 GMT
Server: Apache Ranger
2020-02-12 08:41:02,648  [I] Deleted user : pravin
2020-02-12 08:41:02,648  [I] Number of user deleted : 1
 ```
 
 HDP 2.6.5
 
 ```sh
 [root@c374-node2 ~]# python /usr/hdp/2.6.5.0-292/ranger-admin/deleteUserGroupUtil.py -users /root/users.txt  -admin admin -url http://172.25.37.128:6080 -force -debug
Enter Ranger Admin password :
Request URL = http://172.25.37.128:6080/service/xusers/users/userName/ambari?forceDelete=true
Response    = HTTP/1.1 204 No Content
Server: Apache-Coyote/1.1
Set-Cookie: RANGERADMINSESSIONID=17A13877C5CDFD717F03D60B1618FA39; Path=/; HttpOnly
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000
Date: Wed, 12 Feb 2020 08:45:21 GMT
2020-02-12 08:45:22,032  [I] Deleted user : ambari
Request URL = http://172.25.37.128:6080/service/xusers/users/userName/registersssd?forceDelete=true
Response    = HTTP/1.1 204 No Content
Server: Apache-Coyote/1.1
Set-Cookie: RANGERADMINSESSIONID=A73641D2B12B2FE06F32FDF0F4F6CB88; Path=/; HttpOnly
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000
Date: Wed, 12 Feb 2020 08:45:21 GMT
2020-02-12 08:45:22,086  [I] Deleted user : registersssd
2020-02-12 08:45:22,087  [I] Number of user deleted : 2
[root@c374-node2 ~]# cat /root/users.txt
ambari
registersssd
 ```
 
 Ref: https://issues.apache.org/jira/browse/RANGER-806
 
 ```
 java -cp '/usr/hdp/current/ranger-usersync/lib/*' org.apache.ranger.credentialapi.buildks list -provider jceks://file/etc/ranger/kms/rangerkms.jceks

java -cp '/usr/hdp/current/ranger-usersync/lib/*' org.apache.ranger.credentialapi.buildks get ranger.ks.jdbc.password -provider jceks://file/etc/ranger/kms/rangerkms.jceks
```

### Ranger tagsync triage
```

Login into tagsync node, share me output of "hostname -f" and tar file
hostname -f
tar -cvzf tagsync-config-logs.tar.gz /etc/ranger/tagsync/conf/* /var/log/ranger/tagsync/tagsync.log /var/log/ranger/tagsync/tagsync.out

Login into kafka node:

hostname -f
ps -aux| grep kafka
ls -ltr /etc/security/keytabs/
klist -kt /etc/security/keytabs/kafka.service.keytab

```
