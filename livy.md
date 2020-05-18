
In kerberos env, SPNEGO is enabled in Livy UI. 
they need have kerberos ticket on local machine and Firefox browser needs to be configured accordingly to access SPNEGO enabled UI.

If their local machine is on same domain only Firefox browser needs to be configured.
If their local machine is on different domain but one way trust is configured only Firefox browser needs to be configured. else they can configure one way trust or
Install MIT kerberos client and configure it 
REF: https://community.hortonworks.com/articles/28537/user-authentication-from-windows-workstation-to-hd.html

--------------------------------------------
```
kinit -kt /etc/security/keytabs/livy.service.keytab $(klist -kt /etc/security/keytabs/livy.service.keytab |sed -n "4p"|cut -d ' ' -f7)
Share me output of below cmd:

# klist -f
```

Confirm if below spark submit cmd works:

```
/usr/hdp/current/spark2-client/bin/spark-submit --master yarn-cluster --executor-memory 1G --class org.apache.spark.examples.SparkPi /usr/hdp/current/spark2-client/examples/jars/spark-examples*.jar 1	
```

Livy:
=====
 Note: the POST request does not upload local jars to the cluster. You should upload required jar files to HDFS before running the job. 
```
# hdfs dfs -copyFromLocal /usr/hdp/current/spark2-client/examples/jars/spark-examples*.jar /tmp
# hdfs dfs -ls /tmp/spark-examples*.jar
```
```
vi /tmp/livy.json

{ "className": "org.apache.spark.examples.SparkPi",
        "executorMemory": "1g",
        "args": [2000],
        "file": "/tmp/spark-examples_2.11-2.3.0.2.6.5.0-292.jar"
       }

curl -ik --negotiate -u : -H "Content-Type: application/json" -H 'X-Requested-By: livy' -X POST -d @/tmp/livy.json "http://c374-node3.squadron.support.hortonworks.com:8999/batches"
```

check the status in UI or livy-livy-server.out file
