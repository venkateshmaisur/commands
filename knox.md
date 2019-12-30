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
nohup hbase rest start -p 8080 & 2>&1 

-->Once set , you can now configure knox topology to have webhbase as below: 
<service> 
<role>WEBHBASE</role> 
<url>http://{{hbase_master_host}}:8080</url> 
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
