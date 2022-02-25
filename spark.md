# Spark HWC integration - HDP 3.X Secure cluster

### Prerequisites : 

* Kerberized Cluster
* Enable hive interactive server in hive
* Get following details from hive for spark

Ref: https://docs.cloudera.com/HDPDocuments/HDP3/HDP-3.1.0/integrating-hive/content/hive_configure_a_spark_hive_connection.html

##### In latest HDP/Ambari all below values are already popululdated in Spark2 configs:

```
spark.hadoop.hive.llap.daemon.service.hosts @llap0
spark.sql.hive.hiveserver2.jdbc.url  jdbc:hive2://c174-node2.squadron.support.hortonworks.com:2181,c174-node3.squadron.support.hortonworks.com:2181,c174-node4.squadron.support.hortonworks.com:2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2-interactive
spark.datasource.hive.warehouse.metastoreUri thrift://c174-node3.squadron.support.hortonworks.com:9083
```

```bash
spark.sql.hive.hiveserver2.jdbc.url
 grep -a2 beeline.hs2.jdbc.url.llap  /etc/hive/conf/beeline-site.xml

spark.datasource.hive.warehouse.metastoreUri
 grep -a1  hive.metastore.uris  /etc/hive/conf/hive-site.xml

spark.hadoop.hive.llap.daemon.service.hosts
# Copy value from Advanced hive-interactive-site > hive.llap.daemon.service.hosts

spark.hadoop.hive.zookeeper.quorum
 grep -a1  hive.zookeeper.quorum  /etc/hive/conf/hive-site.xml
```

## 1. Basic testing :
eg: 
```sh
echo '1201,Vinod,45000,Technical manager
1202,Manisha,45000,Proof reader
1203,Masthanvali,40000,Technical writer
1204,Kiran,40000,Hr Admin
1205,Kranthi,30000,Op Admin' > /tmp/data.txt
hdfs dfs -put /tmp/data.txt /tmp
```

## Login into Hive 

```sql
CREATE TABLE IF NOT EXISTS employee ( eid int, name String, salary String, destination String)
COMMENT 'Employee details'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
LOAD DATA INPATH '/tmp/data.txt' OVERWRITE INTO TABLE employee;
```

## 2) kinit to the spark user and run 

```java
spark-shell --master yarn --conf "spark.security.credentials.hiveserver2.enabled=false" --conf "spark.sql.hive.hiveserver2.jdbc.url=jdbc:hive2://c174-node2.squadron.support.hortonworks.com:2181,c174-node3.squadron.support.hortonworks.com:2181,c174-node4.squadron.support.hortonworks.com:2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2-interactive" --conf "spark.datasource.hive.warehouse.metastoreUri=thrift://c174-node3.squadron.support.hortonworks.com:9083" --conf "spark.datasource.hive.warehouse.load.staging.dir=/tmp/" --conf "spark.hadoop.hive.llap.daemon.service.hosts=@llap0" --conf "spark.hadoop.hive.zookeeper.quorum=c174-node2.squadron.support.hortonworks.com:2181,c174-node3.squadron.support.hortonworks.com:2181,c174-node4.squadron.support.hortonworks.com:2181" --jars /usr/hdp/current/hive_warehouse_connector/hive-warehouse-connector-assembly-1.0.0.3.1.4.0-315.jar
```

##### Note: spark.security.credentials.hiveserver2.enabled should be set to false for YARN client deploy mode, and true for YARN cluster deploy mode (by default). This configuration is required for a Kerberized cluster

## 3) run following code in scala shell to view the table data
```java
import com.hortonworks.hwc.HiveWarehouseSession
val hive = HiveWarehouseSession.session(spark).build()
hive.execute("show tables").show
hive.executeQuery("select * from employee").show
```

## 4) To apply common properties by default, add following setting into ambari spark2 custom conf

```java
spark.hadoop.hive.llap.daemon.service.hosts @llap0
spark.sql.hive.hiveserver2.jdbc.url  jdbc:hive2://c174-node2.squadron.support.hortonworks.com:2181,c174-node3.squadron.support.hortonworks.com:2181,c174-node4.squadron.support.hortonworks.com:2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2-interactive
spark.datasource.hive.warehouse.metastoreUri thrift://c174-node3.squadron.support.hortonworks.com:9083
spark.hadoop.hive.zookeeper.quorum=c174-node2.squadron.support.hortonworks.com:2181,c174-node3.squadron.support.hortonworks.com:2181,c174-node4.squadron.support.hortonworks.com:2181
spark.datasource.hive.warehouse.load.staging.dir=/tmp/
```

## 5) 
```java
spark-shell --master yarn  --conf "spark.security.credentials.hiveserver2.enabled=false" --jars  /usr/hdp/current/hive_warehouse_connector/hive-warehouse-connector-assembly-1.0.0.3.1.4.0-315.jar
```
##### Note: Common properties are read from spark default properties

### Pyspark example :
```java
pyspark --master yarn --jars /usr/hdp/current/hive_warehouse_connector/hive-warehouse-connector-assembly-1.0.0.3.1.4.0-315.jar  --py-files  /usr/hdp/current/hive_warehouse_connector/pyspark_hwc-1.0.0.3.1.4.0-315.zip --conf spark.security.credentials.hiveserver2.enabled=false

from pyspark_llap.sql.session import HiveWarehouseSession
hive = HiveWarehouseSession.session(spark).build()
```

