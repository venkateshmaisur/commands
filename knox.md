# Knox troubleshooting

```bash
echo -n | openssl s_client -connect ${knoxserver}:8443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/knoxcert.crt
watch -n 1 'netstat -anp | grep `cat /var/run/knox/gateway.pid` | grep ESTABLISHED | wc -l' 
{GATEWAY_HOME}/bin/knoxcli.sh create-alias ldcSystemPassword --cluster hdp --value hadoop

mv /usr/hdp/current/knox-server/data/deployments/ /usr/hdp/current/knox-server/data/deployments_backup

env GZIP=-9 tar czhvf ./knox_all_conf_$(hostname)_$(date +"%Y%m%d%H%M%S").tgz /usr/hdp/current/knox-server/conf/ /etc/ranger/*/policycache /usr/hdp/current/knox-server/data/deployments/ /var/log/knox/gateway.log /var/log/knox/gateway-audit.log 2>/dev/null
keytool -import -file /tmp/adcert.crt -keystore $JAVA_HOME/jre/lib/security/cacerts -alias AD-Cert -storepass changeit
curl -ik -u Username:Password -X GET  'https://<KNOX-HOSTNAME>:8443/gateway/default/webhdfs/v1/?op=LISTSTATUS'
```

##### Connect to hive using Knox.
```bash
echo -n | openssl s_client -connect ${knoxserver}:8443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/knoxcert.crt
keytool -import -file /tmp/knoxcert.crt -keystore /tmp/knox.jks -alias knox-Cert -storepass changeit

beeline -u "jdbc:hive2://KnoxserverInternalHostName:8443/;ssl=true;sslTrustStore=/tmp/knox.jks;trustStorePassword=changeit;transportMode=http;httpPath=gateway/default/hive" -n <username> -p <password>

```

```
Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true

KNOX:
/usr/hdp/current/knox-server/bin/gateway.sh

Modify the gateway.sh and added -Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true on both the host.
====
#dynamic library path
APP_JAVA_LIB_PATH="-Djava.library.path=$APP_HOME_DIR/ext/native -Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true"

Restart Knox and test again.

```

##### Debug on Ranger Knox Plugin

Modify the gateway-log4j.properties like below, restart Knox and review the ranger Knox plugin log in ranger.knoxagent.log
```sh
#Ranger Knox Plugin debug
ranger.knoxagent.logger=DEBUG,console,KNOXAGENT
ranger.knoxagent.log.file=ranger.knoxagent.log
log4j.logger.org.apache.ranger=${ranger.knoxagent.logger}
log4j.additivity.org.apache.ranger=false
log4j.appender.KNOXAGENT =org.apache.log4j.DailyRollingFileAppender
log4j.appender.KNOXAGENT.File=${app.log.dir}/${ranger.knoxagent.log.file}
log4j.appender.KNOXAGENT.layout=org.apache.log4j.PatternLayout
log4j.appender.KNOXAGENT.layout.ConversionPattern=%d{ISO8601} %p %c{2}: %m%n %L
log4j.appender.KNOXAGENT.DatePattern=.yyyy-MM-dd
```

### KNOX Hbase rest

```bash
	For hbase, you must start the hbase rest service and configure your topology with the webhbase service url set to the <host>:<port> 
-->On hbase master: 
You would need to add properties hbase.rest.keytab.file & hbase.rest.kerberos.principal like below in hbase-site prior to startin rest service. 
hbase.rest.kerberos.principal=HTTP/_HOST@LAB.HORTONWORKS.NET
hbase.rest.keytab.file=/etc/security/keytabs/spnego.service.keytab 

#su - hbase 
nohup hbase rest start -p 60080 & 2>&1 

-->Once set , you can now configure knox topology to have webhbase as below: 
            <service>
                <role>WEBHBASE</role>
                <url>http://{{hbase_master_host}}:{{hbase_master_port}}</url>
            </service>


Ref: https://knox.apache.org/books/knox-1-3-0/user-guide.html#HBase+URL+Mapping

After this change you should be able to use the knox to query over webhdfs rest API. 

#curl -ikv -u admin:admin-password https://c374-node4.squadron.support.hortonworks.com:8443/gateway/default/hbase/status/cluster 

https://knox.apache.org/books/knox-0-12-0/user-guide.html#HBase+REST+API+Setup
```

##### Use LB for KnoxSSO where you have multiple knox instances

