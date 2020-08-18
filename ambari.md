# Ambari Known Issue

## Ambari KDC Credentails


```bash
curl -ivk -H "X-Requested-By: ambari" -u admin:admin -X POST -d '{ "Credential" : { "principal" : "admin/admin@EXAMPLE.COM", "key" : "PASSWORD", "type" : "persisted" } }' http://hostname.example.com:8080/api/v1/clusters/CLUSTERNAME/credentials/kdc.admin.credential 


curl -ik -u admin -H "X-Requested-By: ambari" -X DELETE  http://hostname.example.com:8080/api/v1/clusters/CLUSTERNAME/credentials/kdc.admin.credential 
```
## Ambari config.py

```sql
/var/lib/ambari-server/resources/scripts/configs.py -u admin -p admin -a get -t 8080 -l localhost -n PreProduction -c krb5-conf

/var/lib/ambari-server/resources/scripts/configs.py -t 1111 -s https -a get -l `hostname -f` -n ZEUS -c hadoop-env -u admin -p admin  
```

## Ambari LDAP

```bash
ambari-server setup-ldap --ldap-url=172.26.126.127:389 --ldap-user-class=person --ldap-user-attr=uid --ldap-group-class=groupofnames --ldap-ssl=false --ldap-secondary-url= ""--ldap-referral="" --ldap-group-attr=cn --ldap-member-attr=member --ldap-dn=dn --ldap-base-dn=dc=pravin,dc=com --ldap-bind-anonym=false --ldap-manager-dn=cn=Manager,dc=pravin,dc=com --ldap-manager-password=Welcome --ldap-save-settings

ambari-server restart
ambari-server sync-ldap --all

# Some extra filter
ambari.ldap.isConfigured
authentication.ldap.useSSL
authentication.ldap.primaryUrl
authentication.ldap.secondaryUrl
authentication.ldap.baseDn
authentication.ldap.bindAnonymously
authentication.ldap.managerDn
authentication.ldap.managerPassword
authentication.ldap.dnAttribute
authentication.ldap.usernameAttribute
authentication.ldap.username.forceLowercase
authentication.ldap.userBase
authentication.ldap.userObjectClass
authentication.ldap.groupBase
authentication.ldap.groupObjectClass
authentication.ldap.groupNamingAttr
authentication.ldap.groupMembershipAttr
authorization.ldap.adminGroupMappingRules
authentication.ldap.userSearchFilter
authentication.ldap.alternateUserSearchEnabled
authentication.ldap.alternateUserSearchFilter
authorization.ldap.groupSearchFilter
authentication.ldap.referral
authentication.ldap.pagination.enabled
authentication.ldap.sync.userMemberReplacePattern
authentication.ldap.sync.groupMemberReplacePattern
authentication.ldap.sync.userMemberFilter
authentication.ldap.sync.groupMemberFilter
ldap.sync.username.collision.behavior
```

## AMBARI LDAP using knox demo ldap
```
yum clean all
yum install openldap-clients -y

# KNOX DEMO LDAP

ldapsearch -h c174-node3.squadron.support.hortonworks.com -p 33389 -D uid=admin,ou=people,dc=hadoop,dc=apache,dc=org -w admin-password -b dc=hadoop,dc=apache,dc=org "(uid=admin)"

ambari-server setup-ldap --ldap-url=c174-node3.squadron.support.hortonworks.com:33389 --ldap-user-class=person --ldap-user-attr=uid --ldap-group-class=groupofnames --ldap-ssl=false --ldap-secondary-url= ""--ldap-referral="" --ldap-group-attr=cn --ldap-member-attr=member --ldap-dn=dn --ldap-base-dn=dc=hadoop,dc=apache,dc=org --ldap-bind-anonym=false --ldap-manager-dn=uid=admin,ou=people,dc=hadoop,dc=apache,dc=org --ldap-manager-password=admin-password --ldap-save-settings

echo "authentication.ldap.pagination.enabled=false" >> /etc/ambari-server/conf/ambari.properties

ambari-server restart
ambari-server sync-ldap --all
```

## Ambari Version mismatch

```sql
select repo_version_id, stack_id, version, display_name from repo_version; 
select * from host_version; 
update host_version set state='CURRENT' where repo_version_id='51' ; 
update host_version set state='INSTALLED' where repo_version_id='1'; 
```

## Ambari backup and restore
```sql
pg_dump -U ambari -f ambari.sql

create database ambarinew;
su - postgres
psql -d ambarinew -f /tmp/db_backup.sql

GRANT CONNECT ON DATABASE ambarinew TO ambari;
```

