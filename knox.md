# Knox troubleshooting


#### cdp-dc
```
export KNOX_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*KNOX_GATEWAY | tail -1)
env GZIP=-9  tar -cvzf knox.tar.gz /var/lib/knox/gateway/conf /var/lib/knox/gateway/data/deployments/cdp-proxy-api* $KNOX_PROCESS_DIR /var/log/knox/gateway/gateway.log /var/log/knox/gateway/gateway-audit.log
```
```
Please reproduce the issue and execute below commands and attach the knox.tar.gz to the case.


export KNOX_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*KNOX_GATEWAY | tail -1)
export KNOX_GATEWAY_SaveAliasCommand=$(ls -1dtr /var/run/cloudera-scm-agent/process/*KNOX_GATEWAY-SaveAliasCommand | tail -1)
env GZIP=-9  tar -cvzf knox.tar.gz /var/lib/knox/gateway/conf $KNOX_GATEWAY_SaveAliasCommand  $KNOX_PROCESS_DIR /var/log/knox/gateway/gateway.log /var/log/knox/gateway/knoxcli.log /var/log/knox/gateway/gateway-audit.log /var/lib/knox/gateway/data/security/keystores
```

##### knox ldap
```bash
role=authentication
authentication.name=ShiroProvider
authentication.param.sessionTimeout=30
authentication.param.redirectToUrl=/${GATEWAY_PATH}/knoxsso/knoxauth/login.html
authentication.param.restrictedCookies=rememberme,WWW-Authenticate
authentication.param.urls./**=authcBasic
authentication.param.main.ldapRealm=org.apache.knox.gateway.shirorealm.KnoxLdapRealm
authentication.param.main.ldapContextFactory=org.apache.knox.gateway.shirorealm.KnoxLdapContextFactory
authentication.param.main.ldapRealm.contextFactory=$ldapContextFactory
authentication.param.main.ldapRealm.contextFactory.authenticationMechanism=simple
authentication.param.main.ldapRealm.contextFactory.url=ldap://10.113.243.16:389
authentication.param.main.ldapRealm.searchBase=DC=SUPPORT,DC=COM
authentication.param.main.ldapRealm.contextFactory.systemUsername=test1@SUPPORT.COM
authentication.param.main.ldapRealm.contextFactory.systemPassword=hadoop12345!
authentication.param.main.ldapRealm.userObjectClass=person
authentication.param.main.ldapRealm.userSearchAttributeName=sAMAccountName
authentication.param.main.ldapRealm.userSearchFilter=(&amp;(sAMAccountName={0})(memberOf=CN=support,OU=groups,OU=hortonworks,DC=SUPPORT,DC=COM))
authentication.param.remove=main.pamRealm
authentication.param.remove=main.pamRealm.service
```

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

#####

```
<service> 
<role>HIVE</role> 
<url>http://{{hive_server_host}}:{{hive_http_port}}/{{hive_http_path}}</url> 
<param><name>replayBufferSize</name><value>32</value></param> 
<param> 
<name>httpclient.connectionTimeout</name> 
<value>30m</value> 
</param> 
<param> 
<name>httpclient.socketTimeout</name> 
<value>30m</value> 
</param>
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

##### Knox + yarn ui HDP 3.x
Please follow the below procedure to access the yarn logs for a running application.
```bash

We need to use the latest rules from below:
https://github.com/apache/knox/tree/master/gateway-service-definitions/src/main/resources/services/yarnui/2.7.0

Please follow below procedure.

1. Login into Knox host:

cd /usr/hdp/current/knox-server/data/services/yarnui/2.7.0/
mv rewrite.xml rewrite.xml.bk
mv service.xml service.xml.bk

2. Use below link to download if you have public access if you dont have access, copy and paste to create a new file under '/usr/hdp/current/knox-server/data/services/yarnui/2.7.0/'

wget https://raw.githubusercontent.com/apache/knox/master/gateway-service-definitions/src/main/resources/services/yarnui/2.7.0/rewrite.xml
wget https://raw.githubusercontent.com/apache/knox/master/gateway-service-definitions/src/main/resources/services/yarnui/2.7.0/service.xml

