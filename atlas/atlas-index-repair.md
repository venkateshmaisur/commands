Atlas Index repair

```bash
Since the default Hive database shows up in Advanced search in Atlas UI, there seems to be something wrong with indexing in Solr. 
In the workaround, we are going to delete the Atlas collections in Solr and then rebuild the index data from HBase.

Please follow these steps:
=====
1. Stop atlas
2. Remove all atlas collections in Solr:

-----Non Kerberos Env --------
curl "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=vertex_index"
curl "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=fulltext_index"
curl "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=edge_index"

----- For Kerbeors Env-----
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=fulltext_index"
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=edge_index"
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=vertex_index"
--------------------------------
To confirm if collections are deleted successfully, you can list the collections:
curl -ik --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=LIST&wt=json"

3. Start atlas and observe that collections are recreated
4. Can't search 'employee' table in atlas Basic search. it's searchable however, in Advanced search
5. Implemented steps from https://github.com/apache/atlas/tree/branch-0.8/tools/atlas-index-repair-kit
6. navigate to atlas host and /opt directory
# cd /opt
7. download titan-0.5.4-hadoop2.zip
# wget http://s3.thinkaurelius.com/downloads/titan/titan-0.5.4-hadoop2.zip
8. unzip titan-0.5.4-hadoop2.zip file
# unzip titan-0.5.4-hadoop2.zip
9. Navigate to /opt/titan-0.5.4-hadoop2
# cd /opt/titan-0.5.4-hadoop2
10. download and extract index repair kit
-----
# wget https://raw.githubusercontent.com/apache/atlas/branch-0.8/tools/atlas-index-repair-kit/atlas-index-repair-kit.tar.gz
# tar xvf atlas-index-repair-kit.tar.gz
-----
11. Update atlas-conf/atlas-titan.properties with details to connect to data-store (like HBase). For example:
$ grep storage /usr/hdp/current/atlas-server/conf/atlas-application.properties

     storage.backend=hbase
     storage.hostname=fqdn
     storage.hbase.table=atlas_titan
-----
12. Add following properties in bin/atlas-gremlin.sh at the top of the file:
-----
  ATLAS_WEBAPP_DIR=/usr/hdp/current/atlas-server/server/webapp/
STORE_CONF_DIR=/etc/hbase/conf/
-----
13. Ensure home directory for 'atlas' user exists in HDFS and this directory is owned by 'atlas' user
# su hdfs
$ hdfs dfs -mkdir /user/atlas
$ hdfs dfs -chown atlas:hdfs /user/atlas

set JAVA_HOME
ps aux | grep atlas
export JAVA_HOME=/usr/jdk64/jdk1.8.0_112

14. Start Gremlin shell by executing the following command:
bin/atlas-gremlin.sh bin/atlas-index-repair.groovy

15. Start index repair by entering the following in the Gremlin shell:
> repairAtlasIndex('/etc/atlas/conf/atlas-application.properties')
=====

I believe your customer has Kerberos enabled. Youll need to implement the following steps after step 12:
=====
5. If Atlas is run in a kerberized environment, setup the following:
5.1. Update /etc/atlas/conf/atlas-application.properties with necessary kerberos details for the data-store and index. For example:
hbase.security.authentication=kerberos
hbase.security.authorization=true
hbase.rpc.engine=org.apache.hadoop.hbase.ipc.SecureRpcEngine
index.search.backend=solr5
index.search.solr.mode=cloud
index.search.solr.zookeeper-url=fqdn:2181/infra-solr

5.2. Copy necessary configuration files from the deployment to atlas-conf folder. For example:
hadoop-client/conf/core-site.xml
hadoop-client/conf/hdfs-site.xml
hadoop-client/conf/yarn-site.xml
ambari-infra-solr/conf/infra_solr_jaas.conf
ambari-infra-solr/conf/security.json

5.3. Update bin/atlas-gremlin.sh to set the following variable at the top. For example:
JAAS_CONF_FILE=infra_solr_jaas.conf

5.4. Kinit as atlas user with the command like:
kinit -kt /etc/security/keytabs/atlas.service.keytab atlas/fqdn@EXAMPLE.COM
=====

Refer:
https://github.com/apache/atlas/tree/branch-0.8/tools/atlas-index-repair-kit




java.lang.IllegalArgumentException: Could not instantiate implementation: com.thinkaurelius.titan.diskstorage.hbase.HBaseStoreManager
at com.thinkaurelius.titan.util.system.ConfigurationUtil.instantiate(ConfigurationUtil.java:55)
at com.thinkaurelius.titan.diskstorage.Backend.getImplementationClass(Backend.java:421)
at com.thinkaurelius.titan.diskstorage.Backend.getStorageManager(Backend.java:361)
at com.thinkaurelius.titan.graphdb.configuration.GraphDatabaseConfiguration.<init>(GraphDatabaseConfiguration.java:1275)
at com.thinkaurelius.titan.core.TitanFactory.open(TitanFactory.java:93)
at com.thinkaurelius.titan.core.TitanFactory.open(TitanFactory.java:61)
at com.thinkaurelius.titan.core.TitanFactory$open.call(Unknown Source)
.
.
.
.
.
.
=====>>>
To fix this, we copied the hdfs-site.xml and core-site.xml from /etc/hadoop/conf to /etc/hbase/conf





curl --negotiate -u: 'http://<solr host>:<port>/solr/vertex_index/select?q=iyt_t:hive_db&distrib=false&rows=500&wt=json' | python -m json.tool





Since atlas-index-repair-kit is already setup in your Atlas host, can you run index repair for a missing entity guid id of default db, please find below steps

1) kinit with atlas keytab

2) Start Gremlin shell by executing the following command (I recall it was under /opt directory. Your end customer Tejaswee should know about this):
# bin/atlas-gremlin.sh bin/atlas-index-repair.groovy

3) Repair single entity with its guid.
repairAtlasEntity('/usr/hdp/<hdp-version>/atlas/conf/atlas-application.properties', '<missing entity GUID id of default db>')

How to find the GUID of default database?
- log in to Atlas UI
- switch to Advanced Search
- type in the query: where name='default' (as shown in screenshot)
- get the GUID from the address bar (see default_db_guid file attached)

Please let us know the result of this. Also provide atlas application logs while accessing missing entity in basic search:
- do a tailf on application logs
- search for default DB
- attach relevant logs to case
```




1. Please backup the earlier atlas-index-repair.groovy file from titan-0.5.4-hadoop2/bin and replace it with the new atlas-index-repair.groovy file I've attached to the case.



