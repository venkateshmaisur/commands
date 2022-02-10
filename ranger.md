# Ranger Commands


![Ranger Troubleshooting](https://github.com/bhagadepravin/commands/blob/master/Ranger%20troubleshooting.png)


## cdp-dc
```bash
export RANGER_ADMIN_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*RANGER_ADMIN| tail -1)
env GZIP=-9  tar -cvzf ranger-admin.tar.gz $RANGER_ADMIN_PROCESS_DIR /var/log/ranger/admin/ranger-admin-`hostname -f`-ranger.log /var/log/ranger/admin/catalina.out /var/log/ranger/admin/ranger_db_patch.log
```

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

### Reset password on RHEL 7.5
systemctl stop mariadb
mysqld_safe --skip-grant-tables &
mysql -u root
> use mysql;
> UPDATE user SET password=PASSWORD('root') WHERE User='root' AND Host = 'localhost';
> FLUSH PRIVILEGES;

```

## CDP Ranger AD authentication
```
ranger.authentication.method = ACTIVE_DIRECTORY
ranger.ldap.ad.url = ldap://10.113.243.16:389
ranger.ldap.ad.bind.dn = test1@SUPPORT.COM
ranger.ldap.ad.bind.password = hadoop12345!
ranger.ldap.ad.domain = support.com
ranger.ldap.ad.base.dn = OU=hortonworks,DC=SUPPORT,DC=COM
ranger.ldap.ad.referral = ignore
ranger.ldap.ad.user.searchfilter = (&(sAMAccountName={0})(memberOf=CN=support,OU=groups,OU=hortonworks,DC=SUPPORT,DC=COM))

```
## CDP Ranger LDAP authentication
```
ranger.authentication.method     LDAP
ranger.ldap.url 				ldap://10.17.103.192:389
ranger.ldap.bind.dn 	        cn=Manager,dc=pravin,dc=com
ranger.ldap.bind.password       
ranger.ldap.user.dnpattern      uid={0},ou=users,dc=pravin,dc=com
ranger.ldap.user.searchfilter   uid={0}
ranger.ldap.group.searchbase    ou=groups,dc=pravin,dc=com
ranger.ldap.group.searchfilter
ranger.ldap.group.roleattribute
ranger.ldap.base.dn       	    dc=pravin,dc=com
ranger.ldap.referral 			ignore
```

## CDP Ranger Usersync AD

```

echo "10.113.243.16   ad-support-01.SUPPORT.COM"  >> /etc/hosts
# Check the jks file
$ export RANGER_USERSYNC_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*RANGER_USERSYNC| tail -1)
$ grep -a2 ranger.usersync.truststore.file $RANGER_USERSYNC_PROCESS_DIR/conf/ranger-ugsync-site.xml

# It must be below path
/var/lib/cloudera-scm-agent/agent-cert/cm-auto-global_truststore.jks

# Get Truststore password 
https://CM-hostname:7183/api/v40/certs/truststorePassword

# Get AD cert into a file: 
$ echo -n | openssl s_client -connect AD-hostname:636 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/ADcert.crt
# You can also check if AD has chain certificate or not, you can add RootCA certificare into to the truststore, if customer do not want to add AD server cert:
$ openssl s_client -connect AD-hostname:636 -showcerts


#Import cert into cm-auto-global_truststore.jks 
$ /usr/java/jdk1.8.0_232-cloudera/bin/keytool -import -keystore /var/lib/cloudera-scm-agent/agent-cert/cm-auto-global_truststore.jks -file /tmp/ADcert.crt -alias adcert -storepass <PASSWORD>

#Use below to check if its added or not
$ /usr/java/jdk1.8.0_232-cloudera/bin/keytool -list -keystore /var/lib/cloudera-scm-agent/agent-cert/cm-auto-global_truststore.jks
```

```
ranger.usersync.ldap.url = ldap://10.113.243.16:389
ranger.usersync.ldap.binddn = test1@SUPPORT.COM
ranger.usersync.ldap.ldapbindpassword = hadoop12345!
ranger.usersync.ldap.searchBase = OU=hortonworks,DC=support,DC=com
ranger.usersync.ldap.user.searchbase = OU=squadron_users,OU=users,OU=hortonworks,DC=support,DC=com
ranger.usersync.ldap.user.searchscope = sub
ranger.usersync.ldap.user.objectclass = person
ranger.usersync.ldap.user.searchfilter = Empty all users
ranger.usersync.ldap.user.nameattribute = sAMAccountName
ranger.usersync.ldap.referral
ranger.usersync.ldap.user.groupnameattribute = sAMAccountName
ranger.usersync.group.usermapsyncenabled = check
ranger.usersync.group.searchenabled
ranger.usersync.group.searchbase = OU=groups,OU=hortonworks,DC=support,DC=com
ranger.usersync.group.searchscope = sub
ranger.usersync.group.objectclass = group
ranger.usersync.group.searchfilter = Empty all users
ranger.usersync.group.nameattribute  = cn
ranger.usersync.group.memberattributename = member
```


## dump
```sql
mysqldump ranger -u root -p > ranger.sql
env GZIP=-9 tar cvzf ranger-dump.tar.gz ranger.sql