# chown knox:hadoop /usr/hdp/current/knox-server/data/services/yarnui/2.7.0/*
# mv /usr/hdp/current/knox-server/data/deployments /var/lib/knox/data-3.1.0.0-78/deployments.bk

3. Restart Knox service

4. touch those xml files.

touch /usr/hdp/current/knox-server/data/services/yarnui/2.7.0/rewrite.xml
touch /usr/hdp/current/knox-server/data/services/yarnui/2.7.0/service.xml

5. Access the Knox yarn v1 UI. access the logs of running applications.

=============================================================================================================
```

###### For Spark UI + knox
```
To access the logs using Knox URL you need to add 'knox' user to 'spark.history.ui.admin.acls'

Please add below and restart the service let me know if that helps.

# spark.history.ui.admin.acls=knox
```


###### [Spark History UI Service] Executor logs (stdout/stderr) links are broken]
https://jira.cloudera.com/browse/EAR-10781


###### hdp Knox sso troubleshooting:

```

select * from ambari_configuration;

grep -a2  main.ldapRealm  /etc/knox/conf/topologies/knoxsso.xml

#make sure it has same ldap/ad details:

Open two terminals

tailf /var/log/ambari-server/ambari-server.log | tee /tmp/new-ambari-server.log
tail -f /var/log/knox/gateway.log /var/log/knox/gateway-audit.log | tee /tmp/knox.log

take a downtime for Knox restart:
login into knox node:
mv /usr/hdp/current/knox-server/data/deployments/ /usr/hdp/current/knox-server/data/deployments_backup

Disable Knox debug:

Restart Knox service

Open a browser, clear all cache and cookies from the browser.

Access Ambari url, Make sure you have run tailf cmd on both ambari and knox : If you still facing the issue:
attach below files:

env GZIP=-9 tar czhvf ./knox_all_conf_$(hostname)_$(date +"%Y%m%d%H%M%S").tgz /usr/hdp/current/knox-server/conf/ /usr/hdp/current/knox-server/data/services/ambari* /usr/hdp/current/knox-server/data/deployments/ /var/log/knox/gateway.log /var/log/knox/gateway-audit.log 2>/dev/null

/tmp/new-ambari-server.log
/tmp/knox.log

attach tar file form above cmd as well


Ambari success logging:

2021-03-10 07:59:13,807  INFO [ambari-client-thread-216] AmbariJwtAuthenticationFilter:265 - hadoop-jwt cookie has been found and is being processed
2021-03-10 07:59:14,338  INFO [ambari-client-thread-216] AmbariJwtAuthenticationFilter:265 - hadoop-jwt cookie has been found and is being processed



```

```
   May i know what is the default heap memory for Knox ?
>> Knox by default doesnt have a default heap settings, process will start requesting memory for OS based on the need(which is unreserved for knox). If OS cannot allocate memory knox will not be able to get heap and will fail with heap issue if such condition arises. 


        Also, please let me know if this the fix for "InvalidOperation Handle " or "Invalid Session handle" ?
>> InvalidOperation and InvalidSession are caused because of the failover by knox to different HS2 , which we see is caused after 15mins timeout on  queries executed by user.  Based on the logs, java heap issue and timeout issue on HS2s occurred at same time.

Addressing knox heap issue can help but without monitoring we cannot confirm, as this could have caused by queries submitted by user, which is taking more than 15mins of compile time. 


Heap config is calculated based on number of simultaneous users and if that is not possible to find, a good start would be to set knox heap size to 4GB.
```




```
 HS2 logs check for
 
grep 'Completed compiling' hiveserver2.log*  | awk -F' ' '{print $(NF-1)}' | sort -nr | head -10

that should give query time

and

 grep 409.116 hiveserver2.log* | grep completed -i
hiveserver2.log.2021-07-19_1:2021-07-19T00:36:58,215 INFO  [35bf3600-a114-4379-87ce-5491b3a93d80 HiveServer2-HttpHandler-Pool: Thread-2792874]: ql.Driver (:()) - Completed compiling command(queryId=hive_20210719003009_c5f1f15c-cf14-46cb-9e74-bfd645406dfc); Time taken: 409.116 seconds


to find the queryId
```


#### knox oom troubleshooting
```
Please set below paratmeter in Knox gateway.sh to generate heapdump when there is OOM.

1.  ADD below parameter for HeapDumpPath

