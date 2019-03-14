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
============================================================================================================================

For a Kerberos env kinit with Ambari Infra keytab
###### Kinit with Ambari Infra keytab
```shell
kinit -kt /etc/security/keytabs/ambari-infra-solr.service.keytab $(klist -kt /etc/security/keytabs/ambari-infra-solr.service.keytab |sed -n "4p"|cut -d ' ' -f7)
```

# Delete Collections
###### This is for Ranger audit collection
```shell
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=ranger_audits"
```

###### This is for Atlas collection
```shell
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=fulltext_index"
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=edge_index"
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=vertex_index"
```

###### This is for Logsearch collection
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
###### Usefull curl's
```shell
curl -ik --negotiate -u : "http://$(hostname -f):8886/solr/admin/cores?action=STATUS&wt=json&indent=true"
curl -ik --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=clusterstatus&wt=json&indent=true"
curl -ik --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=delete&name=ranger_audits"
curl -ik --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?collection=ranger_audit&shard=shard1∾tion=SPLITSHARD

```
###### Disable kerberos cache for solr

```shell
SOLR_OPTS="$SOLR_OPTS -Xss256k -Dsun.security.krb5.rcache=none"
```

###### Start Ambari Infra manully
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

###### Download the `solrconfig.xml` from Zookeeper
```shell
/usr/lib/ambari-infra-solr/server/scripts/cloud-scripts/zkcli.sh --zkhost horton0.example.com:2181 -cmd getfile /infra-solr/configs/ranger_audits/solrconfig.xml solrconfig.xml
```
Edit the file or use sed to replace the `90 Days` in the `solrconfig.xml`
`sed -i 's/+90DAYS/+14DAYS/g' solrconfig.xml`

###### Upload the config back to Zookeeper

```shell
/usr/lib/ambari-infra-solr/server/scripts/cloud-scripts/zkcli.sh --zkhost horton0.example.com:2181 -cmd putfile /infra-solr/configs/ranger_audits/solrconfig.xml solrconfig.xml
```
###### Reload the config
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
`1. /usr/lib/ambari-infra-solr-client/solrCloudCli.sh --zookeeper-connect-string <zk>:2181,<zk>:2181,<zk>:2181/infra-solr --create-collection --collection ranger_audits --config-set ranger_audits --shards 2 --replication 2 --max-shards 2 

2. /usr/lib/ambari-infra-solr-client/solrCloudCli.sh --zookeeper-connect-string <zk>:2181,<zk>:2181,<zk>:2181 --znode /infra-solr --setup-kerberos-plugin --jaas-file /etc/ambari-infra-solr/conf/infra_solr_jaas.conf --secure --security-json-location /etc/ambari-infra-solr/conf/security.json 

3. /usr/lib/ambari-infra-solr-client/solrCloudCli.sh --zookeeper-connect-string <zk>:2181,<zk>:2181,<zk>:2181/infra-solr --create-collection --collection ranger_audits --config-set ranger_audits --shards 1 --replication 1 --max-shards 3 --retry 5 --interval 10 --no-sharding --jaas-file /etc/ambari-infra-solr/conf/infra_solr_jaas.conf

4. /opt/lucidworks-hdpsearch/solr/bin/solr create -c collection -n configset -s 1 -rf 1

5. curl -i --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=CREATE&ranger_audits=newCollection&numShards=2&replicationFactor=2"

6. curl -i --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=CREATE&name=ranger&numShards=2&replicationFactor=2&maxShardsPerNode=2&createNodeSet=<zk>:2181,<zk>:2181,<zk>:2181/solr&collection.configName=ranger_audits

```
## Deleting Indexed Data

In delete mode `(-m delete)`, the program deletes data from the Solr collection. This mode uses the filter field `(-f FITLER_FIELD)` option to control which data should be removed from the index.

The command below will delete log entries from the hadoop_logs collection, which have been created before `August 29, 2017`, we'll use the -f option to specify the field in the Solr collection to use as a filter field, and the -e option to denote the end of the range of values to remove.

`infra-solr-data-manager -m delete -s http://<solr-hostname>:8886/solr -c hadoop_logs -f logtime -e 2017-08-29T12:00:00.000Z`

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

* Restart all the Solr instances
* You can check the solr.log for any errors
* You can verify by logging into the `Ranger Admin Web interface ­> Audit > Plugins`
* Make sure to create required policies for users. If users are getting denied, please check the audit logs.

- [Performance Tuning for Ambari Infra](https://docs.hortonworks.com/HDPDocuments/Ambari-2.6.2.0/bk_ambari-operations/content/performance_tuning_for_ambari_infra.html)
- [Securing Solr Collections with Ranger + Kerberos](https://community.hortonworks.com/articles/15159/securing-solr-collections-with-ranger-kerberos.html)
- [Setup Ranger to use Ambari Infra Solr enabled in SSL](https://community.hortonworks.com/articles/92987/setup-ranger-to-use-ambari-infra-solr-enabled-in-s.html)
- [User authentication from Windows Workstation to HDP Realm Using MIT Kerberos Client (with Firefox)](https://community.hortonworks.com/articles/28537/user-authentication-from-windows-workstation-to-hd.html)
- [Setup Ambari Infra Solr to store indices on HDFS](https://community.hortonworks.com/articles/87093/setup-ambari-infra-solr-to-store-indices-on-hdfs.html)
- [Banana](https://github.com/lucidworks/banana/wiki/Installation-and-Quick-Start)
- [ams-solr-metrics-mpack](https://github.com/oleewere/ams-solr-metrics-mpack)
- []
- []