If the file size is more than 10gb use below cmd and attach the dump by excluding table=ranger.x_trx_log

mysqldump ranger -u root -p --ignore-table=ranger.x_trx_log > ranger_trx.sql
env GZIP=-9 tar cvzf ranger-dump-truncated.tar.gz ranger_trx.sql


mysqldump ranger -u root -p --ignore-table=ranger.x_trx_log --ignore-table=ranger.x_auth_sess > ranger_trx.sql
env GZIP=-9 tar cvzf ranger-dump-truncated.tar.gz ranger_trx_new.sql /etc/my.cnf

while restoring dump to lab make sure you create those two tables manually after db is restored
```

Ranger llap permissions:
```
 Hive to enforce urlauthorization, llap service will try to impersonate the user and execute liststatus hdfs API call on the location to confirm the impersonated user has RWX permissions on that location, this operation is re-cursive, so location mentioned  '/hadoop/tmp' should be either owned by the user 'hive'  or have RWX permission on the directory and all the files under that path. 

confirm with below commands: 
# hdfs dfs -ls -d /hadoop/tmp
# hdfs dfs -ls /hadoop/tmp

- To successful do the above operation of liststatus, as LLAP is impersonating the user, core-site/hive-site should be configured with proxyuser.hive.host/groups to include FQDN/IP of LLAP host and '*'

Check proxyuser properties with below command executed at beeline prompt (LLAP connection): 

set hadoop.proxyuser.hive.hosts;
set hadoop.proxyuser.hive.groups;

Above command output should have LLAP hostname/IP for hadoop.proxyuser.hive.hosts. And group name of user (hive) / * for hadoop.proxyuser.hive.groups


- Impersonation error for second case should be logged to file /var/log/hive/hive-server2-interactive.err (review this log and above configs to confirm impersonation issues). 

Error something like below should be logged in case of second issue: 

Caused by: org.apache.hadoop.ipc.RemoteException(org.apache.hadoop.security.authorize.AuthorizationException): Unauthorized connection for super-user: hive/c316-node4.coelab.cloudera.com@COELAB.CLOUDERA.COM from IP 172.25.34.193
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


###### RangerKMS
CREATE DATABASE rangerkms;
CREATE USER 'rangerkms'@'%' IDENTIFIED BY 'cloudera';
CREATE USER 'rangerkms'@'localhost' IDENTIFIED BY 'cloudera';
CREATE USER 'rangerkms'@'pravincredit-1.pravincredit.root.hwx.site' IDENTIFIED BY 'cloudera';
GRANT ALL PRIVILEGES ON rangerkms.* TO 'rangerkms'@'%';
GRANT ALL PRIVILEGES ON rangerkms.* TO 'rangerkms'@'localhost';
GRANT ALL PRIVILEGES ON rangerkms.* TO 'rangerkms'@'pravincredit-1.pravincredit.root.hwx.site';
grant all privileges on *.* to 'rangerkms'@'pravincredit-1.pravincredit.root.hwx.site' identified by 'cloudera' with grant option;
FLUSH PRIVILEGES;
```
## Oracle
```
SQLException : SQL state: 42000 java.sql.SQLSyntaxErrorException: ORA-00955: name is already used by an existing object
 ErrorCode: 955
SQLException : SQL state: 42000 java.sql.SQLSyntaxErrorException: ORA-00955: name is already used by an existing object


insert into x_db_version_h (id,version, inst_at, inst_by, updated_at, updated_by,active) values ( X_DB_VERSION_H_SEQ.nextval,'030', sysdate, 'Ranger 1.1.0.3.2.0.0-520', sysdate, 'c4232-node2.coelab.cloudera.com','Y');
commit;

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


