Make sure Ambari Infra , Hbase and kafka are up and running. 
`kinit -kt /etc/security/keytabs/atlas.service.keytab $(klist -kt /etc/security/keytabs/atlas.service.keytab |sed -n "4p"|cut -d ' ' -f7)`

`rep -i java_home /etc/hadoop/conf/hadoop-env.sh`

+++++
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

```bash
/bin/bash /usr/hdp/current/atlas-server/hook-bin/import-hive.sh -Dsun.security.jgss.debug=true -Djavax.security.auth.useSubjectCredsOnly=false -Djava.security.auth.login.config=/etc/atlas/conf/atlas_jaas.conf
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

---------------------------------------------------------------------------------------------------------------------------

Below are the links which might be helpful to you for getting started with atlas. 

1. https://community.hortonworks.com/articles/81680/atlas-tag-based-searches-utilizing-the-atlas-rest.html 
2. https://community.hortonworks.com/articles/39759/list-atlas-tags-and-traits.html 
3. https://community.hortonworks.com/articles/58220/howto-install-and-configure-high-availability-on-a.html 
4. https://community.hortonworks.com/articles/61274/import-hive-metadata-into-atlas.html 
5. https://hortonworks.com/hadoop-tutorial/cross-component-lineage-apache-atlas/ 
6. https://hortonworks.com/tutorial/tag-based-policies-with-apache-ranger-and-apache-atlas/ 
