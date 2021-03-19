# Setup pheonix

```sql
echo -n | openssl s_client -connect localhost:8443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/knoxcert.crt

keytool -import -file /tmp/knoxcert.crt -keystore /tmp/knox_truststore.jks -alias knox-Cert -storepass changeit


/usr/hdp/current/phoenix-client/bin/sqlline-thin.py https://<KNOX_HOST>:8443/gateway/default/avatica\;authentication=BASIC\;avatica_user=admin\;avatica_password=admin-password\;truststore=/tmp/test.jks\;truststore_password=hadoop


/usr/hdp/current/phoenix-client/bin/sqlline-thin.py https://c374-node4.squadron.support.hortonworks.com:8443/gateway/default/avatica\;authentication=BASIC\;avatica_user=admin\;avatica_password=admin-password\;truststore=/tmp/knox_truststore.jks\;truststore_password=changeit
```
Use `truststore` and `truststore_password` else you will `https protocol not supportted` error in HDP2.6.x

kerberos env
```
1. Please change value if property "hadoop.proxyuser.HTTP.groups" to *.

Go to Ambari > HDFS > Configs

hadoop.proxyuser.HTTP.groups=*

2. export PHOENIX_OPTS="-Dsun.security.krb5.principal=<your principal>"

3. ./sqlline-thin.py "<hostnmae>:8765:/hbase-secure/hbase;authentication=SPNEGO"


Example:

1.- export PHOENIX_OPTS="-Dsun.security.krb5.principal=HTTP/aquilodran-3.openstacklocal@OPENSTACKLOCAL.COM"

2.-./sqlline-thin.py "aquilodran-3.openstacklocal:8765:/hbase-secure/hbase;authentication=SPNEGO"
```
working
```
./sqlline-thin.py "http://c174-node4.squadron.support.hortonworks.com:8765;authentication=SPNEGO"
```



ex:
```
++++++
[root@c274-node1 keytabs]# kinit -kt hbase.service.keytab hbase/c274-node1.supportlab.cloudera.com
[root@c274-node1 keytabs]# export PHOENIX_OPTS="-Dsun.security.krb5.principal=hbase/c274-node1.supportlab.cloudera.com@SUPPORTLAB.CLOUDERA.COM"
[root@c274-node1 keytabs]# /usr/hdp/current/phoenix-client/bin/sqlline-thin.py https://c274-node1.supportlab.cloudera.com:8443/gateway/default/avatica\;authentication=BASIC\;avatica_user=admin\;avatica_password=admin-password\;truststore=/tmp/knox_truststore.jks\;truststore_password=changeit
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/usr/hdp/3.1.5.0-152/phoenix/phoenix-5.0.0.3.1.5.0-152-thin-client.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/usr/hdp/3.1.5.0-152/hadoop/lib/slf4j-log4j12-1.7.25.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
21/03/16 08:04:04 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Setting property: [incremental, false]
Setting property: [isolation, TRANSACTION_READ_COMMITTED]
issuing: !connect jdbc:phoenix:thin:url=https://c274-node1.supportlab.cloudera.com:8443/gateway/default/avatica;authentication=BASIC;avatica_user=admin;avatica_password=admin-password;truststore=/tmp/knox_truststore.jks;truststore_password=changeit;serialization=PROTOBUF none none org.apache.phoenix.queryserver.client.Driver
Connecting to jdbc:phoenix:thin:url=https://c274-node1.supportlab.cloudera.com:8443/gateway/default/avatica;authentication=BASIC;avatica_user=admin;avatica_password=admin-password;truststore=/tmp/knox_truststore.jks;truststore_password=changeit;serialization=PROTOBUF
Connected to: Apache Phoenix (version unknown version)
Driver: Phoenix Remote JDBC Driver (version unknown version)
Autocommit status: true
Transaction isolation: TRANSACTION_READ_COMMITTED
Building list of tables and columns for tab-completion (set fastconnect to true to skip)...
133/133 (100%) Done
Done
sqlline version 1.2.0

0: jdbc:phoenix:thin:url=https://c274-node1.s> !tables
+------------+--------------+-------------+---------------+----------+------------+----------------------------+-----------------+--------------+-----------------+-+
| TABLE_CAT  | TABLE_SCHEM  | TABLE_NAME  |  TABLE_TYPE   | REMARKS  | TYPE_NAME  | SELF_REFERENCING_COL_NAME  | REF_GENERATION  | INDEX_STATE  | IMMUTABLE_ROWS  | |
+------------+--------------+-------------+---------------+----------+------------+----------------------------+-----------------+--------------+-----------------+-+
|            | SYSTEM       | CATALOG     | SYSTEM TABLE  |          |            |                            |                 |              | false           | |
|            | SYSTEM       | FUNCTION    | SYSTEM TABLE  |          |            |                            |                 |              | false           | |
|            | SYSTEM       | LOG         | SYSTEM TABLE  |          |            |                            |                 |              | true            | |
|            | SYSTEM       | SEQUENCE    | SYSTEM TABLE  |          |            |                            |                 |              | false           | |
|            | SYSTEM       | STATS       | SYSTEM TABLE  |          |            |                            |                 |              | false           | |
+------------+--------------+-------------+---------------+----------+------------+----------------------------+-----------------+--------------+-----------------+-+
0: jdbc:phoenix:thin:url=https://c274-node1.s>
++++++++++

```

### Troubleshooting:

```
hbase configs  as the table access was going through knox user and not the doas user

 phoenix.queryserver.withRemoteUserExtractor = true
 
  'hadoop.proxyuser.knox.hosts and hadoop.proxyuser.knox.groups should be set to "*" in core-site.xml of HDFS service.  (this requires restart all Hadoop services if set)

And PQS config phoenix.queryserver.withRemoteUserExtractor=true 



++++++
keytool -import -keystore /tmp/knox-keystore.jks -alias knox -file /tmp/knoxcert -storepass changeit

keytool -printcert -sslserver <knox-server>:8443 -rfc

gateway.httpclient.socketTimeout= 60000
gateway.httpclient.connectionTimeout=60000

++++++++
To test the impersonation via PQS, please follow below steps: 
- On Knox host : 

# kinit -kt knox.service.keytab knox/`hostname -f`
# export PHOENIX_OPTS='-Dsun.security.krb5.principal=knox/<FQDN>@<realm>'
# /usr/hdp/current/phoenix-client/bin/sqlline-thin.py "http://<PQS-FQDN>:8765/?doAs=<userName>;authentication=SPNEGO;serialization=PROTOBUF"

+++++++++
Due to phoenix jira https://issues.apache.org/jira/browse/PHOENIX-5761 not fixed in 3.1.5 you need to do kinit and set PHOENIX_OPTS eve though authentication is set to BASIC. However this should not be the case if connected from external service via ODBC or JDBC. 


```