mysqldump ranger -u root -p --ignore-table=ranger.x_trx_log --ignore-table=ranger.x_auth_sess > ranger_trx_new.sql
env GZIP=-9 tar cvzf ranger-dump-truncated_new.tar.gz ranger_trx_new.sql /etc/my.cnf

# restore
mysql -u root -proot ranger1 < ranger_trx.sql
nohup sh -c "cat ranger_trx.sql | grep -v 'INSERT INTO \\\`x_auth_sess\\\`' | mysql -u root -proot ranger1" &
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

## Nifi Ranger logging

```
1. Enable debug for nifi ranger authorizer class in logback.xml as below:

Ambari UI -> Nifi - > Configs -> Advanced -> Advanced nifi-node-logback-env -> Template for logback.xml

Search for  <logger name="org.apache.nifi" level="INFO"
add below to enable ranger.authorization logging

<logger name="org.apache.nifi.ranger.authorization" level="DEBUG"/>


Expected logging:

2020-03-05 08:08:42,845 INFO [main] o.a.ranger.plugin.util.PolicyRefresher PolicyRefresher(serviceName=c2232_nifi): found updated version. lastKnownVersion=-1; newVersion=2
```


Ranger llap
```
 Hive to enforce urlauthorization, llap service will try to impersonate the user and execute liststatus hdfs API call on the location to confirm the impersonated user has RWX permissions on that location, this operation is re-cursive, so location mentioned  '/hadoop/tmp' should be either owned by the user 'hive'  or have RWX permission on the directory and all the files under that path. 

confirm with below commands: 
# hdfs dfs -ls -d /hadoop/tmp
# hdfs dfs -ls /hadoop/tmp

- To successful do the above operation of liststatus, as LLAP is impersonating the user, core-site/hive-site should be configured with proxyuser.hive.host/groups to include FQDN/IP of LLAP host and '*'

Check proxyuser properties with below command executed at beeline prompt (LLAP connection): 

set hadoop.proxyuser.hive.hosts;
set hadoop.proxyuser.hive.groups;

Above command output should have LLAP hostname/IP for hadoop.proxyuser.hive.hosts. And group name of user (hive) / * for hadoop.proxyuser.hive.groups


- Impersonation error for second case should be logged to file /var/log/hive/hive-server2-interactive.err (review this log and above configs to confirm impersonation issues). 

Error something like below should be logged in case of second issue: 

Caused by: org.apache.hadoop.ipc.RemoteException(org.apache.hadoop.security.authorize.AuthorizationException): Unauthorized connection for super-user: hive/c316-node4.coelab.cloudera.com@COELAB.CLOUDERA.COM from IP 172.25.34.193
```

# Ranger Usersync CDP-DC troubleshooting:

```
#openssl s_client -connect localhost:5151  > /tmp/usersync.txt
export RANGER_USERSYNC_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*RANGER_USERSYNC| tail -1)
env GZIP=-9  tar -cvzf ranger-usersync.tar.gz $RANGER_USERSYNC_PROCESS_DIR /var/log/ranger/usersync/usersync-`hostname -f`-ranger.log /tmp/usersync.txt
```

Please enable debug on Ranger usersync service
```
Goto -> Ranger -> Configuration -> Under Filters click on (Ranger usersync and then Logs)  -> set Ranger Usersync Logging Threshold to DEBUG

Save and restart Usersync service only
Goto Ranger -> Instances -> Select Ranger Usersync  -> Action for Selected -> Restart
```

### usersync ldap

