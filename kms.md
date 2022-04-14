```sh
=============
Key Trustee KMS
=============

useradd keyadmin
useradd pravin


hadoop.kms.acl.CREATE= keyadmin keyadmingroup
hadoop.kms.acl.GET_KEYS= keyadmin,pravin keyadmingroup



#as hdfs create dirs for EZs
sudo -u hdfs hdfs dfs -mkdir /zone_encr
sudo -u hdfs hdfs dfs -mkdir /zone_encr2

sudo -u hdfs hdfs dfs -chown pravin /zone_encr
sudo -u hdfs hdfs dfs -chown pravin /zone_encr2

# create keys
sudo -u keyadmin hadoop key create testkey
sudo -u keyadmin hadoop key create testkey2

#as pravin list the keys and their metadata
sudo -u pravin hadoop key list -metadata


[root@c474-node4 ~]# sudo -u pravin hadoop key list
Listing keys for KeyProvider: org.apache.hadoop.crypto.key.kms.LoadBalancingKMSClientProvider@510f3d34
testkey2
testkey

#as hdfs create 2 EZs using the 2 keys
sudo -u hdfs hdfs crypto -createZone -keyName testkey -path /zone_encr
sudo -u hdfs hdfs crypto -createZone -keyName testkey2 -path /zone_encr2

#check EZs got created
sudo -u hdfs hdfs crypto -listZones  

#create test files
sudo -u pravin echo "My test file1" > /tmp/test1.log
sudo -u pravin echo "My test file2" > /tmp/test2.log

#copy files to EZs
sudo -u pravin hdfs dfs -copyFromLocal /tmp/test1.log /zone_encr
sudo -u pravin hdfs dfs -copyFromLocal /tmp/test2.log /zone_encr

sudo -u pravin hdfs dfs -copyFromLocal /tmp/test2.log /zone_encr2

sudo -u pravin hdfs dfs -cat /zone_encr/test1.log
sudo -u pravin hdfs dfs -cat /zone_encr2/test2.log

sudo -u pbhagade hdfs dfs -cat /zone_encr/test1.log



#try to remove file from EZ using usual -rm command 
sudo -u pravin hdfs dfs -rm /zone_encr/test2.log

#confirm that test2.log was deleted and that zone_encr only contains test1.log
sudo -u pravin hdfs dfs -ls  /zone_encr/

#copy a file between EZs using distcp with -skipcrccheck option
sudo -u pravin hadoop distcp -skipcrccheck -update /zone_encr2/test2.log /zone_encr/
```

```
ERROR:
======[root@c474-node4 ~]# sudo -u pravin hadoop key list -metadata
Listing keys for KeyProvider: org.apache.hadoop.crypto.key.kms.LoadBalancingKMSClientProvider@510f3d34
Cannot list keys for KeyProvider: org.apache.hadoop.crypto.key.kms.LoadBalancingKMSClientProvider@510f3d34
list [-provider <provider>] [-strict] [-metadata] [-help]:

The list subcommand displays the keynames contained within
a particular provider as configured in core-site.xml or
specified with the -provider argument. -metadata displays
the metadata. If -strict is supplied, fail immediately if
the provider requires a password and none is given.
Executing command failed with the following exception: AuthorizationException: User [pravin] is not authorized to perform [READ] on key with ACL name [testkey]!!
```

===> 
default.key.acl.READ=pravin

```
ERROR:
=======
copyFromLocal: User [pravin] is not authorized to perform [DECRYPT_EEK] on key with ACL name [testkey]!!
```
default.key.acl.DECRYPT_EEK=pravin



ADD ->
key.acl.testkey.DECRYPT_EEK=pravin


