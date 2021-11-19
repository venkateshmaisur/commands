Make sure Ambari Infra , Hbase and kafka are up and running. 

```sh
kinit -kt /etc/security/keytabs/atlas.service.keytab $(klist -kt /etc/security/keytabs/atlas.service.keytab |sed -n "4p"|cut -d ' ' -f7)
grep -i java_home /etc/hadoop/conf/hadoop-env.sh
```

## Atlas CDP Recreate hbasse table and solr collection 

```
export ATLAS_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*ATLAS_SERVER | tail -1)
ps auxwwf | grep atlas-ATLAS_SERVER > /tmp/atlas-ps.txt
env GZIP=-9  tar -cvzf atlas.tar.gz $ATLAS_PROCESS_DIR /var/log/atlas/application.log /tmp/atlas-ps.txt


+++
If you dont have any data in atlas hbase tables and solr collecttion, we will delete it and follow recreation steps:

Drop Hbase table:

# Login into HBase node, kinit with hbase keytab

$ hbase shell

disable 'atlas_janus'
disable 'ATLAS_ENTITY_AUDIT_EVENTS'
drop 'ATLAS_ENTITY_AUDIT_EVENTS' 
drop 'atlas_janus'

# Login into Solr node, kinit with solr keytab

# check with available collection, if atlas collection are present delete it.
solrctl collection  --list

solrctl collection --delete vertex_index
solrctl collection --delete edge_index
solrctl collection --delete fulltext_index

Stop Atlas:

1. Goto CM UI -> Altas -> Action -> Create Hbase Table for Atlas
2. Goto CM UI -> Altas -> Action ->  Initialize Atlas

Restart Atlas service, If it still fail to start, Please collect below details.


export ATLAS_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*ATLAS_SERVER | tail -1)
export ATLAS_SERVER-InitializeAtlasRole=$(ls -1dtr /var/run/cloudera-scm-agent/process/*ATLAS_SERVER-InitializeAtlasRole | tail -1)
export CREATE_TABLE_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*hbase-create-hbase-tables-for-atlas* | tail -1)
ps auxwwf | grep atlas-ATLAS_SERVER > /tmp/atlas-ps.txt

env GZIP=-9  tar -cvzf atlas.tar.gz $ATLAS_PROCESS_DIR $ATLAS_SERVER-InitializeAtlasRole $CREATE_TABLE_PROCESS_DIR /var/log/atlas/application.log /tmp/atlas-ps.txt


attach atlas.tar.gz

```

### Enable Atlas metric and atlas performance logging
```
Please ask customer to enable metric and atlas performance logging

going to CM->Atlas->configuration - Atlas Server Logging Advanced Configuration Snippet (Safety Valve)

log4j.appender.perf_appender=org.apache.log4j.DailyRollingFileAppender
log4j.appender.perf_appender.file=/var/log/atlas/atlas_perf.log
log4j.appender.perf_appender.append=true
log4j.category.org.apache.atlas.perf=debug,perf_appender
log4j.additivity.org.apache.atlas.perf=false
log4j.appender.METRICS.layout=org.apache.log4j.PatternLayout
log4j.appender.METRICS.layout.ConversionPattern=%d %x %m%n
log4j.appender.METRICS.layout.maxFileSize=1024MB
log4j.additivity.METRICS=true
log4j.category.METRICS=DEBUG,METRICS


Save and restart Atlas service.

Wait for 1 - 2 hour collect metric.log, atlas_perf.log log file

export ATLAS_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*ATLAS_SERVER | tail -1)
ps auxwwf | grep atlas-ATLAS_SERVER > /tmp/atlas-ps.txt
env GZIP=-9  tar -cvzf atlas.tar.gz $ATLAS_PROCESS_DIR /var/log/atlas/application.log /tmp/atlas-ps.txt /var/log/atlas/atlas_perf.log  /var/log/atlas/audit.log /var/log/atlas/metric.log

attach atlas.tar.gz
```

### Atlas Group mapping issue (Linux + AD)
```
CDP Atlas Ranger logging:

Atlas Server Logging Advanced Configuration Snippet (Safety Valve)
log4j.category.org.apache.ranger=info,FILE



CM -> Atlas -> Configuration -> atlas.authentication.method.ldap.ugi-groups [check the box]

atlas.authentication.method.ldap.ugi-groups this checkbox should be checked 

and remove "atlas.authentication.ugi-groups.include-hadoop-groups=true" property if it is set.
```

