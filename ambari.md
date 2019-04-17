# ambari and postgres commands
ambari &amp; postgres cmd cheatsheet

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


If Disable Security was not completed successfully , Service startup affects.

So, services still had kerberoe config. To fix the issue, We reenabled the kerberos on the cluster.

Take Ambari DB backup

Logged in into ambari db and set security_type to kerberos. As earlier it was set to None. 

`$ ambari=> update clusters set security_type='KERBEROS';`

​ If Kerberos Service and Kerberos client are missing, So we need to use below curl cmds to add the service.


```sh
$ curl -u admin:admin -H 'X-Requested-By: ambari' -X PUT -d '{"HostRoles": {"state":"INSTALLED"}}' "http://<ambari-hostname>:8080/api/v1/clusters/<CLUSTER-NAME>/host_components?HostRoles/state=INIT"


$ curl -u admin:admin -i -H "X-Requested-By: ambari" -X POST -d '{"ServiceInfo":{"service_name":"KERBEROS"}}' http://<ambari-hostname>:8080/api/v1/clusters/<CLUSTER-NAME>/services


$ curl -u admin:admin -H "X-Requested-By: ambari" -X POST http://<ambari-hostname>:8080/api/v1/clusters/<CLUSTER-NAME>/services/KERBEROS/components/KERBEROS_CLIENT


$ curl -s -u admin:admin http://<ambari-hostname>:8080/api/v1/hosts|grep host_name| sed -n 's/.*"host_name" : "\([^\"]*\)".*/\1/p'>hostcluster.txt


$ for i in `cat hostcluster.txt`; do curl -u admin:admin -H "X-Requested-By: ambari" -X POST http://<ambari-hostname>:8080/api/v1/clusters/<CLUSTER-NAME>/hosts/$i/host_components/KERBEROS_CLIENT; done
```

- We made the temporary kdc.credentials using below command for further operations,

```bash
$ curl -H "X-Requested-By:ambari" -u admin:admin -X POST -d '{ "Credential" : { "principal" : "admin/admin@EXAMPLE.COM", "key" : "h4d00p&!", "type" : "temporary" } }' http://<ambari-hostname>:8080/api/v1/clusters/<CLUSTER-NAME>/credentials/kdc.admin.credential 

- After this executed below commands to ADD the clients back to UI, 

$ curl -u admin:admin -H 'X-Requested-By: ambari' -X PUT -d '{"HostRoles": {"state":"INSTALLED"}}' http://<ambari-hostname>:8080/api/v1/clusters/<CLUSTER-NAME>/host_components?HostRoles/state=INIT
```


Using below query we came to know kerberos-env was not set. 

`$ ambari=> select version_tag, type_name, selected, create_timestamp from clusterconfig where type_name = 'kerberos-env'; `

So we updated to latest version tag. 

`$ update clusterconfig set selected = 1 where type_name = 'kerberos-env' AND version_tag = 'versionxxxxxxxxx';`

Same with krb5-conf 

`$ ambari=> select version_tag, type_name, selected, create_timestamp from clusterconfig where type_name = 'krb5-conf'; `

So we updated to latest version tag. 
`$ update clusterconfig set selected = 1 where type_name = 'krb5-conf' AND version_tag = 'versionxxxxxxxxx'; `

Also: 
```ambari=>
UPDATE hostcomponentstate SET security_state='SECURED_KERBEROS' WHERE security_state='UNSECURED';
UPDATE hostcomponentdesiredstate SET security_state='SECURED_KERBEROS' WHERE security_state='UNSECURED';
UPDATE servicedesiredstate SET security_state='SECURED_KERBEROS' WHERE security_state='UNSECURED';
```

Restarted Ambari Server:

Later we checked MIT KDC was uninstalled, So we reinstalled and configured with same REALM and regenerated the keytabs and successfully started zookeeper.