```sh 
-->Create a new keystore: 

#keytool -genkey -keystore knoxSSO.jks -alias knoxsso -keyalg rsa -keysize 2048 

(First name and Lastname is set as KnoxSSO, or it can be anything) 

-->Create passphrase alias, here the passphrase alias prompts for the password, which is same password set for knoxSSO.jks in step1 

# /usr/hdp/current/knox-server/bin/knoxcli.sh create-alias signing.key.passphrase --cluster knoxsso 

-->Extract the public key from the knox SSO.jks which is in the DER format, 
# /usr/jdk64/jdk1.8.0_112/bin/keytool -export -file /tmp/sign.crt -alias knoxsso -keystore knoxSSO.jks 

-->Convert the DER to PEM format which can be used configure ambari server jwt-cert.pem 

# openssl x509 -in /tmp/sign.crt -inform DER -outform PEM 

(copy the content and in the file /etc/ambari-server/conf/jwt-cert.pem) 

-->Copy the knoxSSO.jks to keystore path of knox 

#cp /var/tmp/knoxSSO.jks /usr/hdp/current/knox-server/data/security/keystores/ 

-->Copy the knoxSSO.jks to the second knox instance: 
#scp knoxSSO.jks <knox2>:/usr/hdp/current/knox-server/data/security/keystores/ 

-->On Knox 2 host create the passphrase alias(step was done on knox 1 already): 
# /usr/hdp/current/knox-server/bin/knoxcli.sh create-alias signing.key.passphrase --cluster knoxsso 

Configure gateway-site with below two properties: 

Ambari>Knox>Configs>Custom gateway-site>Add 

gateway.signing.keystore.name=knoxSSO.jks 
gateway.signing.key.alias=knoxsso
```

## Performance:
```
configuring appropriate timeouts in gateway-site.xml, in Ambari Knox -> config -> Custom gateway-site, add the following

gateway.httpclient.connectionTimeout=600000
gateway.httpclient.socketTimeout=600000
gateway.httpclient.maxConnections=128
```

### knoxsso troubleshooting
```
### Non-working sso

2020-02-25 14:33:34,725 INFO  server.JWTRedirectAuthenticationHandler (JWTRedirectAuthenticationHandler.java:alternateAuthenticate(170)) - USERNAME: admin
2020-02-25 14:33:34,901 WARN  server.AuthenticationFilter (AuthenticationFilter.java:doFilter(525)) - AuthenticationToken ignored: org.apache.hadoop.security.authentication.util.  : Invalid signature
2020-02-25 14:33:34,902 INFO  server.JWTRedirectAuthenticationHandler (JWTRedirectAuthenticationHandler.java:getJWTFromCookie(203)) - hadoop-jwt cookie has been found and is being processed



###  working sso

2020-02-25 14:34:45,845 INFO  provider.BaseAuditHandler (BaseAuditHandler.java:logStatus(312)) - Audit Status Log: name=yarn.async.multi_dest.batch, finalDestination=yarn.async.multi_dest.batch.hdfs, interval=01:00.001 minutes, events=28783, succcessCount=338, totalEvents=188211, totalSuccessCount=2199
2020-02-25 14:34:47,407 INFO  server.JWTRedirectAuthenticationHandler (JWTRedirectAuthenticationHandler.java:alternateAuthenticate(159)) - sending redirect to: https://c174-node3.squadron.support.hortonworks.com:8443/gateway/knoxsso/api/v1/websso?originalUrl=http://c174-node3.squadron.support.hortonworks.com:8088/cluster
2020-02-25 14:34:48,842 INFO  provider.BaseAuditHandler (BaseAuditHandler.java:logStatus(312)) - Audit Status Log: name=yarn.async.multi_dest.batch, finalDestination=yarn.async.multi_dest.batch.solr, interval=01:00.001 minutes, events=28139, succcessCount=338, totalEvents=184725, totalSuccessCount=2199



### knox logs yarn knoxsso

20/02/25 14:35:52 ||4e257a73-13e1-437d-b88c-996ac3ea320d|audit|10.42.80.70|KNOXSSO||||access|uri|/gateway/knoxsso/api/v1/websso?originalUrl=http://c174-node3.squadron.support.hortonworks.com:8088/ui2/|unavailable|Request method: GET
20/02/25 14:35:52 |||audit|10.42.80.70|KNOXSSO||||access|uri|/gateway/knoxsso/api/v1/websso?originalUrl=http://c174-node3.squadron.support.hortonworks.com:8088/ui2/|success|Response status: 401
20/02/25 14:35:52 ||c819c7cf-f945-4e34-81a3-93c400dbd6cd|audit|10.42.80.70|knoxauth||||access|uri|/gateway/knoxsso/knoxauth/login.html?originalUrl=http://c174-node3.squadron.support.hortonworks.com:8088/ui2/|unavailable|Request method: GET
20/02/25 14:35:52 ||c819c7cf-f945-4e34-81a3-93c400dbd6cd|audit|10.42.80.70|knoxauth|anonymous|||authentication|uri|/gateway/knoxsso/knoxauth/login.html?originalUrl=http://c174-node3.squadron.support.hortonworks.com:8088/ui2/|success|
20/02/25 14:35:52 |||audit|10.42.80.70|knoxauth|anonymous|||access|uri|/gateway/knoxsso/knoxauth/login.html?originalUrl=http://c174-node3.squadron.support.hortonworks.com:8088/ui2/|success|Response status: 200
```
