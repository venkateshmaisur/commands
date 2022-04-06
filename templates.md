Collect tar files of process dir:

```
kinit -kt $(find /var/run/cloudera-scm-agent/process/ -name "*SOLR_SERVER" | head -1)/solr.keytab solr/`hostname -f`
```

### Ranger usersync
```bash
tar -cvf usersync-process.tar $(find /var/run/cloudera-scm-agent/process/ -name "*RANGER_USERSYNC" | head -1)
```

### Raanger admin
```
tar -cvf  ranger-admin.tar.gz $(find /var/run/cloudera-scm-agent/process/ -name "*RANGER_ADMIN" | head -1) /var/log/ranger/admin/ranger-admin-`hostname -f`-ranger.log /var/log/ranger/admin/catalina.out
```

### Ranger tagsync
```
tar -cvf  ranger-tagsync.tar.gz $(find /var/run/cloudera-scm-agent/process/ -name "*RANGER_TAGSYNC" | head -1) /var/log/ranger/admin/tagsync.log
```

### Knox
```
tar -cvf  knox.tar.gz $(find /var/run/cloudera-scm-agent/process/ -name "*KNOX_GATEWAY" | head -1)  /var/lib/knox/gateway/conf /var/lib/knox/gateway/data/deployments/cdp-proxy-api* $KNOX_PROCESS_DIR /var/log/knox/gateway/gateway.log /var/log/knox/gateway/gateway-audit.log
```

### HS2
```
$ tar -cvf hive-process.tar $(find /var/run/cloudera-scm-agent/process/ -name "*hive_on_tez-HIVESERVER2" | head -1)
```