## Delete Kerberos principal from DB

```sql
backup ambari server 
select * from kerberos_principal_host where principal_name like 'oozie%'; 
delete from kerberos_principal_host where principal_name like 'ozzie%'; 
restart amabri server 
regenerate missing keytabs through ambari server. 
```
```sh
ambari 2.7.3
select * from kkp_mapping_service where kkp_id in (select kkp_id  from kerberos_keytab_principal where principal_name like 'zookeeper%');
```

```sh
CREATE TABLE kkp_mapping_service_BKP AS SELECT * FROM kkp_mapping_service; 
CREATE TABLE kerberos_keytab_principal_BKP AS SELECT * FROM kerberos_keytab_principal; 
CREATE TABLE kerberos_keytab_BKP AS SELECT * FROM kerberos_keytab; 
CREATE TABLE kerberos_principal_BKP AS SELECT * FROM kerberos_principal; 

DELETE FROM kkp_mapping_service; 
DELETE FROM kerberos_keytab_principal; 
DELETE FROM kerberos_keytab; 
DELETE FROM kerberos_principal; 
```

```
backup ambari server 
select *  from kerberos_principal where principal_name like 'yarn-ats-hbase%';
select *  from kerberos_keytab_principal where principal_name like 'yarn-ats-hbase%';
ambari=> delete from kkp_mapping_service where kkp_id in (select kkp_id from kerberos_keytab_principal where principal_name like 'yarn-ats-hbase%');
ambari=> delete  from kerberos_keytab_principal where principal_name like 'yarn-ats-hbase%';
ambari=> delete  from kerberos_principal where principal_name like 'yarn-ats-hbase%';
ambari-server restart
```

```
DELETE kkp_mapping_service FROM kkp_mapping_service INNER JOIN kerberos_keytab_principal ON kkp_mapping_service.kkp_id=kerberos_keytab_principal.kkp_id and kerberos_keytab_principal.principal_name='HTTP/ambari_server%';
DELETE FROM kerberos_keytab_principal WHERE principal_name='HTTP/ambari_server%';
DELETE FROM kerberos_principal WHERE principal_name='HTTP/ambari_server%'
```
## Kerberos cahce cleanup
```
1. Manually created ambari server keytab using below command

ktutil: add_entry -password -p service_pinc/cluster1@zyx.com -k 1 -e des3-cbc-sha1-kd
Password for vemkd/cluster1@abc.com:
ktutil: wkt /path_to_keytab_file/xyz.keytab

2. Then cleaned following directories /var/lib/ambari-agent/tmp and /var/lib/ambari-agent/cache on all host
3. Took the backup of ambari database and fired below queries
SELECT * FROM ambari.kerberos_principal WHERE cached_keytab_path IS NOT null;
update ambari.kerberos_principa set cached_keytab_path=NULL where principla_name=<>;
update ambari.kerberos_principa set cached_keytab_path=NULL where principla_name=HTTP%;
```

## POSTGRES CMDS

* Removing Hung or In-Progress Operations in Ambari

https://developer.ibm.com/hadoop/2015/10/29/removing-hung-progress-operations-ambari/

```sql
ambari=> select distinct status from host_role_command;
  status   
-----------
 ABORTED
 COMPLETED
 QUEUED
 FAILED
```

```sql
select task_id, role, role_command, status from host_role_command where status = 'QUEUED';
```

```sql
update host_role_command set status = 'ABORTED' where status = 'QUEUED';
```

## Few nodes was showing incorrect version of HDP so we followed below steps: 

```sql
- Take ambari DB backup 

Run below command to get the current and previous HDP version 

>> select version,stack_id,display_name,repo_version_id from repo_version; 

Run below command to get the information about hosts and the current repo info for hosts 

>> select * from host_verison where repo_version_id=<previous version id>; 

Update the host_version with 'INSTALLED' state 

$ update host_version set state='INSTALLED' where repo_version_id=101;

$ update host_version set state='CURRENT' where repo_version_id=151; 
```

## regenerate certs
```
cat /var/lib/ambari-server/keys/pass.txt

Replcace **** with above password

openssl ca -create_serial -out /var/lib/ambari-server/keys/ca.crt -days 365 -keyfile /var/lib/ambari-server/keys/ca.key -key **** -selfsign -extensions jdk7_ca -config /var/lib/ambari-server/keys/ca.config -batch -infiles /var/lib/ambari-server/keys/ca.csr

openssl pkcs12 -export -in /var/lib/ambari-server/keys/ca.crt -inkey /var/lib/ambari-server/keys/ca.key -certfile /var/lib/ambari-server/keys/ca.crt -out /var/lib/ambari-server/keys/keystore.p12 -password pass:**** -passin pass:****
```