```bash
ranger.usersync.ldap.url : ldap://10.17.102.145:389
ranger.usersync.ldap.binddn : cn=Manager,dc=pravin,dc=com
ranger.usersync.ldap.ldapbindpassword : Welcome
ranger.usersync.ldap.searchBase : dc=pravin,dc=com
ranger.usersync.ldap.user.searchbase : dc=pravin,dc=com
ranger.usersync.ldap.user.objectclass : posixAccount
ranger.usersync.ldap.user.searchfilter : uid={0}
ranger.usersync.ldap.user.nameattribute : uid
ranger.usersync.ldap.user.groupnameattribute : cn
ranger.usersync.group.usermapsyncenabled : Checked
ranger.usersync.user.searchenabled : (by default set to false)
ranger.usersync.group.searchenabled : (enabled by default)
ranger.usersync.group.searchbase : dc=pravin,dc=com
ranger.usersync.group.objectclass : groupOfNames
ranger.usersync.group.searchfilter : 
ranger.usersync.group.nameattribute : cn
ranger.usersync.group.memberattributename : member
ranger.usersync.group.search.first.enabled  : (by default set to false)



We have below two options:
ranger.usersync.user.searchenabled
ranger.usersync.group.search.first.enabled


ranger.usersync.ldap.user.searchscope : base

2020-11-04 15:53:17,330 INFO org.apache.ranger.ldapusersync.process.LdapUserGroupBuilder: LdapUserGroupBuilder initialization completed with --  
ldapUrl: ldap://10.17.102.145:389,  ldapBindDn: cn=Manager,dc=pravin,dc=com,  ldapBindPassword: ***** ,  ldapAuthenticationMechanism: simple,  
searchBase: dc=pravin,dc=com,  userSearchBase: [dc=pravin,dc=com],  userSearchScope: 2,  userObjectClass: posixAccount,  userSearchFilter: null,  
extendedUserSearchFilter: (objectclass=posixAccount),  userNameAttribute: uid,  userSearchAttributes: [uid],  userGroupNameAttributeSet: null,  
pagedResultsEnabled: true,  pagedResultsSize: 500,  groupSearchEnabled: true,  groupSearchBase: [dc=pravin,dc=com],  groupSearchScope: 2,  
groupObjectClass: groupOfNames,  groupSearchFilter: null,  extendedGroupSearchFilter: (&(objectclass=groupOfNames)(|(member={0})(member={1}))),  
extendedAllGroupsSearchFilter: (&(objectclass=groupOfNames)),  groupMemberAttributeName: member,  groupNameAttribute: cn, 
groupSearchAttributes: [member, cn], groupSearchFirstEnabled: false, userSearchEnabled: false,  ldapReferral: ignore

if you want all user to be synced, keep the property empty or use "uid=*" or (objectclass=posixAccount)
```

# Ranger Admin CDP-DC troubleshooting:

### Enable Ranger Debug

`CM --> Ranger -> Configuration -> Under Filter section Select ( Ranger Admin & Logs ) -> Ranger Admin Logging Threshold -> DEBUG -> Save -> Instances -> Select Ranger Admin -> Action for Selected Restart`

Once service is restarted login in to Ranger node:
```
export RANGER_ADMIN_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*RANGER_ADMIN| tail -1)
env GZIP=-9  tar -cvzf ranger-admin.tar.gz $RANGER_ADMIN_PROCESS_DIR /var/log/ranger/admin/ranger-admin-`hostname -f`-ranger.log /var/log/ranger/admin/catalina.out /var/log/ranger/admin/ranger_db_patch.log
```
attach ranger-admin.tar.gz


###### CDP ranger getting password from alias
```
usersync.ssl.key.password
ranger.usersync.policymgr.password
ranger.usersync.ldap.bindalias
To list alias present in the jceks file

1) Get the latest process directory generated by CM which is used by Ranger Usersync process.

Do ps -ef | grep rangerusersync
Check for "/var/run/cloudera-scm-agent/process/<ID>-ranger-RANGER_USERSYNC/" in the classpath
2) Open "/var/run/cloudera-scm-agent/process/<ID>-ranger-RANGER_USERSYNC/proc.json" file and export HADOOP_CREDSTORE_PASSWORD value.

export HADOOP_CREDSTORE_PASSWORD=<PASSWORD>
3) Then run below command to get the aliases present in the jceks.

${JAVA_HOME}/bin/java -cp "/opt/cloudera/parcels/CDH/lib/ranger-usersync/lib/*" org.apache.ranger.credentialapi.buildks list -provider jceks://file/var/run/cloudera-scm-agent/process/<ID>-ranger-RANGER_USERSYNC/conf/rangerusersync.jceks
To get password from the alias,

${JAVA_HOME}/bin/java -cp "/opt/cloudera/cm/lib/*" com.cloudera.enterprise.crypto.GenericKeyStoreTypePasswordExtractor "jceks" "/var/run/cloudera-scm-agent/process/<ID>-ranger-RANGER_USERSYNC/conf/rangerusersync.jceks" "usersync.ssl.key.password"
```


