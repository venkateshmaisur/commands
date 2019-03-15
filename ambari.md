# ambari and postgres commands
ambari &amp; postgres cmd cheatsheet

# POSTGRES CMDS

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

##### Few nodes was showing incorrect version of HDP so we followed below steps: 

```sql
- Take ambari DB backup 

Run below command to get the current and previous HDP version 

>> select version,stack_id,display_name,repo_version_id from repo_version; 

Run below command to get the information about hosts and the current repo info for hosts 

>> select * from host_verison where repo_version_id=<previous version id>; 

Update the host_version with 'INSTALLED' state 

`$ update host_version set state='INSTALLED' where repo_version_id=101; `

$ update host_version set state='CURRENT' where repo_version_id=151; 
```