## Ambari Kerberos Descriptor

`curl -u username:password -X GET http://<ambari-hostname>:8080/api/v1/clusters/c174/artifacts/kerberos_descriptor > kerberos_descriptor.json`

`curl -u username:password -X PUT -d @kerberos_descriptor.json http://<ambari-hostname>:8080/api/v1/clusters/c174/artifacts/kerberos_descriptor`

## Ambari Kerberos Issue, service not starting As Disabling Kerberos was not successfull.




```sh
If Disable Security was not completed successfully , Service startup affects.

Check why Disable Security from Ambari OPS section was failed. If its related for Authfailed in zookeeper zonde. Below contains steps to add skipacl, once Kerberos is disabled you can remove skipacl property.

So, services should have kerberoe config. To fix the issue, We reenabled the kerberos on the cluster.
 
We checked MIT KDC was uninstalled, So we reinstalled and configured with same REALM and regenerated the keytabs and successfully started zookeeper.

Logged in into ambari db and set security_type to kerberos. As earlier it was set to None. 


# ambari=> update clusters set security_type='KERBEROS';
# ambari=> UPDATE hostcomponentstate SET security_state='SECURED_KERBEROS' WHERE security_state='UNSECURED';
# ambari=> UPDATE hostcomponentdesiredstate SET security_state='SECURED_KERBEROS' WHERE security_state='UNSECURED';
# ambari=> UPDATE servicedesiredstate SET security_state='SECURED_KERBEROS' WHERE security_state='UNSECURED';


Using below query we came to know kerberos-env was not set. 

# ambari=> select version_tag, type_name, selected, create_timestamp from clusterconfig where type_name = 'kerberos-env'; 

So we updated to latest version tag. 

# ambari=> update clusterconfig set selected = 1 where type_name = 'kerberos-env' AND version_tag = 'versionxxxxxxxxx'; 

Same with krb5-conf 

# ambari=> select version_tag, type_name, selected, create_timestamp from clusterconfig where type_name = 'krb5-conf'; 

So we updated to latest version tag. 
# ambari=> update clusterconfig set selected = 1 where type_name = 'krb5-conf' AND version_tag = 'versionxxxxxxxxx'; 

Restarted Ambari Server:

* As Kerberos Service and Kerberos client was missing, So we used below curl cmds to add the service.

# curl -u admin:admin -H 'X-Requested-By: ambari' -X PUT -d '{"HostRoles": {"state":"INSTALLED"}}' "http://<ambari-hostname>:8080/api/v1/clusters/<CLUSTER-NAME>/host_components?HostRoles/state=INIT"

# curl -u admin:admin -i -H "X-Requested-By: ambari" -X POST -d '{"ServiceInfo":{"service_name":"KERBEROS"}}' http://<ambari-hostname>:8080/api/v1/clusters/<CLUSTER-NAME>/services

# curl -u admin:admin -H "X-Requested-By: ambari" -X POST http://<ambari-hostname>:8080/api/v1/clusters/<CLUSTER-NAME>/services/KERBEROS/components/KERBEROS_CLIENT

# curl -s -u admin:admin http://<ambari-hostname>:8080/api/v1/hosts|grep host_name| sed -n 's/.*"host_name" : "\([^\"]*\)".*/\1/p'>hostcluster.txt


# for i in `cat hostcluster.txt`; do curl -u admin:admin -H "X-Requested-By: ambari" -X POST http://<ambari-hostname>:8080/api/v1/clusters/<CLUSTER-NAME>/hosts/$i/host_components/KERBEROS_CLIENT; done

* We made the temporary kdc.credentials using below command for further operations,

# curl -H "X-Requested-By:ambari" -u admin:admin -X POST -d '{ "Credential" : { "principal" : "admin/admin@EXAMPLE.COM", "key" : "h4d00p&!", "type" : "temporary" } }' http://<ambari-hostname>:8080/api/v1/clusters/<CLUSTER-NAME>/credentials/kdc.admin.credential 

- After this executed below commands to ADD the clients back to UI, 

# curl -u admin:admin -H 'X-Requested-By: ambari' -X PUT -d '{"HostRoles": {"state":"INSTALLED"}}' http://<ambari-hostname>:8080/api/v1/clusters/<CLUSTER-NAME>/host_components?HostRoles/state=INIT


Regenerate All keytabs. Add skipacl in zookeeper service.

+++++
1. Add below attribute to Zookeeper-env template 

-Dzookeeper.skipACL=yes 

Like below. 

# export SERVER_JVMFLAGS="$SERVER_JVMFLAGS -Dzookeeper.skipACL=yes ...... 


2. Restart ZooKeeper servers and login to zkcli 
+++++

Restart Zookeeper Service before disabling kerberos..

Disable the Kerberos using Ambari UI.
```