```
# export ATLAS_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*ATLAS_SERVER | tail -1)
# egrep 'hbase|storage' $ATLAS_PROCESS_DIR/conf/atlas-application.properties

 # kinit -kt ${ATLAS_PROCESS_DIR}/atlas.keytab atlas/$(hostname -f)
 # klist
 # echo 'list' | hbase shell -n | grep -i atlas
 
  # export HBASE_PROCESS_DIR=$(ls -1drt /var/run/cloudera-scm-agent/process/*hbase-REGIONSERVER | tail -1)
 # kinit -kt $HBASE_PROCESS_DIR/hbase.keytab hbase/$(hostname -f)
 # klist
 # echo 'list' | hbase shell -n | grep -i atlas
 
  # kinit -kt $HBASE_PROCESS_DIR/hbase.keytab hbase/$(hostname -f)
 # echo "user_permission 'atlas_janus'" |hbase shell -n
 # echo "user_permission 'ATLAS_ENTITY_AUDIT_EVENTS'" |hbase shell -n
 
 By default CM doesnt set permissions on thse tables to allow atlas user access. Execute below commands to grant RWX permissions to atlas user.

 # echo "grant 'atlas','RWXCA','atlas_janus'" | hbase shell -n
 # echo "grant 'atlas','RWXCA','ATLAS_ENTITY_AUDIT_EVENTS'" | hbase shell -n
 # echo "user_permission 'atlas_janus'" |hbase shell -n
 # echo "user_permission 'ATLAS_ENTITY_AUDIT_EVENTS'" |hbase shell -n
 
 # echo -e "hadoop\nhadoop" | kadmin.local -q 'addprinc thomas'
# echo -e "hadoop\nhadoop" | kadmin.local -q 'addprinc steve'
# echo hadoop | kinit thomas 
 # beeline --silent=true -u "jdbc:hive2://$(hostname -f):2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2" -e "create table atlas_test_table(col1 string,col2 int);"
 # beeline --silent=true -u "jdbc:hive2://$(hostname -f):2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2" -e "describe formatted atlas_test_table"
  # kinit -kt $ATLAS_PROCESS_DIR/atlas.keytab atlas/$(hostname -f)
 # export JAVA_HOME=/usr/java/jdk1.8.0_232-cloudera/
 # echo hadoop | kinit admin/admin
 # /opt/cloudera/parcels/CDH/lib/atlas/hook-bin/import-hive.sh
 
 
 # echo hadoop | kinit thomas
# beeline --silent=true -u "jdbc:hive2://$(hostname -f):2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2" -e "create table atlas_test_ctas_bridge as (select * from atlas_test_table)"
# beeline --silent=true -u "jdbc:hive2://$(hostname -f):2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2"  -e "show tables"
# echo hadoop | kinit admin/admin
# /opt/cloudera/parcels/CDH/lib/atlas/hook-bin/import-hive.sh



## Hive import script
```sh
HIVE_HOME=/usr/hdp/current/hive-client
export HIVE_HOME=/usr/hdp/current/hive-client
HIVE_CONF_DIR=/usr/hdp/current/hive-client/conf
export HIVE_CONF_DIR=/usr/hdp/current/hive-client/conf
HADOOP_HOME=`hadoop classpath`
export HADOOP_HOME=`hadoop classpath`
export ATLASCPPATH=/usr/hdp/current/hbase-client/lib/hbase-common.jar
```

```sh
kinit -kt /etc/security/keytabs/atlas.service.keytab $(klist -kt /etc/security/keytabs/atlas.service.keytab |sed -n "4p"|cut -d ' ' -f7)
HIVE_HOME=/usr/hdp/current/hive-client
export HIVE_HOME=/usr/hdp/current/hive-client
HIVE_CONF_DIR=/usr/hdp/current/hive-client/conf
export HIVE_CONF_DIR=/usr/hdp/current/hive-client/conf
/usr/hdp/current/atlas-server/hook-bin/import-hive.sh
```

### cdp import script
```
Login into Hbase node:
export ATLAS_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*ATLAS_SERVER | tail -1)
kinit -kt $ATLAS_PROCESS_DIR/atlas.keytab atlas/`hostname -f`

**Note**
# set JAVA_HOME if not set
# Make sure atlas service user has access to atlas policy for "update-entity"

#run:
/opt/cloudera/parcels/CDH//lib/atlas/hook-bin/import-hbase.sh
```

```bash
/bin/bash /usr/hdp/current/atlas-server/hook-bin/import-hive.sh -Dsun.security.jgss.debug=true -Djavax.security.auth.useSubjectCredsOnly=false -Djava.security.auth.login.config=/etc/atlas/conf/atlas_jaas.conf
```
## Triage
```

I will assume that this cluster is not kerberized and will share few below cmds and share me the output of the same.

1. Could you please confirm Ambari Infra and kafka are up and running?

Share me the output of below cmds in text file and attach the text to the case.


/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --list --zookeeper ZK-Hostname:2181

cd /usr/hdp/current/kafka-broker/bin
./kafka-topics.sh --describe --zookeeper ZK-Hostname:2181 --topic ATLAS_HOOK
./kafka-topics.sh --describe --zookeeper ZK-Hostname:2181 --topic ATLAS_ENTITIES
./kafka-topics.sh --describe --zookeeper ZK-Hostname:2181 --topic __consumer_offsets
./kafka-consumer-groups.sh --bootstrap-server <broker host>:6667 --list
./kafka-consumer-groups.sh --describe --bootstrap-server <broker host>:6667 --group atlas


Login into Ambari infra Node:
curl -ik "http://$(hostname -f):8886/solr/admin/collections?action=clusterstatus&wt=json&indent=true"


Attach atlas logs /var/log/atlas/application.log

Also, attach below config files.

hive,atlas,kafka

