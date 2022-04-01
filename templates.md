Collect tar files of process dir:

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
