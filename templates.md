Collect tar files of process dir:

```bash
tar -cvf usersync-process.tar $(find /var/run/cloudera-scm-agent/process/ -name "*RANGER_USERSYNC" | head -1)
```
