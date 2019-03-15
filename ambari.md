# ambari and postgres commands
ambari &amp; postgres cmd cheatsheet

# POSTGRES CMDS

* Removing Hung or In-Progress Operations in Ambari

https://developer.ibm.com/hadoop/2015/10/29/removing-hung-progress-operations-ambari/

```psql
ambari=> select distinct status from host_role_command;
  status   
-----------
 ABORTED
 COMPLETED
 QUEUED
 FAILED
```

`select task_id, role, role_command, status from host_role_command where status = 'QUEUED';`

`update host_role_command set status = 'ABORTED' where status = 'QUEUED';`