##### Ranger HDP 3.x masking troubleshooting
```
1. login into Kafka node

Kinit with kafka keytab
 /usr/hdp/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server  c274-node2.supportlab.cloudera.com:6667 --topic ATLAS_ENTITIES  --consumer-property security.protocol=SASL_PLAINTEXT

 also new tab:

 cat /tmp/client.properties
security.protocol=SASL_PLAINTEXT
/usr/hdp/current/kafka-broker/bin/kafka-consumer-groups.sh --describe --group ranger_entities_consumer --bootstrap-server c274-node2.supportlab.cloudera.com:6667 --command-config /tmp/client.properties

2. Login into Ranger database;

use <ranger-database>
# run below sql query, "test" is table which we are going to create and tag it using masking policy:
2.a)
select * from x_service_resource where service_resource_elements_text like '%test%'\G

3. Login into hive node:
create table t1 (x int);
insert into t1 values (1), (3), (2), (4);
select x from t1 order by x desc;


4. Login into Atlas tag the entity, you will also see logging in Step 1.

5. In Step 2, rerun the query:

Look for "tags_text" which should not be null. it should have tag details, if it has meaning tag are getting propogating, it takes 30 sec to propogate ateast.

6. Rerun the beeline query to check masking policy is working or not:
select x from t1 order by x desc;


7. If its not working lets collect below details.

a. get step 1 output
b. Get step 2 output
c. get output of below cmd:

cat /tmp/client.properties
security.protocol=SASL_PLAINTEXT
/usr/hdp/current/kafka-broker/bin/kafka-consumer-groups.sh --describe --group ranger_entities_consumer --bootstrap-server c274-node2.supportlab.cloudera.com:6667 --command-config /tmp/client.properties

d. get ranger tagsync log file.
```


###### Ranger Knox Plugin troubleshooting

```
*. Debug on Ranger Knox Plugin
Modify the gateway-log4j.properties like below, restart Knox and review the ranger Knox plugin log in ranger.knoxagent.log

#Ranger Knox Plugin debug
ranger.knoxagent.logger=DEBUG,console,KNOXAGENT
ranger.knoxagent.log.file=ranger.knoxagent.log
log4j.logger.org.apache.ranger=${ranger.knoxagent.logger}
log4j.additivity.org.apache.ranger=false
log4j.appender.KNOXAGENT =org.apache.log4j.DailyRollingFileAppender
log4j.appender.KNOXAGENT.File=${app.log.dir}/${ranger.knoxagent.log.file}
log4j.appender.KNOXAGENT.layout=org.apache.log4j.PatternLayout
log4j.appender.KNOXAGENT.layout.ConversionPattern=%d{ISO8601} %p %c{2}: %m%n %L
log4j.appender.KNOXAGENT.DatePattern=.yyyy-MM-dd

* You need to access something through Knox URL to generate the loggging for ranger.knoxagent.log
* In kerberos env, knox conf must have core-site.xml with below entry

cat core-site.xml
  <configuration  xmlns:xi="http://www.w3.org/2001/XInclude">
    <property>
      <name>hadoop.security.authentication</name>
      <value>kerberos</value>
    </property>
  </configuration>%
  
  * In debug logs if you see below error:

+++
 1302021-04-01 15:37:43,746 DEBUG util.RangerSslHelper: RangerSslHelper{keyStoreAlias=sslKeyStore, keyStoreFile=null, keyStoreType=jks, keyStoreURL=null, trustStoreAlias=sslTrustStore, trustStoreFile=null, trustStoreType=jks, trustStoreURL=null}
 ++++
 
 Meaning its not picking the jks files. due to misconfig, check for below file

grep -a2 ranger.plugin.knox.policy.rest.ssl.config.file *
grep: descriptors: Is a directory
ranger-knox-security.xml-
ranger-knox-security.xml-    <property>
ranger-knox-security.xml:      <name>ranger.plugin.knox.policy.rest.ssl.config.file</name>
ranger-knox-security.xml-      <value>/usr/hdf/current/knox-server/conf/ranger-policymgr-ssl.xml</value>
ranger-knox-security.xml-    </property>

Below error can be ignored:
+++
 1302021-04-01 15:37:43,751 ERROR utils.RangerCredentialProvider: Unable to get the Credential Provider from the Configuration
 72java.lang.IllegalArgumentException: The value of property hadoop.security.credential.provider.path must not be null
 +++
 
 * If see below error in gateway.log while accessing any url through knox:

++++++
2021-04-06 12:46:59,322 ERROR knox.gateway (GatewayServlet.java:service(146)) - Gateway processing failed: javax.servlet.ServletException: java.lang.NoClassDefFoundError: com/google/common/base/MoreObjects
++++++

a jar is missing
Solution:
find /usr/hdf/3.5.1.0-17/ -name guava-25.1-jre.jar

cp /usr/hdf/3.5.1.0-17/ranger-knox-plugin/lib/ranger-knox-plugin-impl/guava-25.1-jre.jar  /usr/hdf/3.5.1.0-17/knox/ext/ranger-knox-plugin-impl/
cp /usr/hdf/3.5.1.0-17/ranger-knox-plugin/lib/ranger-knox-plugin-impl/guava-25.1-jre.jar  /usr/hdf/3.5.1.0-17/ranger-knox-plugin/lib/ranger-knox-plugin-impl/

for any 500,404 error while accessing the URL, check gateway.log file
```
### Ranger group role assignment

