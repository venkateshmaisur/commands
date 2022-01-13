

```sql
[root@pbhagade-3 88-impala-STATESTORE]# kinit -kt impala.keytab impala/pbhagade-3.pbhagade.root.hwx.site
[root@pbhagade-3 88-impala-STATESTORE]#
[root@pbhagade-3 88-impala-STATESTORE]# cd
[root@pbhagade-3 ~]# spark-shell --jars kudu-spark2_2.11-1.15.0.7.1.7.67-1.jar
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
22/01/13 13:32:29 WARN conf.HiveConf: HiveConf of name hive.masking.algo does not exist
22/01/13 13:32:39 WARN cluster.YarnSchedulerBackend$YarnSchedulerEndpoint: Attempted to request executors before the AM has registered!
Spark context Web UI available at http://pbhagade-3.pbhagade.root.hwx.site:4040
Spark context available as 'sc' (master = yarn, app id = application_1641981266097_0011).
Spark session available as 'spark'.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.4.7.7.1.7.0-551
      /_/

Using Scala version 2.11.12 (OpenJDK 64-Bit Server VM, Java 1.8.0_232)
Type in expressions to have them evaluated.
Type :help for more information.

scala>

scala> import org.apache.kudu.spark.kudu._
import org.apache.kudu.spark.kudu._

scala> val df = spark.read.options(Map("kudu.master" -> "pbhagade-1.pbhagade.root.hwx.site", "kudu.table" -> "default.n1")).format("kudu").load
df: org.apache.spark.sql.DataFrame = [id: bigint, name: string]

scala> val df = spark.read.options(Map("kudu.master" -> "pbhagade-1.pbhagade.root.hwx.site:7051",
     |                                 "kudu.table" -> "default.my_first_table")).format("kudu").load
df: org.apache.spark.sql.DataFrame = [id: bigint, name: string]

scala> df.createOrReplaceTempView("my_first_table")

scala> spark.sql("select * from my_first_table").show()
22/01/13 13:34:15 WARN conf.HiveConf: HiveConf of name hive.masking.algo does not exist
Hive Session ID = a836815d-1831-446a-8c75-7859dae692c6
[Stage 0:>                                                          (0 + 0) / 1]22/01/13 13:34:34 WARN cluster.YarnScheduler: Initial job has not accepted any resources; check your cluster UI to ensure that workers are registered and have sufficient resources
22/01/13 13:34:49 WARN cluster.YarnScheduler: Initial job has not accepted any resources; check your cluster UI to ensure that workers are registered and have sufficient resources
| id|name|
+---+----+
|  2|jane|
|  3| bob|
|  1|john|
+---+----+


scala> spark.sql("select * from my_first_table").show()
+---+----+
| id|name|
+---+----+
|  2|jane|
|  3| bob|
|  1|john|
+---+----+


scala>
```