![pyspark cmdline](https://github.com/bhagadepravin/commands/blob/master/jpeg/pyspark%20cmdline.png)

## 6) run following code in scala shell to view the hive table data
```java
import com.hortonworks.hwc.HiveWarehouseSession
val hive = HiveWarehouseSession.session(spark).build()
hive.execute("show tables").show
hive.executeQuery("select * from employee").show
```

# 7) Integrate HWC in Livy2 Interpreter in Zeppelin

Ref: https://community.cloudera.com/t5/Community-Articles/How-to-configure-zeppelin-livy-interpreter-for-secure-HDP/ta-p/249267

Ref: https://zeppelin.apache.org/docs/0.6.1/interpreter/livy.html

```java
  a) add following property in Custom livy2-conf
        livy.file.local-dir-whitelist=/usr/hdp/current/hive_warehouse_connector/
  b) Add hive-site.xml to /usr/hdp/current/spark2-client/conf on all cluster nodes.
  
  c)Ensure  hadoop.proxyuser.hive.hosts=*  exists in core-site.xml ; refer Custom core-site section in HDFS confs
  
  d) Login to Zeppelin and in livy2 interpreter  settings add following 
     livy.spark.hadoop.hive.llap.daemon.service.hosts=@llap0
     livy.spark.security.credentials.hiveserver2.enabled=true
     livy.spark.sql.hive.hiveserver2.jdbc.url=jdbc:hive2://c174-node2.squadron.support.hortonworks.com:2181,c174-   node3.squadron.support.hortonworks.com:2181,c174-node4.squadron.support.hortonworks.com:2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2-interactive
     livy.spark.sql.hive.hiveserver2.jdbc.url.principal=hive/_HOST@HWX.COM
     livy.spark.yarn.security.credentials.hiveserver2.enabled=true
     livy.spark.jars=file:///usr/hdp/current/hive_warehouse_connector/hive-warehouse-connector-assembly-1.0.0.3.1.4.0-315.jar
```

![Livy Interpreter Setting](https://github.com/bhagadepravin/commands/blob/master/jpeg/Livy%20Interpreter%20Setting.png)


```
 Note: Ensure to change the version of hive-warehouse-connector-assembly to match your HWC version

  d) Restart livy2 interpreter 
  
  e) in first paragraph add 
     %livy2
     import com.hortonworks.hwc.HiveWarehouseSession
     val hive = HiveWarehouseSession.session(spark).build()

  f) in second paragraph add
     %livy2
     hive.executeQuery("select * from employee").show
```


##### Note: There is an Ambari defect: AMBARI-22801, which reset the proxy configs on  keytab regenration/service addition. Please follow the step  7.c again in such scenarios

![Livy zepplein example](https://github.com/bhagadepravin/commands/blob/master/jpeg/Livy%20zepplein%20example.png)


![livy.pyspark](https://github.com/bhagadepravin/commands/blob/master/jpeg/livy.pyspark.png)

# Known Error's

1. 
```
scala> hive.execute("show tables").show
java.lang.RuntimeException: java.sql.SQLException: Cannot create PoolableConnectionFactory (Bad URL format: Multiple values for property principal)
  at com.hortonworks.spark.sql.hive.llap.HiveWarehouseSessionImpl.executeInternal(HiveWarehouseSessionImpl.java:200)
  at com.hortonworks.spark.sql.hive.llap.HiveWarehouseSessionImpl.executeSmart(HiveWarehouseSessionImpl.java:189)
  at com.hortonworks.spark.sql.hive.llap.HiveWarehouseSessionImpl.execute(HiveWarehouseSessionImpl.java:182)
  ... 49 elided
```
##### Solution: 
Check spark.sql.hive.hiveserver2.jdbc.url if you have added any principal. After removing principal issue

2. 
```
No module named pyspark_llap.sql.session
Traceback (most recent call last):
ImportError: No module named pyspark_llap.sql.session
```
##### Solution:

For Python usage, the configuration below should also be added. For instance:
In zepplein use livy.spark.submit.pyFiles  (capital F)
```java
Goto Zepplein UI -> Interpreter Setting -> Livy Interpreter -> Add below

livy.spark.submit.pyFiles=file////usr/hdp/current/hive_warehouse_connector/pyspark_hwc-1.0.0.3.1.4.0-315.zip


=> Rerun the notebbok
%livy.pyspark
from pyspark_llap.sql.session import HiveWarehouseSession
hive = HiveWarehouseSession.session(spark).build()
hive.setDatabase("default")
hive.table("employee").filter("salary = 45000 OR salary = 30000").show()

%livy.pyspark
hive.setDatabase("hwc_db")
hive.table("crimes").filter("year = 2000 OR year = 2010").show()
```

3. 
```java
%livy
from pyspark_llap.sql.session import HiveWarehouseSession
hive = HiveWarehouseSession.session(spark).build()
<console>:1: error: ';' expected but '.' found.
from pyspark_llap.sql.session import HiveWarehouseSession
```
##### solution:
make sure you use `%livy.pyspark1



### SPARK + ATLAS + Lineage
```
spark-shell
spark.sql("create external table blah1 ( name string ) location 'hdfs:///tmp/blah1'")

spark.sql("create table blah2 AS SELECT * FROM blah1 ")

## for managed table we need to HwC
```