## Adding Hiveserver2 using Ambari REST in a Kerberos Env:

```sh
1. We need to make sure kerberos credentials are stored in ambari db.
Use below curl cmd to check the same

curl -ik -u admin -H "X-Requested-By: ambari" -X DELETE  http://AMBARI_SERVER_HOST:8080/api/v1/clusters/CLUSTERNAME/credentials/kdc.admin.credential 

Ex:
curl -ik -u admin:pbhagade -H "X-Requested-By: ambari" -X GET  http://172.25.34.129:8080/api/v1/clusters/c174/credentials/kdc.admin.credential 

if you dont see credentials we need to add them using below curl cmd:

curl -ivk -H "X-Requested-By: ambari" -u admin:admin -X POST -d '{ "Credential" : { "principal" : "admin/admin@EXAMPLE.COM", "key" : "PASSWORD", "type" : "temporary" } }' http://AMBARI_SERVER_HOST:8080/api/v1/clusters/CLUSTERNAME/credentials/kdc.admin.credential 

Make sure you replcace admin kerberos credential. principal and PASSWORD.

Ex: 
curl -ivk -H "X-Requested-By: ambari" -u admin:pbhagade -X POST -d '{ "Credential" : { "principal" : "admin/admin@HWX.COM", "key" : "hadoop", "type" : "temporary" } }' http://172.25.34.129:8080/api/v1/clusters/c174/credentials/kdc.admin.credential 


Cross-check if its added or not, it shuld look like below:

curl -ik -u admin:pbhagade -H "X-Requested-By: ambari" -X GET  http://172.25.34.129:8080/api/v1/clusters/c174/credentials/kdc.admin.credential

{
  "href" : "http://172.25.34.129:8080/api/v1/clusters/c174/credentials/kdc.admin.credential",
  "Credential" : {
    "alias" : "kdc.admin.credential",
    "cluster_name" : "c174",
    "type" : "temporary"
  }



# Ensure the host is added to the cluster.
curl --user admin:admin -i -X GET http://AMBARI_SERVER_HOST:8080/api/v1/clusters/CLUSTER_NAME/hosts/NEW_HOST_ADDED

Ex: 

curl --user admin:pbhagade -i -X GET http://172.25.34.129:8080/api/v1/clusters/c174/hosts/c174-node2.squadron.support.hortonworks.com


# Add the necessary host components to the host.
curl --user admin:admin -i -H "X-Requested-By: ambari" -X POST http://AMBARI_SERVER_HOST:8080/api/v1/clusters/CLUSTER_NAME/hosts/NEW_HOST_ADDED/host_components/HIVE_SERVER

Ex:
curl -ik --user admin:pbhagade -H "X-Requested-By: ambari"  -X POST http://172.25.34.129:8080/api/v1/clusters/c174/hosts/c174-node2.squadron.support.hortonworks.com/host_components/HIVE_SERVER

You should see HiveServer2 in ambari under the host you added

#Install the components.
curl --user admin:admin -i -X PUT -d '{"HostRoles": {"state": "INSTALLED"}}' http://AMBARI_SERVER_HOST:8080/api/v1/clusters/CLUSTER_NAME/hosts/NEW_HOST_ADDED/host_components/HIVE_SERVER

Ex:
curl --user admin:pbhagade -i  -H "X-Requested-By: ambari" -X PUT -d '{"HostRoles": {"state": "INSTALLED"}}' http://172.25.34.129:8080/api/v1/clusters/c174/hosts/c174-node2.squadron.support.hortonworks.com/host_components/HIVE_SERVER

You will get below response:

{
  "href" : "http://172.25.34.129:8080/api/v1/clusters/c174/requests/152",
  "Requests" : {
    "id" : 152,
    "status" : "Accepted"
  }

it will install Hiveserver2, and you can use curl cmd to start it.

#Start the components.
curl --user admin:admin -i -H "X-Requested-By: ambari" -X PUT -d '{"HostRoles": {"state": "STARTED"}}' http://AMBARI_SERVER_HOST:8080/api/v1/clusters/CLUSTER_NAME/hosts/NEW_HOST_ADDED/host_components/HIVE_SERVER

curl --user admin:pbhagade -i  -H "X-Requested-By: ambari" -X PUT -d '{"HostRoles": {"state": "STARTED"}}' http://172.25.34.129:8080/api/v1/clusters/c174/hosts/c174-node2.squadron.support.hortonworks.com/host_components/HIVE_SERVER
```