### How to enable hourly log rotation + zipping for kms logs
```bash
Follow be steps on ranger kms host: 

- Find log4j extras jar on the Ranger KMS host (usually included with spark2 pkgs)
# find /usr/hdp/<version>/ -name apache-log4j-extras-1.2.17.jar

(or download and copy the jar to ranger-kms classpath)

# wget http://apache.mirrors.tds.net/logging/log4j/extras/1.2.17/apache-log4j-extras-1.2.17-bin.zip
# unzip apache-log4j-extras-1.2.17-bin.zip 
# cp ./apache-log4j-extras-1.2.17/apache-log4j-extras-1.2.17.jar /usr/hdp/<version>/ranger-kms/ews/webapp/lib/

- Configure log4j as below  Ambari> Ranger KMS > Advanced kms-log4j

log4j.logger=INFO, kms
log4j.additivity.kms=false
log4j.rootLogger=INFO, kms
log4j.logger.org.apache.hadoop.conf=ERROR
log4j.logger.org.apache.hadoop=INFO
log4j.logger.com.sun.jersey.server.wadl.generators.WadlGeneratorJAXBGrammarGenerator=OFF

log4j.appender.kms=org.apache.log4j.rolling.RollingFileAppender
log4j.appender.kms.File=${kms.log.dir}/kms.log
log4j.appender.kms.rollingPolicy=org.apache.log4j.rolling.TimeBasedRollingPolicy
log4j.appender.kms.rollingPolicy.ActiveFileName=${kms.log.dir}/kms.log
log4j.appender.kms.rollingPolicy.FileNamePattern=${kms.log.dir}/kms.%d{yyyy-MM-dd_HH}.log.gz
log4j.appender.kms.layout=org.apache.log4j.PatternLayout
log4j.appender.kms.layout.ConversionPattern=%d{ISO8601} %-5p %c{1} - %m%n

log4j.appender.kms-audit=org.apache.log4j.DailyRollingFileAppender
log4j.appender.kms-audit.DatePattern='.'yyyy-MM-dd
log4j.appender.kms-audit.File=${kms.log.dir}/kms-audit.log
log4j.appender.kms-audit.Append=true
log4j.appender.kms-audit.layout=org.apache.log4j.PatternLayout
log4j.appender.kms-audit.layout.ConversionPattern=%d{ISO8601} %m%n
log4j.appender.kms-audit.MaxFileSize={{ranger_kms_audit_log_maxfilesize}}MB

log4j.logger.kms-audit=INFO, kms-audit
log4j.additivity.kms-audit=false
```

## Auditing to external systems in CDP Private Cloud Base
```bash
1. Ranger KMS Server Advanced Configuration Snippet (Safety Valve) for conf/ranger-kms-audit.xml

Name: xasecure.audit.destination.log4j
Value: true

Name: xasecure.audit.destination.log4j.logger
Value: ranger.audit

Name: xasecure.audit.log4j.is.enabled
Value:true


2. Ranger KMS Server Logging Advanced Configuration Snippet (Safety Valve)

log4j.appender.RANGER_AUDIT=org.apache.log4j.DailyRollingFileAppender
log4j.appender.RANGER_AUDIT.File=/var/log/ranger/kms/ranger-audit-test.log
log4j.appender.RANGER_AUDIT.Append=true
log4j.appender.RANGER_AUDIT.layout=org.apache.log4j.PatternLayout
log4j.appender.RANGER_AUDIT.layout.ConversionPattern=%m%n
log4j.logger.ranger.audit=INFO,RANGER_AUDIT
log4j.additivity.RANGER_AUDIT=false



cat /var/log/ranger/kms/ranger-audit-test.log
{"repoType":7,"repo":"cm_kms","reqUser":"admin","evtTime":"2022-04-14 07:47:21.660","access":"getkeys","resType":"keyname","action":"getkeys","result":1,"agent":"kms","policy":42,"enforcer":"ranger-acl","cliIP":"172.27.187.194","agentHost":"pbhagade-3.pbhagade.root.hwx.site","logType":"RangerAudit","id":"9404917a-7353-413f-aa6e-171ea74e9c71-0","seq_num":1,"event_count":1,"event_dur_ms":1,"tags":[],"cluster_name":"Cluster 1","policy_version":2}
{"repoType":7,"repo":"cm_kms","reqUser":"admin","evtTime":"2022-04-14 07:47:30.866","access":"getmetadata","resType":"keyname","action":"getmetadata","result":1,"agent":"kms","policy":42,"enforcer":"ranger-acl","cliIP":"172.27.187.194","agentHost":"pbhagade-3.pbhagade.root.hwx.site","logType":"RangerAudit","id":"9404917a-7353-413f-aa6e-171ea74e9c71-1","seq_num":3,"event_count":1,"event_dur_ms":1,"tags":[],"cluster_name":"Cluster 1","policy_version":2}

```