```sh
We found that Disable Security was not completed successfully has it falied in ambari infra due to auth failed on zookeeper znode.

+++++++++++++++++++
Ambari Infra:
============

Exception in thread "main" org.apache.zookeeper.KeeperException$NoAuthException: KeeperErrorCode = NoAuth for /infra-solr
	at org.apache.zookeeper.KeeperException.create(KeeperException.java:113)
	at org.apache.zookeeper.KeeperException.create(KeeperException.java:51)
	at org.apache.zookeeper.ZooKeeper.setACL(ZooKeeper.java:1459)
+++++++++++++++++++

So, services still had kerberoe config. To fix the issue, We reenabled the kerberos on the cluster. 
We checked MIT KDC was uninstalled, So we reinstalled and configured with same REALM and regenerated the keytabs and successfully started zookeeper.

Logged in into ambari db and set security_type to kerberos. As earlier it was set to None. 


# ambari=> update clusters set security_type='KERBEROS';
ambari=>
UPDATE hostcomponentstate SET security_state='SECURED_KERBEROS' WHERE security_state='UNSECURED';
UPDATE hostcomponentdesiredstate SET security_state='SECURED_KERBEROS' WHERE security_state='UNSECURED';
UPDATE servicedesiredstate SET security_state='SECURED_KERBEROS' WHERE security_state='UNSECURED';


Using below query we came to know kerberos-env was not set. 

ambari=> select version_tag, type_name, selected, create_timestamp from clusterconfig where type_name = 'kerberos-env'; 

So we updated to latest version tag. 

#update clusterconfig set selected = 1 where type_name = 'kerberos-env' AND version_tag = 'versionxxxxxxxxx'; 

Same with krb5-conf 

ambari=> select version_tag, type_name, selected, create_timestamp from clusterconfig where type_name = 'krb5-conf'; 

So we updated to latest version tag. 
#update clusterconfig set selected = 1 where type_name = 'krb5-conf' AND version_tag = 'versionxxxxxxxxx'; 

Restarted Ambari Server:

​As Kerberos Service and Kerberos client was missing, So we used below curl cmds to add the service.


# curl -u admin -p admin -i -H "X-Requested-By: ambari" -X POST -d '{"ServiceInfo":{"service_name":"KERBEROS"}}' http://10.30.83.21:8080/api/v1/clusters/gsp_abo_analytics/services

# curl -u admin -H "X-Requested-By: ambari" -X POST http://10.30.83.21:8080/api/v1/clusters/gsp_abo_analytics/services/KERBEROS/components/KERBEROS_CLIENT

# curl -s -u admin http://10.30.83.21:8080/api/v1/hosts|grep host_name| sed -n 's/.*"host_name" : "\([^\"]*\)".*/\1/p'>hostcluster.txt

# for i in `cat hostcluster.txt`; do curl -u admin -H "X-Requested-By: ambari" -X POST http://10.30.83.21:8080/api/v1/clusters/gsp_abo_analytics/hosts/$i/host_components/KERBEROS_CLIENT; done


- We made the temporary kdc.credentials using below command for further operations,

# curl -H "X-Requested-By:ambari" -u admin -X POST -d '{ "Credential" : { "principal" : "admin/admin@GSPABO.COM", "key" : "Welcome", "type" : "temporary" } }' http://10.30.83.21:8080/api/v1/clusters/gsp_abo_analytics/credentials/kdc.admin.credential 

After this executed below commands to ADD the clients back to UI,  

# curl -u admin:Exit@1234 -H 'X-Requested-By: ambari' -X PUT -d '{"HostRoles": {"state":"INSTALLED"}}' http://10.30.83.21:8080/api/v1/clusters/gsp_abo_analytics/host_components?HostRoles/state=INIT 


Regenerated All keytabs. All skipacl in zookeeper.

+++++
Add below attribute to Zookeeper-env template 

-Dzookeeper.skipACL=yes 

Like below. 

export SERVER_JVMFLAGS="$SERVER_JVMFLAGS -Dzookeeper.skipACL=yes ...... 


2. Restart ZooKeeper servers and login to zkcli 
+++++

Restrat Zookeeper.

Disabled the Kerberos successfully.
```