```
Check if customer added below property and restarted Ranger admin and usersync service.

Add a property in safety valve under ranger-admin-site "Ranger Admin Advanced Configuration Snippet (Safety Valve) for conf/ranger-admin-site.xml"

ranger.support.for.service.specific.role.download=true

```


### delete the user/groups:
```
Ref: https://issues.apache.org/jira/browse/RANGER-806

You just need to have a file that has details of users/groups. on a new line.

vi /tmp/group.txt

groupname1
groupname2
etc

Example: python /opt/cloudera/parcels/CDH-7.1.5-1.cdh7.1.5.p0.7431829/lib/ranger-admin/deleteUserGroupUtil.py -groups /tmp/group.txt -admin admin -url https://pravin-1.pravin.root.hwx.site:6182 -p -d -sslCertPath /var/run/cloudera-scm-agent/process/490-ranger-RANGER_USERSYNC/cm-auto-in_cluster_ca_cert.pem

# usage 

2021-04-19 08:17:51,545  [I] Usage(Group delete): deleteUserGroupUtil.py -groups <group file path> -admin <ranger admin user> -url <rangerhosturl> [-force] [-sslCertPath <cert path>] [-debug]
2021-04-19 08:17:51,545  [I] Usage(User delete): deleteUserGroupUtil.py -users <user file path> -admin <ranger admin user> -url <rangerhosturl> [-force] [-sslCertPath <cert path>] [-debug]
2021-04-19 08:17:51,545  [I] -groups: Delete groups specified in the given file
2021-04-19 08:17:51,545  [I] -users: Delete users specified in the given file
2021-04-19 08:17:51,545  [I] -admin: Ranger Admin user ID
2021-04-19 08:17:51,545  [I] -force: Force delete users/groups, even if they are referenced in policies
2021-04-19 08:17:51,545  [I] -url: Ranger Admin URL
2021-04-19 08:17:51,546  [I] -sslCertPath: Filepath to ssl certificate to use when Ranger Admin uses HTTPS
2021-04-19 08:17:51,546  [I] -debug: Enables debugging



Note: without -force, user/group will be deleted, but its still see in the Ranger UI, as Visibility  HIDDEN.

 -force: Force delete users/groups, even if they are referenced in policies
```

## cdp debug
```
Please enable debug on Ranger Usersync and Ranger Admin service. Save and Restart the service.

1. Ranger admin:

enable debug logs for ranger admin by adding the below parameters in----> Ranger Admin Logging Advanced Configuration Snippet (Safety Valve)

logs.log4j.category.org.apache.ranger.biz.XUserMgr=debug,RFA
log4j.additivity.org.apache.ranger.biz.XUserMgr=false


2. Ranger Usersync:

Goto CM -> Ranger -> configuration -> Ranger Usersync Logging Threshold -> DEBUG

Save and restart the service.


Please attach the Usersync and Ranger admin logs.
```

### Usersync ssl debug in cdp

```
CM -> Ranger -> configuration -> search for "Ranger Usersync Environment Advanced Configuration Snippet (Safety Valve)"
Key   = CSD_JAVA_OPTS
value = -Djavax.net.debug=ssl
Save and restart Usersync service.
Get the latest process dir output:

export RANGER_USERSYNC_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*RANGER_USERSYNC| tail -1) 
env GZIP=-9 tar -cvzf ranger-usersync.tar.gz $RANGER_USERSYNC_PROCESS_DIR 
```

