# Knox CDP-DC services


## Atlas

#### Atlas API
```bash
curl -iku knoxui:knoxui https://localhost:8443/gateway/cdp-proxy-api/atlas/api/atlas/v2/glossary
```
#### Atlas UI
```bash
Open in your browser
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

## Cloudera Manager API
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
```
Open in your browser
https://KNOX_HOST:8443/gateway/cdp-proxy/hdfs/?host=http://NAMENODE_HOST:NAMENODE_PORT 
```

Hive
JDBC API
Hive On Tez - HiveServer2 - JDBC
Configuration - OPSAPS-54505
Set "Hive Service->Configuration->HiveServer2 Transport Mode" to HTTP
Restart stale services with CM

Testing
# Assumes run as a user that has access to gateway.jks (ie: root)
# beeline -u 'jdbc:hive2://localhost:8443/;ssl=true;sslTrustStore=/var/lib/knox/gateway/data/security/keystores/gateway.jks;trustStorePassword=knoxsecret;transportMode=http;httpPath=gateway/cdp-proxy-api/hive' -n knoxui -p knoxui -e 'show databases;'


Hive LLAP - HiveServer2 - JDBC - CDPD-1800
Not supported.

Cannot have two of the same services in one topology (ie: two HIVE). If needed to have both LLAP HS2 and original HS2 proxied in one topology, need to make a new Knox service definition (ie: HIVELLAP).

Hive LLAP HS2 has active/passive mode so requires a new service definition and probably dispatch - CDPD-1800
HiveServer2 UI
Not supported. HS2 UI will be disabled in CDP - CDPD-1799


Hue
Configuration - CDPD-7797
CM->Hue Configuration->Authentication Backend
desktop.auth.backend.KnoxSpnegoDjangoBackend
Hue UI 
Open https://KNOX_HOST:8443/gateway/cdp-proxy/hue/ in your browser

Impala
JDBC API
TODO
# beeline -u "jdbc:hive2://$(hostname -f):8443/;ssl=true;sslTrustStore=/var/lib/knox/gateway/data/security/keystores/gateway.jks;trustStorePassword=knoxsecret;transportMode=http;httpPath=gateway/cdp-proxy-api/impala" -n knoxui -p knoxui -e 'show databases;'


Impala UI
TODO
https://KNOX_HOST:8443/gateway/cdp-proxy/impalaui?scheme=https&host=sko-demo2-coordinator0.adar-sko.xcu2-8y8x.dev.cldr.work&port=25000


Livy
Livy API
# curl -iku knoxui:knoxui https://localhost:8443/gateway/cdp-proxy-api/livy/batches/


Livy UI
Open https://KNOX_HOST:8443/gateway/cdp-proxy/livy/ui/ in your browser


MapReduce
Job History UI
Open https://KNOX_HOST:8443/gateway/cdp-proxy/jobhistory/ in your browser


Oozie
Oozie API
# curl -iku knoxui:knoxui https://localhost:8443/gateway/cdp-proxy-api/oozie/v1/admin/build-version


Oozie UI
Open https://KNOX_HOST:8443/gateway/cdp-proxy/oozie/ in your browser


Phoenix (aka Avatica)
Phoenix Query Server JDBC
TODO

# phoenix-sqlline-thin --authentication BASIC --auth-user knoxui --auth-password knoxui --serialization PROTOBUF --truststore /var/lib/knox/gateway/data/security/keystores/gateway.jks --truststore-password knoxsecret "https://$(hostname -f):8443/gateway/cdp-proxy-api/avatica"


Ranger
Configuration - OPSAPS-54502
Cloudera Manager->Ranger Service->Configuration
Check the "Enable Knox Trusted Proxy Support" box
ranger.usersync.group.based.role.assignment.rules = ROLE_SYS_ADMIN:u:knoxui
Adding knoxui to ROLE_SYS_ADMIN only needed if trying to use CDEP
Restart stale services
Ranger API
Note: Need to make sure user has permissions (knoxui doesn't by default) to access API endpoint or get 401 back. 
# curl -iku knoxui:knoxui https://localhost:8443/gateway/cdp-proxy-api/ranger/service/public/v2/api/servicedef

Ranger UI
Open https://KNOX_HOST:8443/gateway/cdp-proxy/ranger/ in your browser
Spark
Spark History UI
Open https://KNOX_HOST:8443/gateway/cdp-proxy/sparkhistory/ in your browser


Solr
Solr API
# curl -iku knoxui:knoxui https://localhost:8443/gateway/cdp-proxy-api/solr/admin/collections?action=CLUSTERSTATUS

Solr UI
Open https://KNOX_HOST:8443/gateway/cdp-proxy/solr/ in your browser

YARN
YARN ResourceManager API
# curl -iku knoxui:knoxui https://localhost:8443/gateway/cdp-proxy-api/resourcemanager/v1/cluster


YARN UI
YARN UI V1
Open https://KNOX_HOST:8443/gateway/cdp-proxy/yarn/ in your browser
YARN UI V2
Open https://KNOX_HOST:8443/gateway/cdp-proxy/yarnuiv2/ in your browser
Zeppelin
Zeppelin UI
Open https://KNOX_HOST:8443/gateway/cdp-proxy/zeppelin/ in your browser