## Ambari DDL
https://github.com/apache/ambari/blob/129632c94aa339571d0fa278a2259157b5244fcb/ambari-server/src/main/resources/Ambari-DDL-SQLAnywhere-CREATE.sql#L1233-L1241

## create user using API

```
Request URL: http://172.25.34.8:8080/api/v1/users


POST {"Users/user_name":"pravin","Users/password":"BigData","Users/active":true,"Users/admin":true}

```


```
update users set user_type='LOCAL' where user_name='admin';
```

## ambari two way ssl

```
ambari two way ssl

+++++ Tested steps for CA signed +++++++

on Ambari server make sure you have below things

/var/lib/ambari-server/keys/

keystore.p12 [Server cert + intermediate CA + RootCA]
pass.txt [keystore password]
ca.crt [root ca]
key.pem [ambari server key]

/var/lib/ambari-agent/keys/.   [make sure you copy respected server certs and keys to respected nodes under keys dir.

Ambari server creates on self signed certificate and CA signed so you need to copy certificates to respected locations.

apollo1.openstacklocal.crt
apollo1.openstacklocal.key
ca.crt

++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++

1. Stop all ambari-agents and the ambari-server processes 

2. ssh to the ambari-server machine 

cd /var/lib/ambari-server/keys 

We need to move the following files from here to a different /tmp directory 

ca.key 
ca.cert 
pass.txt 
keystore.p12 

3. On the same machine 

cd /var/lib/ambari-server/keys/db/newcerts 

Perform an ls -al 
Move any *.crt, *.csr and *.pem files and move to a different /tmp directory 


4. On the same machine 

cd /var/lib/ambari-server/keys/db 

>cat index.txt 

and ensure this is empty, if not vi the file and remove the contents of the file. 

>echo '01' > serial 

So if you cat serial it should only contain 01 

5. Logon to each ambari-agent machine 

cd /var/lib/ambari-agent/keys 

>ls -al 

and ensure that the directory is empty and if it isnt move out the contents. 

6. openssl ca -config /var/lib/ambari-server/keys/ca.config -in /var/lib/ambari-server/keys/ambari-server.csr -out /var/lib/ambari-server/keys/ambari-server.crt -batch -passin file:/var/lib/ambari-server/keys/pass.txt -keyfile /var/lib/ambari-server/keys/ca.key -cert /var/lib/ambari-server/keys/ca.crt 

7. enable two way ssl in ambari server 

6. Start the ambari-server and ambari-agents


+++++

-->Use certificate with CN other than wild character with subject name alterternative set to the list of DNS hostnames for which this cert is used. 

Once we have .key,.crt you can copy these files to /var/lib/ambari-server/keys 

# cp <file>.key /var/lib/ambari-server/keys/<hostname>.key 
# cp <file>.crt /var/lib/ambari-server/keys/<hostname>.crt 

-->Merge the root CA and Intermediate CA to one file and copy it to this dir with same name. 
#cat <rootCA>.crt <intermediateCA>.crt > ca.crt 
#cp ca.crt /var/lib/ambari-server/keys 

-->Create p12 format file using openssl command : 

#openssl pkcs12 -export -out keystore.p12 -inkey <Hostname>.key -in <hostname>.crt -certfile ca.crt 

On Agent hosts: (as you have same cert used for all hosts copy the same cert and key files from ambari-server to all agent hosts) 

-->Copy the ca.crt file to all agent hosts under /var/lib/ambari-agent/keys 
#cp ca.crt /var/lib/ambari-agent/keys 

-->Copy the <server>.crt under /var/lib/ambari-agent/keys 
#cp <server>.crt /var/lib/ambari-agent/keys/<hostname>.crt 

-->Copy the <server>.key under /var/lib/ambari-agent/keys 
#cp <server>.key /var/lib/ambari-agent/keys/<hostname>.key 

```