-XX:+PrintClassHistogramBeforeFullGC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/

2. When Issue reoccurs again, Please collect below details, before restarting Knox service.

Make sure you update the correct JAVA/_HOME/Path

Login into Knox node:

ps aux | grep knox
export JAVA_HOME=JAVA_path

Ex: export JAVA_HOME=/usr/jdk64/jdk1.8.0_112



for i in {1..3}; do sudo -iu knox $JAVA_HOME/bin/jstack -l $(cat /var/run/knox/gateway.pid); sleep 5; done >> /tmp/jstack.out
/usr/jdk64/jdk1.8.0_112/bin/jmap -heap $(cat /var/run/knox/gateway.pid) > /tmp/jmapheap
/usr/jdk64/jdk1.8.0_112/bin/jmap -histo:live `cat /var/run/knox/gateway.pid` > /tmp/jmaplive
( date;set -x;hostname -A;uname -a;top -b -n 4 -c -H -p $(cat /var/run/knox/gateway.pid);ps auxwwwf;netstat -aopen  |grep $(cat /var/run/knox/gateway.pid);ifconfig ) &>  /tmp/knox_os_cmds.out ; tar czhvf ./knox_$(hostname)_$(date +"%Y%m%d%H%M%S").tgz /tmp/jmapheap  /tmp/jstack.out /tmp/jmapheap /tmp/jmaplive /tmp/java*.hprof /usr/hdp/current/knox-server/conf/ /var/log/knox/gateway.log /var/log/knox/gateway-audit.log 2>/dev/null

attach the tar file

```

##### heapdump
```
/usr/java/jdk1.8.0_232-cloudera/bin/jmap -dump:format=b,file=/tmp/heapdump.bin 32467

/usr/java/jdk1.8.0_232-cloudera/bin/jmap -dump:live,format=b,file=/tmp/dump.hprof 32467
```




##### Enable cdp Knox Gc logging

```
CM UI -> Knox -> Configuration -> Knox Service Environment Advanced Configuration Snippet (Safety Valve)
Add
Key   --> KNOX_GATEWAY_MEM_OPTS

value --> -verbose:gc -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -Xloggc:/var/log/knox/gateway/knox-gc.log -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps


* jstack
switch to root user
su -s /bin/bash knox

# get the java path and knox pid

ps -ef | grep gateway.jar
pid => ps -ef | grep gateway.jar | awk '{print $2}'  | head -n 1

/usr/java/jdk1.8.0_232-cloudera/bin/jstack -l <pid> > /tmp/jstack1.out

after 30 sec

/usr/java/jdk1.8.0_232-cloudera/bin/jstack -l 18778 > /tmp/jstack2.out

after 30 sec

/usr/java/jdk1.8.0_232-cloudera/bin/jstack -l 18778 > /tmp/jstack3.out

1. Jstacks :
---
#!/bin/bash -x 
for I in 1 2 3 4 5; do kill -3 `cat /var/run/knox/gateway/gateway.pid `; sleep 5 ; done 
grep -c 'dump' /var/log/knox/gateway.out 
--- 

2. System stats :
---
# netstat -an | grep 8443 
# top -c -b -n 3 2>&1 > /tmp/top.txt ( this will capture three iterations for top) 
# sar -n DEV 2 5 > /tmp/sar.network 
# for ((i=0 ; i<3 ;i++ )) ; do netstat -s >> /tmp/netstat.stats ; done 
# free -m > /tmp/free.txt 
# vmstat 2 5 > /tmp/vmstat.txt 



When Knox service fails to respond again, collect at least three jstack thread dumps of the Knox java service by running following commands, with gap of at least 30 seconds in between each command, so jstack files can be reviewed for possible threads being blocked.

jstack -l <Knox_PID> > /tmp/knox_jstack#.txt 

Increase Knox JVM Heap size and enable GC logging. Knox Heap size should be set based on user's environment.

Save backup copy of /usr/hdp/current/knox-server/bin/gateway.sh script and update the APP_MEM_OPTS setting in the gateway.sh script, e.g.,

APP_MEM_OPTS="-Xmx5g -XX:NewSize=3G -XX:MaxNewSize=3G -verbose:gc -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -Xloggc:/var/log/knox/knox-gc.log -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps"

```


