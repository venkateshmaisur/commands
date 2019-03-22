Make sure Ambari Infra , Hbase and kafka are up and running. 
```
klist -kt /etc/security/keytabs/atlas.service.keytab 
kinit -kt /etc/security/keytabs/atlas.service.keytab <principal> 
grep -i java_home /etc/hadoop/conf/hadoop-env.sh
```
+++++
```
HIVE_HOME=/usr/hdp/current/hive-client
export HIVE_HOME=/usr/hdp/current/hive-client
HIVE_CONF_DIR=/usr/hdp/current/hive-client/conf
export HIVE_CONF_DIR=/usr/hdp/current/hive-client/conf
HADOOP_HOME=`hadoop classpath`
export HADOOP_HOME=`hadoop classpath`
export ATLASCPPATH=/usr/hdp/current/hbase-client/lib/hbase-common.jar
```

```
klist -kt /etc/security/keytabs/atlas.service.keytab 
kinit -kt /etc/security/keytabs/atlas.service.keytab <principal> 
HIVE_HOME=/usr/hdp/current/hive-client
export HIVE_HOME=/usr/hdp/current/hive-client
HIVE_CONF_DIR=/usr/hdp/current/hive-client/conf
export HIVE_CONF_DIR=/usr/hdp/current/hive-client/conf
/usr/hdp/current/atlas-server/hook-bin/import-hive.sh
/bin/bash /usr/hdp/current/atlas-server/hook-bin/import-hive.sh -Dsun.security.jgss.debug=true -Djavax.security.auth.useSubjectCredsOnly=false -Djava.security.auth.login.config=/etc/atlas/conf/atlas_jaas.conf 
```
