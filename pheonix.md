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
