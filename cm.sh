# Cloudera Manager

### Custom kerberos krb5.conf file

```
Set below value in /etc/default/cloudera-scm-agent
CMF_AGENT_KRB5_CONFIG=/tmp/krb5.conf
KRB5_CONFIG=/tmp/krb5.conf
```

### Cm agent kerbeors debug
```
Set below value in /etc/default/cloudera-scm-agent
KRB5_TRACE=/tmp/krb.log

systemctl restart cloudera-scm-agent
```
