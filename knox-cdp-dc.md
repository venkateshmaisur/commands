# Knox CDP-DC services

##### How to connect

- [Atlas](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#atlas)
- [Cloudera Manager](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#cloudera-manager)
- [HBase](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#hbase)
- [HDFS](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#hdfs)
- [Hive](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#hive)
- [Hue](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#hue)
- [Impala](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#impala)
- [Livy](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#livy)
- [MR](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#mapreduce)
- [HDFS](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#oozie)
- [Oozie](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#oozie)
- [Phoenix](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#phoenix-aka-avatica)
- [Ranger](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#ranger)
- [Spark](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#spark)
- [Solr](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#solr)
- [Yarn](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#yarn)
- [Zeppelin](https://github.com/bhagadepravin/commands/blob/master/knox-cdp-dc.md#zeppelin)
- []()

```
1) cd /opt/cloudera/parcels/CDH-7.2.0-1.cdh7.2.0.p0.3758356/lib/knox/bin
2) ./gateway.sh status
3) export KNOX_GATEWAY_CONF_DIR=/var/lib/knox/gateway/conf
4) export KNOX_GATEWAY_DATA_DIR=/var/lib/knox/gateway/data
5) export KNOX_GATEWAY_LOG_DIR=/var/log/knox/gateway
6) export KNOX_GATEWAY_LOG_OPTS="-Dlog4j.configuration=/var/lib/knox/gateway/conf/gateway-log4j.properties"
7) export KNOX_CLI_LOG_OPTS="-Dlog4j.configuration=/var/lib/knox/gateway/conf/knoxcli-log4j.properties"
8) sudo -u cloudera-scm -E ./gateway.sh clean
9) sudo -u cloudera-scm ./gateway.sh start
10) (ls -l /var/lib/knox/gateway/data/security/master && namei -l /var/lib/knox/gateway/data/security/master) | tee -a /tmp/knox-namei.out
11) tar cvzf /tmp/Knox-$(hostname -f)_$(date +"%Y%m%d%H%M%S").tgz /var/log/knox/gateway/{gateway,knoxcli}.log /tmp/knox-namei.out

```

## Atlas

#### Atlas API
```bash
curl -iku knoxui:knoxui https://localhost:8443/gateway/cdp-proxy-api/atlas/api/atlas/v2/glossary
```
#### Atlas UI
Open in your browser
```bash
https://KNOX_HOST:8443/gateway/cdp-proxy/atlas/
```

## Cloudera Manager
```sh
Configuration
In Cloudera Manager > Knox > Configuration > default.app.topology.name = default
Restart state services

In Cloudera Manager > Administration > Users & Roles > Add Local User
Add local user called "knoxui" with role "Full Administrator"

In Cloudera Manager > Administration > Settings > External Authentication:
Enable SPNEGO/Kerberos Authentication for the Admin Console and API: true

Knox Proxy Principal: knox
Allowed Groups for Knox Proxy: *
Allowed Hosts for Knox Proxy: *
Allowed Users for Knox Proxy: *

Restart Cloudera Manager

SSH into the Cloudera Manager node

# service cloudera-scm-server restart
```

Note: Cloudera Manager restart can take a little while

#### Cloudera Manager API
```
curl -iku knoxui:knoxui 'https://localhost:8443/gateway/cdp-proxy-api/cm-api/v32/tools/echo?message=hello'
```

#### Cloudera Manager UI
Open in your browser
```
https://KNOX_HOST:8443/cmf/home 
```

## HBase

#### HBase API
```
REST / WebHBase
Configuration
HBase Service -> Add Role -> HBase REST Server
HBase Service -> Configuration -> hbase.rest.authentication.type = Kerberos
Start HBase REST Server role
```

#### Master and RegionServer UI

Openin your browser
```
https://KNOX_HOST:8443/gateway/cdp-proxy/hbase/webui/master?host=HBASE_MASTER_HOST&port=HBASE_MASTER_PORT 
```


## HDFS

#### HDFS API - WebHDFS
```
curl -iku knoxui:knoxui https://localhost:8443/gateway/cdp-proxy-api/webhdfs/v1/?op=LISTSTATUS
```

#### HDFS UI
Open in your browser
```
https://KNOX_HOST:8443/gateway/cdp-proxy/hdfs/?host=http://NAMENODE_HOST:NAMENODE_PORT 
```

## Hive
#### JDBC API
```
Hive On Tez - HiveServer2 - JDBC
Configuration - OPSAPS-54505
Set "Hive Service->Configuration->HiveServer2 Transport Mode" to HTTP
Restart stale services with CM
```

Testing
```bash
Assumes run as a user that has access to gateway.jks (ie: root)

beeline -u 'jdbc:hive2://localhost:8443/;ssl=true;sslTrustStore=/var/lib/knox/gateway/data/security/keystores/gateway.jks;trustStorePassword=knoxsecret;transportMode=http;httpPath=gateway/cdp-proxy-api/hive' -n knoxui -p knoxui -e 'show databases;'
```

#### Hive LLAP - HiveServer2 - JDBC - CDPD-1800
Not supported.
```
Cannot have two of the same services in one topology (ie: two HIVE). If needed to have both LLAP HS2 and original HS2 proxied in one topology, need to make a new Knox service definition (ie: HIVELLAP).

Hive LLAP HS2 has active/passive mode so requires a new service definition and probably dispatch - CDPD-1800
HiveServer2 UI
Not supported. HS2 UI will be disabled in CDP - CDPD-1799
```

## Hue
```
Configuration - CDPD-7797
CM->Hue Configuration->Authentication Backend
desktop.auth.backend.KnoxSpnegoDjangoBackend
```
#### Hue UI 
Open in your browser
```
https://KNOX_HOST:8443/gateway/cdp-proxy/hue/ 
```

## Impala

#### JDBC API
```bash
beeline -u "jdbc:hive2://$(hostname -f):8443/;ssl=true;sslTrustStore=/var/lib/knox/gateway/data/security/keystores/gateway.jks;trustStorePassword=knoxsecret;transportMode=http;httpPath=gateway/cdp-proxy-api/impala" -n knoxui -p knoxui -e 'show databases;'
```

#### Impala UI
TODO
```
https://KNOX_HOST:8443/gateway/cdp-proxy/impalaui?scheme=https&host=sko-demo2-coordinator0.adar-sko.xcu2-8y8x.dev.cldr.work&port=25000
```


## Livy
#### Livy API
```
curl -iku knoxui:knoxui https://localhost:8443/gateway/cdp-proxy-api/livy/batches/
```

#### Livy UI
Open  in your browser
```
https://KNOX_HOST:8443/gateway/cdp-proxy/livy/ui/
```

## MapReduce
#### Job History UI
Open in your browser
```
https://KNOX_HOST:8443/gateway/cdp-proxy/jobhistory/ 
```


## Oozie
#### Oozie API
```
curl -iku knoxui:knoxui https://localhost:8443/gateway/cdp-proxy-api/oozie/v1/admin/build-version
```
####Oozie UI
Open in your browser 
```
https://KNOX_HOST:8443/gateway/cdp-proxy/oozie/ 
```

## Phoenix (aka Avatica)
#### Phoenix Query Server JDBC
TODO
```bash
phoenix-sqlline-thin --authentication BASIC --auth-user knoxui --auth-password knoxui --serialization PROTOBUF --truststore /var/lib/knox/gateway/data/security/keystores/gateway.jks --truststore-password knoxsecret "https://$(hostname -f):8443/gateway/cdp-proxy-api/avatica"
```


## Ranger
```
Configuration - OPSAPS-54502
Cloudera Manager->Ranger Service->Configuration

Check the "Enable Knox Trusted Proxy Support" box

ranger.usersync.group.based.role.assignment.rules = ROLE_SYS_ADMIN:u:knoxui

Adding knoxui to ROLE_SYS_ADMIN only needed if trying to use CDEP

Restart stale services
```

#### Ranger API
Note: Need to make sure user has permissions (knoxui doesn't by default) to access API endpoint or get 401 back. 
```
curl -iku knoxui:knoxui https://localhost:8443/gateway/cdp-proxy-api/ranger/service/public/v2/api/servicedef
```

#### Ranger UI
Open in your browser
```
https://KNOX_HOST:8443/gateway/cdp-proxy/ranger/ 
```

## Spark

#### Spark History UI
Open in your browser 
```
https://KNOX_HOST:8443/gateway/cdp-proxy/sparkhistory/
```

## Solr

#### Solr API
```
curl -iku knoxui:knoxui https://localhost:8443/gateway/cdp-proxy-api/solr/admin/collections?action=CLUSTERSTATUS
```

#### Solr UI
Open in your browser
```
https://KNOX_HOST:8443/gateway/cdp-proxy/solr/ 
```

## YARN

#### YARN ResourceManager API
```
curl -iku knoxui:knoxui https://localhost:8443/gateway/cdp-proxy-api/resourcemanager/v1/cluster
```
### YARN UI
#### YARN UI V1
Open in your browser
```
https://KNOX_HOST:8443/gateway/cdp-proxy/yarn/ 
```
#### YARN UI V2
Open in your browser
```
https://KNOX_HOST:8443/gateway/cdp-proxy/yarnuiv2/ 
```

## Zeppelin

#### Zeppelin UI
Openin your browser
```
 https://KNOX_HOST:8443/gateway/cdp-proxy/zeppelin/ 
```


#### Knox Group level access not working
```
Please refer: https://jira.cloudera.com/browse/ENGESC-4918

You need to set below CM -> Knox ->  Configurations: -> 

 gateway.group.config.hadoop.security.group.mapping=org.apache.hadoop.security.LdapGroupsMapping


Add below configs to "Knox Service Advanced Configuration Snippet (Safety Valve) for conf/gateway-site.xml"


 <property>
        <name>gateway.group.config.hadoop.security.group.mapping.ldap.bind.user</name>
        <value>uid=guest,ou=people,dc=hadoop,dc=apache,dc=org</value>
    </property>
    <property>
        <name>gateway.group.config.hadoop.security.group.mapping.ldap.bind.password</name>
        <value>guest-password</value>
    </property>
    <property>
        <name>gateway.group.config.hadoop.security.group.mapping.ldap.url</name>
        <value>ldap://localhost:33389</value>
    </property>
    <property>
        <name>gateway.group.config.hadoop.security.group.mapping.ldap.base</name>
        <value></value>
    </property>
    <property>
        <name>gateway.group.config.hadoop.security.group.mapping.ldap.search.filter.user</name>
        <value>(&amp;(|(objectclass=person)(objectclass=applicationProcess))(cn={0}))</value>
    </property>
    <property>
        <name>gateway.group.config.hadoop.security.group.mapping.ldap.search.filter.group</name>
        <value>(objectclass=groupOfNames)</value>
    </property>
    <property>
        <name>gateway.group.config.adoop.security.group.mapping.ldap.search.attr.member</name>
        <value>member</value>
    </property>
    <property>
        <name>gateway.group.config.hadoop.security.group.mapping.ldap.search.attr.group.name</name>
        <value>cn</value>
    </property>



# Check which shared-provider cdp-proxy using or any other topology 
CM -> Knox ->  Configurations: -> Search in filter "Knox Simplified Topology Management - cdp-proxy cdp-proxy"
if its set to "providerConfigRef=sso"


To modify sso and add identity-assertion, followed below steps:

Goto -> CM -> Knox -> Knox Gateway Advanced Configuration Snippet (Safety Valve) for conf/cdp-resources.xml

 
name = providerConfigs:sso

value = role=federation#federation.name=SSOCookieProvider#federation.param.sso.authentication.provider.url=https://KNOX-HOSTNAME:8443/gateway/knoxsso/api/v1/websso#role=identity-assertion#identity-assertion.name=HadoopGroupProvider#identity-assertion.enabled=true#identity-assertion.param.CENTRAL_GROUP_CONFIG_PREFIX=gateway.group.config.#role=authorization#authorization.name=XASecurePDPKnox#authorization.enabled=true

#Note: Make sure you update "sso.authentication.provider.url"


Save and restart Knox 

```
```
<property><name>gateway.group.config.hadoop.security.group.mapping.ldap.bind.user</name><value>uid=guest,ou=people,dc=hadoop,dc=apache,dc=org</value></property><property><name>gateway.group.config.hadoop.security.group.mapping.ldap.bind.password</name><value>guest-password</value></property><property><name>gateway.group.config.hadoop.security.group.mapping.ldap.url</name><value>ldap://localhost:33389</value></property><property><name>gateway.group.config.hadoop.security.group.mapping.ldap.base</name><value></value></property><property><name>gateway.group.config.hadoop.security.group.mapping.ldap.search.filter.user</name><value>(|(objectclass=person)(objectclass=applicationProcess))(cn={0})</value></property><property><name>gateway.group.config.hadoop.security.group.mapping.ldap.search.filter.group</name><value>(objectclass=groupOfNames)</value></property><property><name>gateway.group.config.adoop.security.group.mapping.ldap.search.attr.member</name><value>member</value></property><property><name>gateway.group.config.hadoop.security.group.mapping.ldap.search.attr.group.name</name><value>cn</value></property>
```

####. modify homepage descriptor
```
After checking, found, we are hitting https://jira.cloudera.com/browse/OPSAPS-58747 (Internal jira)
- As per the jira we should have KNOX-METADATA, KNOXSSOUT, and KNOX-SESSSION in the homepage topology

#############################################
- We followed below steps to resolve this issue:

1. Stop the knox service from CM UI
2. Go to CSD directory, /opt/cloudera/cm/csd/
3. Take a backup of KNOX_C715-7.2.4.jar 
4. Read the jar

#/usr/lib/jvm/latest/bin/jar -tvf /opt/cloudera/cm/csd/KNOX_C715-7.2.4.jar | grep -i homepage

5. Extract the homepage.json file, 

#/usr/lib/jvm/latest/bin/jar -xvf /opt/cloudera/cm/csd/KNOX_C715-7.2.4.jar aux/descriptors/homepage.json

6. Modify homepage.json file like below:

vi aux/descriptors/homepage.json
{
"provider-config-ref": "homepage",
"services": [
{
"name": "KNOX-METADATA"
},
{
"name": "KNOXSSOUT"
},
{
"name": "KNOX-SESSION"
}
],
"applications": [
{
"name": "home"
}
]

7. update the jar again:
#/usr/lib/jvm/latest/bin/jar -uvf /opt/cloudera/cm/csd/KNOX_C715-7.2.4.jar aux/descriptors/homepage.json

8. Restart cm server
#systemctl restart cloudera-scm-server

9. Start the knox service from CM UI
#############################################


- Knox UI is up and running properly
```



```
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
authentication.param.main.ldapRealm.contextFactory.systemUsername=test1@SUPPORT.COM
authentication.param.main.ldapRealm.contextFactory.systemPassword=hadoop12345!
authentication.param.remove=main.pamRealm
authentication.param.remove=main.pamRealm.service


authentication.param.main.cacheManager=org.apache.knox.gateway.shirorealm.KnoxCacheManager
authentication.param.main.securityManager.cacheManager=$cacheManager
authentication.param.main.ldapRealm.authenticationCachingEnabled=true
authentication.param.main.cacheManager.cacheManagerConfigFile=classpath:ehcache.xml

In the Knox configs for "Knox Simplified Topology Management - API Authentication Provider", please ensure to set,
"authentication.param.main.cacheManager.cacheManagerConfigFile=classpath:ehcache.xml"
And it will be reflected as the below in the cdp-proxy-api.xml topology file,
--------------------
<param>
<name>main.cacheManager.cacheManagerConfigFile</name>
<value>classpath:ehcache.xml</value>
</param>
--------------------
Next, please ensure to place your custom "ehcache.xml" under the path "/opt/cloudera/parcels/CDH-<version>/lib/knox/conf/".
For example, like the below
---------
[root@c4235-node4 topologies]# ls -l /opt/cloudera/parcels/CDH-7.1.3-1.cdh7.1.3.p0.4992530/lib/knox/conf/ehcache.xml
-rwxr-xr-x 1 root root 347

```