tar -cvzf configs.tar.gz /etc/kafka/conf/* /etc/atlas/conf/* /etc/hive/conf/*


grep ERROR /Users/pbhagade/Downloads/application\ \(2\).log |grep -i notification | grep rollback |cut -d ' ' -f5- |sort | uniq


grep -e ERROR -e WARN /Users/pbhagade/Downloads/application\ \(2\).log |grep NotificationHookConsumer |tail -1 &> filtered.out

```

## Enable the perf logging to measure the performance

```sh
Goto Ambari UI --> Altas --> Configs --> Advanced --> Advanced atlas-log4j 

Search for 
+++++ 
<!-- uncomment this block to generate performance traces 
<appender name="perf_appender" class="org.apache.log4j.DailyRollingFileAppender"> 
<param name="File" value="{{log_dir}}/atlas_perf.log" /> 
<param name="datePattern" value="'.'yyyy-MM-dd" /> 
<param name="append" value="true" /> 
<layout class="org.apache.log4j.PatternLayout"> 
<param name="ConversionPattern" value="%d|%t|%m%n" /> 
</layout> 
</appender> 

<logger name="org.apache.atlas.perf" additivity="false"> 
<level value="debug" /> 
<appender-ref ref="perf_appender" /> 
</logger> 
--> 

++++ 

uncomment first and last line 

remove 

<!-- uncomment this block to generate performance traces 

--> 


Now performance logging will be done in atlas_perf.log file. 
```

###### performance:
```
I reviewed the logs, it takes  around *191* seconds on average to process the ENTITY_CREATE_V2 type messages.
{noformat}
$ grep "ENTITY_CREATE_V2" atlas_perf\ \(1\)\ \(2\).log | cut -c 81-88 | awk '\{ total += $1; count++ } END \{ print total/count }'

191005
{noformat}
```

## Atlas Backup:
==========
```bash
To backup Hbase table follow below steps: 

1. Create a folder in HDFS which is having an owner as HBase.
2. Run below command from HBase user with TGT if required to export HBase table into HDFS folder which is newly created.

# hbase org.apache.hadoop.hbase.mapreduce.Export "atlas_titan" "/<folder>/atlas_titan"
# hbase org.apache.hadoop.hbase.mapreduce.Export "ATLAS_ENTITY_AUDIT_EVENTS" "/<folder>/ATLAS_ENTITY_AUDIT_EVENTS"

Above commands will backup the Data from HBase table into HDFS.

Please note snapshot only creates a snap of the HBase table so that the original table can be restored to the snapshot point. Also, the snapshot does not replicate the data it just checkpoints it.

With that being said, at the time of import, you should have the HBase tables created with the correct schema which can be done by doing a restart of Atlas:-
1. Run below command from the HBase user with TGT if required to import HBase table from HDFS folder to HBase table:

# hbase org.apache.hadoop.hbase.mapreduce.Import 'atlas_titan' '/<folder>/atlas_titan'

# hbase org.apache.hadoop.hbase.mapreduce.Import 'ATLAS_ENTITY_AUDIT_EVENTS' '/<folder>/ATLAS_ENTITY_AUDIT_EVENTS'
You need to restart atlas once the import is done. 
```

## Drop hbase tables:

```sh

disable 'atlas_titan'
disable 'ATLAS_ENTITY_AUDIT_EVENTS'
drop 'ATLAS_ENTITY_AUDIT_EVENTS' 
drop 'atlas_titan'
```

## Export & Import REST APIs


##### Hive Database backup
```sh
curl -X POST -u admin:admin -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
    "itemsToExport": [
       { "typeName": "hive_db",  "uniqueAttributes": { "name": "dummies" } }
    ],
    "options": {
        "fetchType": "FULL"
    }
}' "http://apollo1.openstacklocal:21000/api/atlas/admin/export" > Atlas-export.zip
```

```sh
FYI: Atlas export fails after taking long time on large databases.
In that case : Change as below
++++++++++
"fetchType": "FULL" 
to
"fetchType": "CONNECTED"
+++++++++++
+++++++++++
 Import Entities by Hive Databases.
 ```
 
eg:-
```sh
curl -u admin:admin -g -X POST -H "Content-Type: multipart/form-data" -H "Cache-Control: no-cache" -F data=@Atlas-export.zip "http://apollo1.openstacklocal:21000/api/atlas/admin/import"
You Multiple database backup.
curl -X POST -u admin:admin -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
    "itemsToExport": [
       { "typeName": "hive_db",  "uniqueAttributes": { "name": "default" } }
       { "typeName": "hive_db",  "uniqueAttributes": { "name": "dummies" } }
    ],
    "options": {
        "fetchType": "FULL"
    }
}' "http://apollo1.openstacklocal:21000/api/atlas/admin/export" > Atlas-export.zip
```

2. If I want to take backup of Atlas by accessing its backing stores (HBase, Solr, and Kafka) instead of using Export API, what should I do? Only exporting tables of HBase is enough? Taking a backup of Solr and Kafka is also necessary? According to https://atlas.apache.org/0.8.1/InstallationSteps.html, indexes on Solr are automatically created when Atlas Metadata Server start. Therefore I think taking a backup of Solr is not necessary. About Kafka, I recognize Kafka in Atlas is just only a message bus, so there's no need to take a backup.

==> Yes, only Hbase backup is required

3. If taking an "exported" tables of HBase is enough for backup of Atlas, is loading those "exported" just before starting Atlas enough to restore Atlas?
===>
Yes.
For more into please refer : https://community.hortonworks.com/questions/91145/how-to-take-backup-of-apache-atlas-and-restore-it.html


# Atlas Migration Recovery
##### When does the issue occurs. When customer Uses json file rather than complete directory path and migration fails:
```
Steps:

Stop HDP 3.x Atlas.

Drop Atlas' Solr collections

Drop Atlas' HBase table ('atlas_janus').

Start HDP 3.x Atlas in migration mode.

Once migration succeeds, perform import-hive.sh to import Hive tables that were created after migration.

Tags and Glossary are manually applied. Migration import will preserve the tags from earlier version. However, there isn't a way of tagging entities after migration.

If the entities tagged post migration is a small number, then user can re-apply the tags.

Other than this, I don't see any other concern.

```


## Atlas/Infra Solr issue after Upgrading Ambari to 2.7.3

```sh

+++++++ERROR++++++++
shards can be added only to 'implicit' collections

Cause: 
=====
This issue occurs when the infra-solr is not upgraded although Ambari is upgraded. When Ambari uploads the latest version of security.json to Zookeeper, it will be incompatible with the old version of Infra-Solr. 
Note: 
This classpath issue happens only if Solr is restarted after ambari upgrade 


Resolution: 

Perform below steps to resolve this issue: 

1) Take a backup of security.json: 
$ kinit -kt <infra-solr-keytab> <principal> 

$ /usr/hdp/current/zookeeper-client/bin/zkCli.sh -server `hostname -f` get /infra-solr/security.json > /var/tmp/security.json 


2) Disable the authorization by replacing the following in infra-solr-env 

Replcace: 
#------------------------ 
SOLR_AUTH_TYPE="kerberos" 
#------------------------ 

With: 
#+++++++++++++++++++++++++ 
SOLR_KERB_NAME_RULES="{{infra_solr_kerberos_name_rules}}" 
SOLR_AUTHENTICATION_CLIENT_CONFIGURER="org.apache.solr.client.solrj.impl.Krb5HttpClientConfigurer" 
#+++++++++++++++++++++++++ 



3) If ambari version is at least 2.7.1, replace logj4 props as well in infra-solr-env 
Replcae: 
#------------------------ 
LOG4J_PROPS={{infra_solr_conf}}/log4j2.xml 
#------------------------ 

With: 
#+++++++++++++++++++++++++ 
LOG4J_PROPS={{infra_solr_conf}}/log4j.properties 
#+++++++++++++++++++++++++ 


4) In Infra-Solr Config-> Advanced infra-solr-security-json, 
Select "Manually Managed" 

5) Update security.json: 
/usr/hdp/current/zookeeper-client/bin/zkCli.sh -server `hostname -f` set /infra-solr/security.json "{ "authentication": { "class": "org.apache.solr.security.KerberosPlugin" } }" 

IMPORTANT: 
Please note that these should be reverted after the solr instances are upgraded. 


6) Restart infra-solr. 	


7) Run migrationConfigGenerator.py script 

wget --no-check-certificate -O /usr/lib/ambari-infra-solr-client/migrationConfigGenerator.py https://raw.githubusercontent.com/apache/ambari/release-2.7.3/ambari-infra/ambari-infra-solr-client/src/main/python/migrationConfigGenerator.py
chmod +x /usr/lib/ambari-infra-solr-client/migrationConfigGenerator.py

wget --no-check-certificate -O /usr/lib/ambari-infra-solr-client/migrationHelper.py https://raw.githubusercontent.com/apache/ambari/release-2.7.3/ambari-infra/ambari-infra-solr-client/src/main/python/migrationHelper.py

$ cd /usr/lib/ambari-infra-solr-client 
$ export CONFIG_INI_LOCATION=/usr/lib/ambari-infra-solr-client/ambari_solr_migration.ini 

$ ./migrationConfigGenerator.py --ini-file $CONFIG_INI_LOCATION --host c3157-node1.squadron-labs.com --port 8080 --cluster c3157 --username admin --password ashelke --backup-base-path=/root --java-home /usr/jdk64/jdk1.8.0_112 

Start generating config file: /usr/lib/ambari-infra-solr-client/ambari_solr_migration.ini ... 
Get Ambari cluster details ... 
Set JAVA_HOME: /usr/jdk64/jdk1.8.0_112 
Service detected: ZOOKEEPER 
Zookeeper connection string: 
Service detected: AMBARI_INFRA_SOLR 
Infra Solr znode: /infra-solr 
Service detected: RANGER 
Ranger Solr collection: ranger_audits 
Ranger backup path: /var/tmp/ranger 
Service detected: ATLAS 
Atlas Solr collections: fulltext_index, edge_index, vertex_index 
Atlas backup path: /var/tmp/atlas 
Kerberos: enabled 
Config file generation has finished successfully 


# Back up Ambari Infra Solr Data
/usr/lib/ambari-infra-solr-client/ambariSolrMigration.sh --ini-file $CONFIG_INI_LOCATION --mode backup | tee backup_output.txt

Migration helper command FINISHED
Total Runtime: 00:01:02


# Remove Existing Collections & Upgrade Binaries
 
````
## ATLAS 503 webui error
```sh
Stop Atlas
Login into Atlas node:
cd /usr/hdp/current/atlas-server/server/webapp/
rm -rf atlas/*
cp atlas.war atlas/
cd atlas/
jar -xvf atlas.war
rm -rf atlas.war
Start Atlas service.
```


## Tag sync performannce 
```
he consumer lag stats every 1 hour for a day so that we can see the current performance. (along with that timeframe tagsync logs)
Along with that please get the kafka dump for ATLAS_ENTITIES topic

--
#date; /usr/hdp/current/kafka-broker/bin/kafka-consumer-groups.sh --bootstrap-server <broker>:6667 --describe --group ranger_entities_consumer --security-protocol <protocol>
--

--
/usr/hdp/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server <broker>:6667 --topic ATLAS_ENTITIES --security-protocol <protocol> --from-beginning > /tmp/atlas_entities.log
```
```
 curl -s -k -u admin:admin 'http://c3232-node2.coelab.cloudera.com:21000/api/atlas/v2/search/basic?limit=25&excludeDeletedEntities=true&typeName=hive_table' | python -mjson.tool | grep name| wc -l
 ```
 
 ###### Enable metrics logging
 ```
 Please enable metric log for Atlas if not enabled and provide metrics log.

Also provide output of metrics API  {{??http://<%atlas_host:port%>/api/atlas/admin/metrics??}}
{noformat}
 <appender name="METRICS" class="org.apache.log4j.RollingFileAppender">
       <param name="File" value="${atlas.log.dir}/metric.log"/>
       <param name="Append" value="true"/>
       <layout class="org.apache.log4j.PatternLayout">
           <param name="ConversionPattern" value="%d %x %m%n"/>
           <param name="maxFileSize" value="100MB" />
       </layout>
   </appender>

   <logger name="METRICS" additivity="false">
       <level value="debug"/>
       <appender-ref ref="METRICS"/>
   </logger>
{noformat}
 ```
 
 #### Atlas group level policy
```
Atlas will first try to get the groups from the local host. If the user exists on the host where atlas is started , that user groups are mapped to the username.
If user doesnt exists in the host, then atlas will look for user's group from HadoopGroups , for this purpose Atlas will use core-site configs for hadoop group mapping.
If hadoop group mapping is configured then a UGI request to get group is made as per configs in core-site and map resulted groups to the user.
So , to map hadoop groups to user, username should not exist on Atlas host. If there is are requirement to map all groups even from local Atlas host and also from HadoopGroup mapping , then atlas provides option 'atlas.authentication.ugi-groups.include-hadoop-groups' that can be set to true. And following restart will map user groups identified from both HadoopGroups and local groups.
Try adding atlas.authentication.ugi-groups.include-hadoop-groups=true in atlas application properties.
If core-site has 'hadoop.security.group.mapping.ldap.ssl.truststore' configs, make sure that truststore file exists on Atlas host as well for connections to ldaps.
```
---------------------------------------------------------------------------------------------------------------------------


#### Atlas ranger tag policies

```
Entity.

entity-type : hive_db,hive_table
entity classification: SG_*, *_NOT_CLASSIFIED*
entity-id: SG*
permissions - give permission desired to user 


Type

 type-category - classification
 type Name - SG_*
 permissions - give permission desired to user 
 
 This following policies worked for singapore schema entities for singapore assigned user  in policy
 ```
Below are the links which might be helpful to you for getting started with atlas. 



#### Atlas Knox Proxy setup
```
In HDP atlas did not support trusted proxy and forced the use of the Anonymous authentication provider so that it could provide its own authentication.

below are the jiras are required for to support trusted proxy for Atlas , Knox

https://issues.apache.org/jira/browse/ATLAS-2824  Atlas authentication to support proxy-user
https://issues.apache.org/jira/browse/KNOX-1877   Atlas service definitions should default to trusted proxy


I checked HDP 3.1.0.302-2 ATLAS-2824  is already applied on it.

KNOX-1877 was missing, We need to make below changes to make it work, which would require Restart of Atlas and Knox.

1. Atlas.

Please check if you have below property set, if present make sure its set to true, If not present, please add in Atlas -> Configs -> Advanced ->  "Custom application-properties"

atlas.authentication.method.trustedproxy=true
atlas.proxyuser.knox.groups=*
atlas.proxyuser.knox.hosts=*

# grep atlas.authentication.method.trustedproxy /etc/atlas/conf/atlas-application.properties


Save and Restart

2. Knox


Please make the below changes where I commented policy and "dispatch classname" and new "dispatch classname"

vim /usr/hdp/current/knox-server/data/services/atlas-api/0.8.0/service.xml

<service role="ATLAS-API" name="atlas-api" version="0.8.0">
<!--    <policies>
        <policy role="webappsec"/>
        <policy role="authentication" name="Anonymous"/>
        <policy role="rewrite"/>
        <policy role="authorization"/>
    </policies>
-->
    <routes>
        <route path="/atlas/api/**"/>
    </routes>
<!--    <dispatch classname="org.apache.knox.gateway.dispatch.PassAllHeadersDispatch" ha-classname="org.apache.knox.gateway.ha.dispatch.AtlasApiHaDispatch"/> -->
        <dispatch classname="org.apache.knox.gateway.dispatch.DefaultDispatch" ha-classname="org.apache.knox.gateway.ha.dispatch.AtlasTrustedProxyHaDispatch" />
</service>



Clear the all kerberos.topo from deployment directory.

ls -ltrd /usr/hdp/current/knox-server/data/deployments/kerberos.topo*
rm -rf /usr/hdp/current/knox-server/data/deployments/kerberos.topo.17679eb56b8


Restart Knox:

touch /usr/hdp/current/knox-server/data/services/atlas-api/0.8.0/service.xml
Rerun the curl cmd:


curl -ik --negotiate -u : -X GET 'https://KNOX-HOSTNAME:8443/gateway/kerberos/atlas/api/atlas/types'


Once above works, We need to use loadbalancer, for that, you need make below changes.
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

1. Make sure /etc/security/keytabs/spnego.service.keytab has all Loadlancer principals with all CNAME, copy the same spnego.service.keytab  on other Knox node
2.  Change "hadoop.auth.config.kerberos.principal" to "*" 

After making this change you may getting below error, when you run curl cmd:
-------
ERROR knox.gateway (AbstractGatewayFilter.java:doFilter(69)) - Failed to execute filter: java.lang.NoClassDefFoundError: org/apache/kerby/kerberos/kerb/keytab/Keytab
-------

This is due to https://issues.apache.org/jira/browse/KNOX-2229 . and a quick fix is to copy all kerb* jars to knox/dep/ direcory.

# cp /usr/hdp/current/hadoop-client/lib/kerb* /usr/hdp/current/knox-server/dep/

** Execute cp command on all knox hosts

Restart Knox


curl -ik --negotiate -u : -X GET 'https://LB-HOSTNAME:LB-PORT/gateway/kerberos/atlas/api/atlas/types'
```
##### Atlas Bussiness metadata 

```
curl --location --request DELETE -u admin:admin 'http://localhost:21000/api/atlas/v2/types/typedef/name/bm01'

https://knox-workshop-3.knox-workshop.root.hwx.site:31443/api/atlas/types
https://knox-workshop-3.knox-workshop.root.hwx.site:31443/api/atlas/v2/types/typedefs

```
### impala hook troubleshooting

```
To check if its issue with CDW or Impala.

We can perfrom few steps like connecting to impala and try create table and observer few details.

1. Connect to impala:

kinit with user:

impala-shell -i pravin-3.pravin.root.hwx.site -d default -k --ssl --ca_cert=/var/run/cloudera-scm-agent/process/455-impala-IMPALAD/cm-auto-in_cluster_ca_cert.pem


2. Open a new terminal.

Login into new into the impala node which we are trying to connect.

# tailf /var/log/impalad/impalad.INFO | tee /tmp/impala-latest.log

3. Login into kafka node:

Open multiple terminal for kafka node.

#I see we have already collected ATLAS_HOOK details.

# kafka-console-consumer --bootstrap-server  `hostname -f`:9093 --topic ATLAS_HOOK --consumer.config /home/client.properties

We will also check the ATLAS_ENTITIES

#  kafka-console-consumer --bootstrap-server  `hostname -f`:9093 --topic ATLAS_ENTITIES --consumer.config /home/client.properties

Also check the atlas consumer lag:

# kafka-consumer-groups --describe --bootstrap-server `hostname -f`:9093 --group atlas --command-config /home/client.properties

4. Login into atlas node:

tailf /var/log/atlas/application.log  | tee /tmp/atlas-latest.log


5. From step we can try to create a table:

create database experiments;
use experiments;
create table t1 (x int);

6. Observer, Step 3 cmds
ATLAS_HOOK , ATLAS_ENTITIES, group atlas , 

You can also check the latest lineage log file under : /var/log/impalad/lineage on the impalad which we are connected to.

any exception in atlas logs


If everything looks good, check in Atlas UI, if entity is created or not.

if not we need to collect above details.


Logs collections:

1. Login into atlas

export ATLAS_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*ATLAS_SERVER | tail -1)
ps auxwwf | grep atlas-ATLAS_SERVER > /tmp/atlas-ps.txt
env GZIP=-9  tar -cvzf atlas.tar.gz $ATLAS_PROCESS_DIR /var/log/atlas/application.log /tmp/atlas-ps.txt

2. Login into impala node which we connected to:

export IMPALAD_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*IMPALAD | tail -1)
env GZIP=-9  tar -cvzf atlas.tar.gz $IMPALAD_PROCESS_DIR /tmp/impala-latest.log  /var/log/impalad/lineage /var/log/impalad/impalad.INFO /var/log/impalad/impalad.ERROR

3. kafka cmd outputs from the console.



```
logs look like

```



kafka-console-consumer --bootstrap-server  `hostname -f`:9093 --topic ATLAS_HOOK --consumer.config /home/client.properties

{"version":{"version":"1.0.0","versionParts":[1]},"msgCompressionKind":"NONE","msgSplitIdx":1,"msgSplitCount":1,"msgSourceIP":"172.27.79.198","msgCreatedBy":"hive","msgCreationTime":1619751227952,"message":{"type":"ENTITY_CREATE_V2","user":"impala","entities":{"referredEntities":{"-79817439561753777":{"typeName":"hive_column","attributes":{"owner":"impala","qualifiedName":"experiments.movies_info.genre@cm","name":"genre","comment":null,"position":2,"type":"string"},"guid":"-79817439561753777","isIncomplete":false,"provenanceType":0,"version":0,"relationshipAttributes":{"table":{"guid":"-79817439561753773","typeName":"hive_table","uniqueAttributes":{"qualifiedName":"experiments.movies_info@cm"},"relationshipType":"hive_table_columns"}},"proxy":false},"-79817439561753776":{"typeName":"hive_column","attributes":{"owner":"impala","qualifiedName":"experiments.movies_info.name@cm","name":"name","comment":null,"position":1,"type":"varchar(50)"},"guid":"-79817439561753776","isIncomplete":false,"provenanceType":0,"version":0,"relationshipAttributes":{"table":{"guid":"-79817439561753773","typeName":"hive_table","uniqueAttributes":{"qualifiedName":"experiments.movies_info@cm"},"relationshipType":"hive_table_columns"}},"proxy":false},"-79817439561753775":{"typeName":"hive_column","attributes":{"owner":"impala","qualifiedName":"experiments.movies_info.id@cm","name":"id","comment":null,"position":0,"type":"int"},"guid":"-79817439561753775","isIncomplete":false,"provenanceType":0,"version":0,"relationshipAttributes":{"table":{"guid":"-79817439561753773","typeName":"hive_table","uniqueAttributes":{"qualifiedName":"experiments.movies_info@cm"},"relationshipType":"hive_table_columns"}},"proxy":false},"-79817439561753774":{"typeName":"hive_storagedesc","attributes":{"qualifiedName":"experiments.movies_info@cm_storage","storedAsSubDirectories":false,"location":"hdfs://pravin-1.pravin.root.hwx.site:8020/warehouse/tablespace/managed/hive/experiments.db/movies_info","compressed":false,"inputFormat":"org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat","parameters":null,"outputFormat":"org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat","serdeInfo":{"typeName":"hive_serde","attributes":{"serializationLib":"org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe","name":null,"parameters":{}}},"numBuckets":0},"guid":"-79817439561753774","isIncomplete":false,"provenanceType":0,"version":0,"relationshipAttributes":{"table":{"guid":"-79817439561753773","typeName":"hive_table","uniqueAttributes":{"qualifiedName":"experiments.movies_info@cm"},"relationshipType":"hive_table_storagedesc"}},"proxy":false}},"entities":[{"typeName":"hive_table","attributes":{"owner":"impala","tableType":"MANAGED_TABLE","temporary":false,"lastAccessTime":1619751227000,"createTime":1619751227000,"qualifiedName":"experiments.movies_info@cm","name":"movies_info","comment":null,"parameters":{"transient_lastDdlTime":"1619751227","OBJCAPABILITIES":"HIVEMANAGEDINSERTREAD,HIVEMANAGEDINSERTWRITE","transactional_properties":"insert_only","transactional":"true"},"retention":0},"guid":"-79817439561753773","isIncomplete":false,"provenanceType":0,"version":0,"relationshipAttributes":{"sd":{"guid":"-79817439561753774","typeName":"hive_storagedesc","uniqueAttributes":{"qualifiedName":"experiments.movies_info@cm_storage"},"relationshipType":"hive_table_storagedesc"},"columns":[{"guid":"-79817439561753775","typeName":"hive_column","uniqueAttributes":{"qualifiedName":"experiments.movies_info.id@cm"},"relationshipType":"hive_table_columns"},{"guid":"-79817439561753776","typeName":"hive_column","uniqueAttributes":{"qualifiedName":"experiments.movies_info.name@cm"},"relationshipType":"hive_table_columns"},{"guid":"-79817439561753777","typeName":"hive_column","uniqueAttributes":{"qualifiedName":"experiments.movies_info.genre@cm"},"relationshipType":"hive_table_columns"}],"partitionKeys":[],"db":{"typeName":"hive_db","uniqueAttributes":{"qualifiedName":"experiments@cm"},"relationshipType":"hive_table_db"}},"proxy":false}]}}}







kafka-console-consumer --bootstrap-server  `hostname -f`:9093 --topic ATLAS_ENTITIES --consumer.config /home/client.properties

{"version":{"version":"1.0.0","versionParts":[1]},"msgCompressionKind":"NONE","msgSplitIdx":1,"msgSplitCount":1,"msgSourceIP":"172.27.79.198","msgCreatedBy":"","msgCreationTime":1619751228672,"message":{"type":"ENTITY_NOTIFICATION_V2","entity":{"typeName":"hive_table","attributes":{"owner":"impala","createTime":1619751227000,"qualifiedName":"experiments.movies_info@cm","name":"movies_info"},"guid":"81f18e76-3257-450c-b196-3b50c7e273be","displayText":"movies_info","isIncomplete":false},"operationType":"ENTITY_CREATE","eventTime":1619751227966}}
{"version":{"version":"1.0.0","versionParts":[1]},"msgCompressionKind":"NONE","msgSplitIdx":1,"msgSplitCount":1,"msgSourceIP":"172.27.79.198","msgCreatedBy":"","msgCreationTime":1619751228672,"message":{"type":"ENTITY_NOTIFICATION_V2","entity":{"typeName":"hive_storagedesc","attributes":{"qualifiedName":"experiments.movies_info@cm_storage"},"guid":"d278a804-5ccf-4780-9e69-a335f3b40449","displayText":"experiments.movies_info@cm_storage","isIncomplete":false},"operationType":"ENTITY_CREATE","eventTime":1619751227966}}
{"version":{"version":"1.0.0","versionParts":[1]},"msgCompressionKind":"NONE","msgSplitIdx":1,"msgSplitCount":1,"msgSourceIP":"172.27.79.198","msgCreatedBy":"","msgCreationTime":1619751228672,"message":{"type":"ENTITY_NOTIFICATION_V2","entity":{"typeName":"hive_column","attributes":{"owner":"impala","qualifiedName":"experiments.movies_info.id@cm","name":"id"},"guid":"2237918c-9154-4725-bfc4-30b9d82cbddd","displayText":"id","isIncomplete":false},"operationType":"ENTITY_CREATE","eventTime":1619751227966}}
{"version":{"version":"1.0.0","versionParts":[1]},"msgCompressionKind":"NONE","msgSplitIdx":1,"msgSplitCount":1,"msgSourceIP":"172.27.79.198","msgCreatedBy":"","msgCreationTime":1619751228672,"message":{"type":"ENTITY_NOTIFICATION_V2","entity":{"typeName":"hive_column","attributes":{"owner":"impala","qualifiedName":"experiments.movies_info.name@cm","name":"name"},"guid":"5bd95220-5af0-4a94-947e-273095393778","displayText":"name","isIncomplete":false},"operationType":"ENTITY_CREATE","eventTime":1619751227966}}
{"version":{"version":"1.0.0","versionParts":[1]},"msgCompressionKind":"NONE","msgSplitIdx":1,"msgSplitCount":1,"msgSourceIP":"172.27.79.198","msgCreatedBy":"","msgCreationTime":1619751228672,"message":{"type":"ENTITY_NOTIFICATION_V2","entity":{"typeName":"hive_column","attributes":{"owner":"impala","qualifiedName":"experiments.movies_info.genre@cm","name":"genre"},"guid":"1cb51038-ed2f-405b-8b55-7d136b8d6336","displayText":"genre","isIncomplete":false},"operationType":"ENTITY_CREATE","eventTime":1619751227966}}
{"version":{"version":"1.0.0","versionParts":[1]},"msgCompressionKind":"NONE","msgSplitIdx":1,"msgSplitCount":1,"msgSourceIP":"172.27.79.198","msgCreatedBy":"","msgCreationTime":1619751228672,"message":{"type":"ENTITY_NOTIFICATION_V2","entity":{"typeName":"hive_db","attributes":{"owner":"impala","qualifiedName":"experiments@cm","clusterName":"cm","name":"experiments"},"guid":"06146bc1-a631-4f9d-8d0c-f1c7b71a9c0a","status":"ACTIVE","displayText":"experiments","isIncomplete":false},"operationType":"ENTITY_UPDATE","eventTime":1619751227966}}
^C21/04/30 02:54:18 INFO internals.ConsumerCoordinator: [Consumer clientId=consumer-console-consumer-29807-1, groupId=console-consumer-29807] Revoke previously assigned partitions ATLAS_ENTITIES-0
21/04/30 02:54:18 INFO internals.AbstractCoordinator: [Consumer clientId=consumer-console-consumer-29807-1, groupId=console-consumer-29807] Member consumer-console-consumer-29807-1-d9143306-5fc3-41c4-85f0-8232b6b79594 sending LeaveGroup request to coordinator pravin-3.pravin.root.hwx.site:9093 (id: 2147483579 rack: null) due to the consumer is being closed
21/04/30 02:54:18 WARN kerberos.KerberosLogin: [Principal=kafka/pravin-1.pravin.root.hwx.site@ROOT.HWX.SITE]: TGT renewal thread has been interrupted and will exit.
Processed a total of 6 messages
[ro


[root@pravin-3 lineage]# #tailf impala_lineage_log_1.0-1618308657670
[root@pravin-3 lineage]# pwd
/var/log/impalad/lineage

{"queryText":"CREATE TABLE MOVIES_INFO ( id int, name varchar(50), genre string )","queryId":"8240ff9777868c61:9bde95c300000000","hash":"d1c8f558a067a35a603b2e90904ccbc4","user":"impala/pravin-2.pravin.root.hwx.site@ROOT.HWX.SITE","timestamp":1619751227,"endTime":1619751227,"edges":[],"vertices":[]}



```

```
export KAFKA_BROKER_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*KAFKA_BROKER | tail -1)
kinit -kt $KAFKA_BROKER_PROCESS_DIR/kafka.keytab kafka/`hostname -f`

cat $KAFKA_BROKER_PROCESS_DIR/jaas.conf

Create a new jaas file: and update the keytab and principal from above jass file

$ vi  /tmp/jaas1.conf

KafkaClient {
com.sun.security.auth.module.Krb5LoginModule required
useKeyTab=true
keyTab="/var/run/cloudera-scm-agent/process/118-kafka-KAFKA_BROKER/kafka.keytab"
principal="kafka/pravinkms-1.pravinkms.root.hwx.site@ROOT.HWX.SITE";
};

$ vi  /tmp/client.properties
sasl.kerberos.service.name=kafka
security.protocol=SASL_PLAINTEXT

$ export KAFKA_OPTS='-Djava.security.auth.login.config=/tmp/jaas1.conf'

$ kafka-topics --list --bootstrap-server `hostname -f`:9092 --command-config /tmp/client.properties | tee /tmp/kafka-list.log

# Also check the atlas consumer lag:
$ kafka-consumer-groups --describe --bootstrap-server `hostname -f`:9092 --group atlas --command-config /tmp/client.properties | tee /tmp/kafka-consumer-atlas.log


Step 3 # We will also check the ATLAS_ENTITIES
$ kafka-console-consumer --bootstrap-server  `hostname -f`:9092 --topic ATLAS_ENTITIES --consumer.config /tmp/client.properties | tee /tmp/kafka-ATLAS_ENTITIES.log

Step 4, Open a new terminal Login into atlas node:

tailf /var/log/atlas/application.log  | tee /tmp/atlas-latest.log

try to create a table when you have cmd from "Step 3" running.

connect to beeline:
create database experiments;
use experiments;
create table t1 (x int);

attach /tmp/kafka-list.log, /tmp/kafka-consumer-atlas.log, /tmp/kafka-ATLAS_ENTITIES.log , /tmp/atlas-latest.log
```

1. https://community.hortonworks.com/articles/81680/atlas-tag-based-searches-utilizing-the-atlas-rest.html 
2. https://community.hortonworks.com/articles/39759/list-atlas-tags-and-traits.html 
3. https://community.hortonworks.com/articles/58220/howto-install-and-configure-high-availability-on-a.html 
4. https://community.hortonworks.com/articles/61274/import-hive-metadata-into-atlas.html 
5. https://hortonworks.com/hadoop-tutorial/cross-component-lineage-apache-atlas/ 
6. https://hortonworks.com/tutorial/tag-based-policies-with-apache-ranger-and-apache-atlas/ 
