# Solr Commands

https://bhagadepravin.github.io/commands/solr

## Delete collection by running curl from solr node

For a Kerberos env kinit with with keytab
###### Kinit with Ambari Infra keytab
```shell
kinit -kt /etc/security/keytabs/ambari-infra-solr.service.keytab $(klist -kt /etc/security/keytabs/ambari-infra-solr.service.keytab |sed -n "4p"|cut -d ' ' -f7)
```

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

###### attach solrconfig.xml 
```shell
/usr/lib/ambari-infra-solr/server/scripts/cloud-scripts/zkcli.sh -zkhost 
<ZkHost>:2181 -cmd getfile /infra-solr/configs/ranger_audits/solrconfig.xml solrconfig.xml 
```
```java
du -sch /opt/ambari_infra_solr/data/*
grep SOLR_HOME /etc/ambari-infra-solr/conf/infra-solr-env.sh
du -h /opt/ambari_infra_solr/data
```

###### attach state.json 
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

Refer : https://community.hortonworks.com/articles/63853/solr-ttl-auto-purging-solr-documents-ranger-audits.html

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
Example: Ambari UI > HDFS > Configs > Advanced > Advanced ranger-<service>-audit


