# - [x] Solr Commands



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

###### Disable kerberos cache for solr

```shell
SOLR_OPTS="$SOLR_OPTS -Xss256k -Dsun.security.krb5.rcache=none"
```

###### Start Ambari Infra manully
```
#/usr/lib/ambari-infra-solr/bin/solr start -cloud -noprompt -s /opt/ambari_infra_solr/data >> /var/log/ambari-infra-solr/solr-install.log 2>&1 
```

## Download AmbariInfra config

1. 
```shell
/usr/lib/ambari-infra-solr-client/solrCloudCli.sh --zookeeper-connect-string <zk>:2181,<zk>:2181,<zk>:2181/infra-solr --download-config --config-dir /var/lib/ambari-agent/tmp/solr_config_ranger_audits_0.863108405923 --config-set ranger_audits
```
2. 
> /opt/lucidworks-hdpsearch/solr/server/scripts/cloud-scripts/zkcli.sh-zkhost <zookeeper host>:<zookeeper port>/solr -cmd downconfig -confdir /tmp/solr_conf -confname <collection-name>
  
## Upload AmbariInfra config
1.
```shell
/usr/lib/ambari-infra-solr-client/solrCloudCli.sh --zookeeper-connect-string pravin2.openstacklocal:2181,pravin1.openstacklocal:2181,pravin3.openstacklocal:2181/infra-solr --upload-config --config-dir /var/lib/ambari-agent/tmp/solr_config_ranger_audits_0.86310840592 --config-set ranger_audits --retry 30 --interval 5 --jaas-file /usr/hdp/current/ranger-admin/conf/ranger_solr_jaas.conf
```

2.
> /opt/lucidworks-hdpsearch/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost ey9omprna004.vzbi.com:2181/solr -cmd upconfig -confdir /tmp/solr_conf -confname collection1 


