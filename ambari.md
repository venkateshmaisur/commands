# Ambari known issue
ambari &amp; postgres cmd cheatsheet

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