### External Table
```
please find the various requirements when creating external tables in Hive. It also captures a few errors if you do not have certain policies or permissions.

When creating External Tables with location clause, one of the following additional access is required (1) or (2)
(1) Users should have direct read and write access to the HDFS location
This can be provided through an appropriate HDFS POSIX permission, HDFS ACL, or HDFS Policy in Ranger.
(2) A URL policy should be in place in Ranger Hadoop SQL policies that provide users with read and write permissions on the HDFS location defined for the table
If the URL policy is missing the table creation might throw an exception like “FAILED: HiveAccessControlException Permission denied: user” with access enforcer as ranger-acl
Make sure that the URL defined in Ranger does not have a trailing “/”. If there is one, then the table creation would fail with “Permission denied”. This is currently a known issue - CDPD-29489
Even if the URL policy is in place, based on the access for user “hive” on the HDFS directory defined in location, the table creation may still fail with - “org.apache.hadoop.security.AccessControlException Permission denied: user=hive”. See below for more details.
If all the subdirectories are not present, then the user “hive” should have READ, WRITE and EXECUTE privileges on the existing directories on the path as it would then create the necessary sub-directories
If all the data directories and the data files are pre-existing with required permissions for the kerberos user, still the user “hive” should have READ and EXECUTE privileges on the entire path defined in HDFS location for the table
The required access for user “hive” on either case listed above can be provided through an appropriate HDFS POSIX permission, HDFS ACL, or HDFS Policy in Ranger.
If all the subdirectories and/or data files exist on the the HDFS location defined for the table but those are not owned by the user (whose kerberos credentials are used), then make sure that the configuration "ranger.plugin.hive.urlauth.filesystem.schemes" is set to "file:" and not "hdfs:,file:" (which is the default) in both Hive and Hive on Tez services.
Without this even with a URL policy present for the user, you will get "Permission denied: user [<user>] does not have [ALL] privilege" error in Ranger that is enforced by Hadoop-acl.
```

### Ranger tagsync troubleshooting
```sh


1. Enable tagsync debug and restart tagsync
2. get the output of
/usr/hdp/current/kafka-broker/bin/kafka-consumer-groups.sh --describe --group ranger_entities_consumer --bootstrap-server kafka-broker:6667
3. login into ranger db and collect the output of
select * from x_tag;
4. tailf /var/log/ranger/tagsync/tagsync.log  | tee /tmp/tagsyncnew.log
5. login into atlas ui
create a new tag or use existing tag.. assign it to any hdfs_path entity ( for which there is no ranger policy, we will need to create a new policy)
6. on Active namnode:
ls -ltr /etc/ranger/c274_hadoop/policycache
tar -cvzf policybefore.tar.gz /etc/ranger/*_hadoop/policycache
7. In Ranger UI
Create a new tag sync policy for Step 5.
Once its created wait for 30 sec.
collect few more details once gain
Step 2, step 3.
8. On active namenode
ls -ltr /etc/ranger/c274_hadoop/policycache
tar -cvzf policyafter.tar.gz /etc/ranger/*_hadoop/policycache
9. login into Ranger node:
cd /var/log/ranger/admin/
attach the latest access_log.2021-11-12.log log file.
collect tagsync debug logs both tagsync.log, /tmp/tagsyncnew.log
10. Also get the audit screenshot of deny from Ranger UI.
```

### Ranger tagsync hive troubleshooting
```bash
1. Enable tagsync debug and restart tagsync service

2. get the output of
/usr/hdp/current/kafka-broker/bin/kafka-consumer-groups.sh --describe --group ranger_entities_consumer --bootstrap-server kafka-broker:6667 --security-protocol <protocol>

Wait for 5 min and rerun above cmd and share the output of both cmds

3. login into ranger db and collect the output of
select * from x_tag;

4. tailf /var/log/ranger/tagsync/tagsync.log  | tee /tmp/tagsyncnew.log

5. login into atlas ui
create a new tag or use existing tag.. assign it to any hive_column entity ( for which there is no ranger policy, we will need to create a new policy)

6. on any HS2 node:
ls -ltr /etc/ranger/c274_hive/policycache
tar -cvzf policybefore.tar.gz /etc/ranger/*_hadoop/policycache


7. login into Ranger node:
cd /var/log/ranger/admin/
attach the latest access_log.2021-11-12.log log file.

collect tagsync debug logs both tagsync.log, /tmp/tagsyncnew.log, along with tagsync configs, rest console outputs while performing action plan.
```
