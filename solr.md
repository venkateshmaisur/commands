# Solr Commands

https://bhagadepravin.github.io/commands/solr

- [Delete Collections](https://github.com/bhagadepravin/commands/blob/master/solr.md#delete-collections)
- [download config](https://github.com/bhagadepravin/commands/blob/master/solr.md#download-ambariinfra-config)
- [Upload AmbariInfra config](https://github.com/bhagadepravin/commands/blob/master/solr.md#upload-ambariinfra-config)
- [Solr corruption](https://github.com/bhagadepravin/commands/blob/master/solr.md#solr-corruption)
- [Enable Heap dump](https://github.com/bhagadepravin/commands/blob/master/solr.md#enable-heap-dump)
- [Kerberos Debug](https://github.com/bhagadepravin/commands/blob/master/solr.md#kerberos-debug)
- [Solr Triage](https://github.com/bhagadepravin/commands/blob/master/solr.md#solr-triage)
- [Set TTL value:](https://github.com/bhagadepravin/commands/blob/master/solr.md#set-ttl-value)
- [Enabled Audit provider summary for services.](https://github.com/bhagadepravin/commands/blob/master/solr.md#enabled-audit-provider-summary-for-services)
- [Create the collection](https://github.com/bhagadepravin/commands/blob/master/solr.md#create-the-collection)
- [Deleting Indexed Data](https://github.com/bhagadepravin/commands/blob/master/solr.md#deleting-indexed-data)
- [Archiving Indexed Data](https://github.com/bhagadepravin/commands/blob/master/solr.md#archiving-indexed-data)
- [Saving Indexed Data](https://github.com/bhagadepravin/commands/blob/master/solr.md#saving-indexed-data)
- [Configuring Solr for Ranger](https://github.com/bhagadepravin/commands/blob/master/solr.md#configuring-solr-for-ranger)
====================================================================================
                                                                                     
For a Kerberos env kinit with Ambari Infra keytab
## Kinit with Ambari Infra keytab
```shell
kinit -kt /etc/security/keytabs/ambari-infra-solr.service.keytab $(klist -kt /etc/security/keytabs/ambari-infra-solr.service.keytab |sed -n "4p"|cut -d ' ' -f7)
```

# Delete Collections
## This is for Ranger audit collection
```shell
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=ranger_audits"
```

## This is for Atlas collection
```shell
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=fulltext_index"
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=edge_index"
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=vertex_index"
```

## This is for Logsearch collection
```shell
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=history"
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=hadoop_logs"
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=audit_logs"
```

###### CLUSTERSTATUS
```shell
curl -ik --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=LIST&wt=json"
curl -ik --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=CLUSTERSTATUS&wt=json"
```
## Usefull curl's
```shell
curl -ik --negotiate -u : "http://$(hostname -f):8886/solr/admin/cores?action=STATUS&wt=json&indent=true"
curl -ik --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=clusterstatus&wt=json&indent=true"
curl -ik --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=delete&name=ranger_audits"
curl -ik --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?collection=ranger_audit&shard=shard1∾tion=SPLITSHARD

```
## Disable kerberos cache for solr

```shell
Amabri UI --> Solr --> Config --> Advanced --> Advanced solr-config-env --> solr.in.sh template

ADD below parameter in the end

SOLR_OPTS="$SOLR_OPTS -Xss256k -Dsun.security.krb5.rcache=none"
```

## Start Ambari Infra manully
```
#/usr/lib/ambari-infra-solr/bin/solr start -cloud -noprompt -s /opt/ambari_infra_solr/data >> /var/log/ambari-infra-solr/solr-install.log 2>&1 
```

## Download AmbariInfra config

```shell
/usr/lib/ambari-infra-solr-client/solrCloudCli.sh --zookeeper-connect-string <zk>:2181,<zk>:2181,<zk>:2181/infra-solr --download-config --config-dir /var/lib/ambari-agent/tmp/solr_config_ranger_audits_0.863108405923 --config-set ranger_audits
```
> /opt/lucidworks-hdpsearch/solr/server/scripts/cloud-scripts/zkcli.sh-zkhost <zookeeper host>:<zookeeper port>/solr -cmd downconfig -confdir /tmp/solr_conf -confname <collection-name>
  
## Upload AmbariInfra config
```shell 
/usr/lib/ambari-infra-solr-client/solrCloudCli.sh --zookeeper-connect-string pravin2.openstacklocal:2181,pravin1.openstacklocal:2181,pravin3.openstacklocal:2181/infra-solr --upload-config --config-dir /var/lib/ambari-agent/tmp/solr_config_ranger_audits_0.86310840592 --config-set ranger_audits --retry 30 --interval 5 --jaas-file /usr/hdp/current/ranger-admin/conf/ranger_solr_jaas.conf
```

> /opt/lucidworks-hdpsearch/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost ey9omprna004.vzbi.com:2181/solr -cmd upconfig -confdir /tmp/solr_conf -confname collection1 

## Solr corruption
###### To check for corruptions: 
```javascript 
java -cp /usr/lib/ambari-infra-solr/server/solr-webapp/webapp/WEB-INF/lib/lucene-core-5.5.2.jar org.apache.lucene.index.CheckIndex INDEX_DATA_PATH
```
###### Use below command to fix any corruption on index.
```java
java -cp /usr/lib/ambari-infra-solr/server/solr-webapp/webapp/WEB-INF/lib/lucene-core-5.5.2.jar org.apache.lucene.index.CheckIndex INDEX_DATA_PATH -exorcise
```

## Enable Heap dump
NOTE: Please specify `JAVA_GC_LOG_DIR` to a disk volume which has at least 10GB disk space (with Xmx8GB) 
```java
JAVA_GC_LOG_DIR=/opt/solr 
GC_TUNE="-XX:+UseG1GC -XX:+PerfDisableSharedMem -XX:+ParallelRefProcEnabled -XX:G1HeapRegionSize=15m -XX:MaxGCPauseMillis=250 -XX:InitiatingHeapOccupancyPercent=75 -XX:+UseLargePages -XX:+AggressiveOpts -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${JAVA_GC_LOG_DIR%/}/" 
```
## Kerberos Debug
```shell
export KRB5_TRACE=/tmp/curl-krb.log
kinit <user-principal>
klist -eaf
curl -iv --negotiate -u : http://<solr-hostname>:8983/solr
```

# Solr Triage

###### Get solrconfig.xml 
```shell
/usr/lib/ambari-infra-solr/server/scripts/cloud-scripts/zkcli.sh -zkhost 
<ZkHost>:2181 -cmd getfile /infra-solr/configs/ranger_audits/solrconfig.xml solrconfig.xml 
```
```shell
du -sch /opt/ambari_infra_solr/data/*
grep SOLR_HOME /etc/ambari-infra-solr/conf/infra-solr-env.sh
du -h /opt/ambari_infra_solr/data
```

###### Get state.json 
```shell
/usr/lib/ambari-infra-solr/server/scripts/cloud-scripts/zkcli.sh -zkhost apollo2.openstacklocal:2181 -cmd getfile /infra-solr/collections/ranger_audits/state.json state.json
```
###### Collecting OS related outputs ("root" required) as well ambari infra configs and logs.
```shell
sudo sh -xc '(date;hostname -A;uname -a;top -b -n 1 -c;ps auxwwwf;netstat -aopen;free -g;ifconfig;cat /proc/meminfo;df -h;mount;vmstat -d;nscd -g;iptables -t nat -nL;env;sysctl -a;sar -A;date)&>/tmp/os_cmds.out'
```
```shell
ls -ltr /var/log/ambari-infra-solr/ > /var/tmp/solrls.txt
```
```shell
tar -czvhf ./ambari_infra_$(hostname)_$(date +"%Y%m%d%H%M%S").tgz /etc/ambari-infra-solr/conf/* /var/tmp/solrls.txt  /tmp/os_cmds.out /var/log/ambari-infra-solr/solr.log /var/log/ambari-infra-solr/solr_gc.log 
```

Screenshot of `SOLR UI>>Cloud>>graph`

## Set TTL value:
- [Follow link to configure TTL value:](https://github.com/bhagadepravin/commands/blob/master/solr.md#set-ttl-value)

## Download the `solrconfig.xml` from Zookeeper
```shell
/usr/lib/ambari-infra-solr/server/scripts/cloud-scripts/zkcli.sh --zkhost horton0.example.com:2181 -cmd getfile /infra-solr/configs/ranger_audits/solrconfig.xml solrconfig.xml
```
Edit the file or use sed to replace the `90 Days` in the `solrconfig.xml`
`sed -i 's/+90DAYS/+14DAYS/g' solrconfig.xml`

## Upload the config back to Zookeeper

```shell
/usr/lib/ambari-infra-solr/server/scripts/cloud-scripts/zkcli.sh --zkhost horton0.example.com:2181 -cmd putfile /infra-solr/configs/ranger_audits/solrconfig.xml solrconfig.xml
```
## Reload the config
`curl -v --negotiate -u : "http://horton0.example.com:8983/solr/admin/collections?action=RELOAD&name=ranger_audits"`

## Enabled Audit provider summary for services.
Ambari UI --> HDFS --> Configs --> Advanced --> Advanced ranger-`hdfs`-audit --> Check [Audit provider summary enabled] 
Ref: https://cwiki.apache.org/confluence/display/RANGER/Ranger+0.5+Audit+Configuration#Ranger0.5AuditConfiguration-Summarization 

## Delete the collection: 
```shell
/usr/lib/ambari-infra-solr-client/solrCloudCli.sh --zookeeper-connect-string <zk>:2181,<zk>:2181,<zk>:2181/infra-solr --delete-collection --collection ranger_audits 

http://<localhost>:8886/solr/admin/collections?action=CREATE&name=ranger_audits&numShards=2&replicationFactor=2&maxShardsPerNode=2&createNodeSet=<zk>:2181,<zk>:2181,<zk>:2181/infra-solr&collection.configName=ranger_audits
```
## Create the collection: 
```shell
1. /usr/lib/ambari-infra-solr-client/solrCloudCli.sh --zookeeper-connect-string <zk>:2181,<zk>:2181,<zk>:2181/infra-solr --create-collection --collection ranger_audits --config-set ranger_audits --shards 2 --replication 2 --max-shards 2 

2. /usr/lib/ambari-infra-solr-client/solrCloudCli.sh --zookeeper-connect-string <zk>:2181,<zk>:2181,<zk>:2181 --znode /infra-solr --setup-kerberos-plugin --jaas-file /etc/ambari-infra-solr/conf/infra_solr_jaas.conf --secure --security-json-location /etc/ambari-infra-solr/conf/security.json 

3. /usr/lib/ambari-infra-solr-client/solrCloudCli.sh --zookeeper-connect-string <zk>:2181,<zk>:2181,<zk>:2181/infra-solr --create-collection --collection ranger_audits --config-set ranger_audits --shards 1 --replication 1 --max-shards 3 --retry 5 --interval 10 --no-sharding --jaas-file /etc/ambari-infra-solr/conf/infra_solr_jaas.conf

4. /opt/lucidworks-hdpsearch/solr/bin/solr create -c collection -n configset -s 1 -rf 1

5. curl -i --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=CREATE&ranger_audits=newCollection&numShards=2&replicationFactor=2"

6. curl -i --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=CREATE&name=ranger&numShards=2&replicationFactor=2&maxShardsPerNode=2&createNodeSet=<zk>:2181,<zk>:2181,<zk>:2181/solr&collection.configName=ranger_audits

```
## Deleting Indexed Data

In delete mode `(-m delete)`, the program deletes data from the Solr collection. This mode uses the filter field `(-f FITLER_FIELD)` option to control which data should be removed from the index.

The command below will delete log entries from the hadoop_logs collection, which have been created before `August 29, 2017`, we'll use the -f option to specify the field in the Solr collection to use as a filter field, and the -e option to denote the end of the range of values to remove.

```sh
Action Plan:

  Deleting ranger_audit collection, we have two options, a curl cmd and infra-solr-data-manager cmd line tool.

  For both operation, if data is huge.

  Lets say you have 200GB of data, when you hit curl or infra-solr-data-manager cmd, Infra solr takes a backup of data, now you have 400GB of data, then depending upon the filter it will delete the ranger_audit data and the backup as well.

  In this process most of the time Infra-Solr goes down due to OOM(java heap) issue, becuase it require much memory to perform this task.

  So, before you perfrom this task, you must increase the infra heap to 25-30GB or thrice of existig memory size, Make sure you have enough disk space as well.


  Check the datadir used by Infra-Solr

  # ps aux | grep infra-solr  | grep Dsolr.solr.home --color

  By default its  /var/lib/ambari-infra-solr/data

   check the size of data dir on all infra nodes:

   # du -sch /var/lib/ambari-infra-solr/data/*

  Purging Data of kerberos cluster
  Ref: https://docs.hortonworks.com/HDPDocuments/Ambari-2.6.2.0/bk_ambari-operations/content/amb_infra_arch_n_purge_command_line_operations.html

  # /usr/bin/infra-solr-data-manager --mode=delete --solr-keytab=/etc/security/keytabs/ambari-infra-solr.service.keytab --solr-principal=infra-solr/c374-node4.squadron-labs.com@HWX.COM --solr-url=http://c374-node4.squadron-labs.com:8886/solr --collection=ranger_audits --filter-field=evtTime --days=30 

  above cmd is single line, make sure you replcase below property.

  --solr-principal
  --solr-url
  --days    -- by default TTL is 90days, ranger_audit keeps the data of 90 days.


  Purging Data of non-kerberos cluster

  # /usr/bin/infra-solr-data-manager --mode=delete --solr-url=http://c374-node4.squadron-labs.com:8886/solr --collection=ranger_audits --filter-field=evtTime --days=30 


  You have run above cmd on ay Infra-solr node once.
  
# /usr/bin/infra-solr-data-manager --mode=delete --solr-keytab=/etc/security/keytabs/ambari-infra-solr.service.keytab --solr-principal=infra-solr/c374-node4.squadron-labs.com@HWX.COM --solr-url=http://c374-node4.squadron-labs.com:8886/solr --collection=ranger_audits --filter-field=evtTime --days=30
You are running Solr Data Manager 1.0 with arguments:
  mode: delete
  solr-url: http://c374-node4.squadron-labs.com:8886/solr
  collection: ranger_audits
  filter-field: evtTime
  days: 30
  date-format: %Y-%m-%dT%H:%M:%S.%fZ
  solr-keytab: /etc/security/keytabs/ambari-infra-solr.service.keytab
  solr-principal: infra-solr/c374-node4.squadron-labs.com@HWX.COM
  skip-date-usage: False
  verbose: False

2019-05-10 08:25:50,061 - The end date will be: 2019-04-10T08:25:50.061498Z
2019-05-10 08:25:50,061 - Deleting data where evtTime <= 2019-04-10T08:25:50.061498Z
--- 0.400218963623 seconds ---
```
```
---- 
curl -ikv --negotiate -u: "http://$(hostname -f):8886/solr/hadoop_logs/update?commit=true" -H "Content-Type: text/xml" --data-binary "<delete><query>@timestamp:[* TO NOW-1DAYS]</query></delete>" 
--- 
```

## Archiving Indexed Data

In archive mode, the program fetches data from the Solr collection and writes it out to HDFS or S3, then deletes the data.

`infra-solr-data-manager -m archive -s http://<solr-hostname>:8886/solr -c hadoop_logs -f logtime -d 1 -r 10 -w 100 -x /tmp -v`
 
## Saving Indexed Data

Saving is similar to Archiving data except that the data is not deleted from Solr after the files are created and uploaded. The Save mode is recommended for testing that the data is written as expected before running the program in Archive mode with the same parameters.

The below example will save the last 3 days of hdfs audit logs into HDFS path "/" with the user hdfs, fetching data from a kerberized Solr.

```shell
infra-solr-data-manager -m save -s http://<solr-hostname>:8886/solr -c audit_logs -f logtime -d 3 -r 10 -w 100 -q type:\”hdfs_audit\” -j hdfs_audit -k /etc/security/keytabs/ambari-infra-solr.service.keytab -n infra-solr/c6401.ambari.apache.org@AMBARI.APACHE.ORG -u hdfs -p /
```
Ref: https://docs.hortonworks.com/HDPDocuments/Ambari-2.6.2.0/bk_ambari-operations/content/amb_infra_arch_n_purge_command_line_operations.html


## Configuring Solr for Ranger
Solr needs to be configured to use Ranger Authorization implementation. For that, run the following command on one of the Solr host
```shell
$SOLR_INSTALL_HOME/server/scripts/cloud-scripts/zkcli.sh -zkhost  $ZK_HOST:2181 -cmd put /solr/security.json '{"authentication":{"class": "org.apache.solr.security.KerberosPlugin"},"authorization":{"class": "org.apache.ranger.authorization.solr.authorizer.RangerSolrAuthorizer"}}'
```

1. Restart all the Solr instances
2. You can check the solr.log for any errors
3. You can verify by logging into the `Ranger Admin Web interface ­> Audit > Plugins`
4. Make sure to create required policies for users. If users are getting denied, please check the audit logs.

##########################################################################################

## Solr performance tunnning on service side

```sh
1. Enable summarization. 

Summarization 
https://cwiki.apache.org/confluence/display/RANGER/Ranger+0.5+Audit+Configuration#Ranger0.5AuditConfiguration-Summarization 

In high volume systems, like kafka a very large number of audit messages can be generated in a short amount of time. For compliance and for other practical reasons, like threat detection, it may not be desirable to throttle back the amount or granularity of auditing. 

Ranger 0.5 adds the ability to summarize audit messages in such situations while preserving the distinguishing traits of each audit message. To ensure that no unique/distinguishing information is lost, during summarization, audit messages are aggregated if and only if they differ only in their time stamp. If anything else about an audit is different then it is preserved as a separate audit message. Further in interest of capturing as much information as possible the time interval on the aggregate audit message denotes the max and min time of actual audit events that were a part for that summary event. 

Ambari UI --> HIVE --> Configs --> Advanced --> Advanced ranger-hive-audit --> Check [Audit provider summary enabled] 

Same way you need to do it for all service for which you have enabled Ranger puginn, like HDFS, hbase,etc 

2. Batching and bulk write of of audit messages 
https://cwiki.apache.org/confluence/display/RANGER/Ranger+0.5+Audit+Configuration 

It can be faster to write several messages to solr in a batch rather than write them one at a time. Similarly when writing audit messages to a database it is much faster to batch write of several messages into a single transaction. Ranger Audit framework provides this via the use of buffer queues. 

batch.size 

By default up to 1000 messages are given to these Audit Destination providers at a time to write. This value can be used to tune that count. 

Ambari > HDFS > Configs > Advanced > Custom ranger-hdfs-audit 

xasecure.audit.destination.hdfs.batch.size=10000 
xasecure.audit.destination.solr.batch.size=10000 
xasecure.audit.hdfs.async.max.queue.size= 30720 
xasecure.audit.solr.async.max.queue.size= 30720 

Ref: https://hortonworks.com/blog/apache-ranger-audit-framework/ 

```

- [Performance Tuning for Ambari Infra](https://docs.hortonworks.com/HDPDocuments/Ambari-2.6.2.0/bk_ambari-operations/content/performance_tuning_for_ambari_infra.html)
- [Securing Solr Collections with Ranger + Kerberos](https://community.hortonworks.com/articles/15159/securing-solr-collections-with-ranger-kerberos.html)
- [Setup Ranger to use Ambari Infra Solr enabled in SSL](https://community.hortonworks.com/articles/92987/setup-ranger-to-use-ambari-infra-solr-enabled-in-s.html)
- [User authentication from Windows Workstation to HDP Realm Using MIT Kerberos Client (with Firefox)](https://community.hortonworks.com/articles/28537/user-authentication-from-windows-workstation-to-hd.html)
- [Setup Ambari Infra Solr to store indices on HDFS](https://community.hortonworks.com/articles/87093/setup-ambari-infra-solr-to-store-indices-on-hdfs.html)
- [Banana](https://github.com/lucidworks/banana/wiki/Installation-and-Quick-Start)
- [ams-solr-metrics-mpack](https://github.com/oleewere/ams-solr-metrics-mpack)
- []
- []
