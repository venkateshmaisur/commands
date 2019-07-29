
# MIT Kerberos Installation script

Modify REALM and password

```sh
#!/bin/sh
# Install packages
echo "Installing Kerberos Packages"
yum install -y krb5-server krb5-libs krb5-workstation
# #################################
# Assming default configuration!!!!
# #################################
REALM="PRAVIN.COM"
HOSTNAME=$(hostname -f)
echo "Creating krb5.conf file, KDC host is ${HOSTNAME} and realm is ${REALM}"
cat >/etc/krb5.conf <<EOF
[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log
[libdefaults]
default_realm = ${REALM}
dns_lookup_realm = false
dns_lookup_kdc = false
ticket_lifetime = 24h
renew_lifetime = 7d
forwardable = true
[realms]
${REALM} = {
kdc = ${HOSTNAME}
admin_server = ${HOSTNAME}
}
[domain_realm]
.${HOSTNAME} = ${REALM}
${HOSTNAME} = ${REALM}
EOF

# Create kdam5.aclfile
echo "Creating kadm5.acl file, realm is ${REALM}"
cat >/var/kerberos/krb5kdc/kadm5.acl <<EOF
*/admin@${REALM} *
EOF
# Create KDC database
echo "Created KDC database, this could take some time"
kdb5_util create -s -P Welcome
# Create admistrative user
echo "Creating administriative account:"
echo " principal: admin/admin"
echo " password: Welcome"
kadmin.local -q 'addprinc -pw Welcome admin/admin'
# Starting services
echo "Starting services"
service krb5kdc start
service kadmin start
chkconfig krb5kdc on
chkconfig kadmin on

```


# Windows Kerberos 

##### Windows kerberos spn

```
These are the steps to configure Windows clients with KDC realm. These KDC settings are not stored in configuration files but in the Windows registry keys. 

1) Run following Windows ksetup commands with AD Administrator privileges. 

In General: 
- ksetup /AddKdc <RealmName> <KDC_HostName> 
- ksetup /addhosttorealmmap <KDC_HostName> <RealmName> 
- ksetup /mapuser * * 

Your Specific KDC configuration: 
- ksetup /AddKdc HDPDV.US.KELLOGG.COM usawshdpdv402.us.kellogg.com 
- ksetup /addhosttorealmmap usawshdpdv402.us.kellogg.com HDPDV.US.KELLOGG.COM 
- ksetup /mapuser * * 

2) Reboot the Windows client after above ksetup changes. 
```

```
#ksetup /addhosttorealmmap <Hostname> <Realm>

Example:
#ksetup /addhosttorealmmap hdpl07oozie.service.group GLOBAL.LLOYDSTSB.COM 

```

## Remove realm from windows

```
When ksetup command was run on your Windows laptop it will sample MIT KDC realms, which need to be removed first. 

> ksetup 

ATHENA.MIT.EDU 
kdc = kerberos.mit.edu 
kdc = kerberos-1.mit.edu 
kdc = kerberos-2.mit.edu 

CSAIL.MIT.EDU 
kdc = kerberos-1.csail.mit.edu 
kdc = kerberos-2.csail.mit.edu 

Failed to create Kerberos key: 5 (0x5) 
Failed to open Kerberos Key: 0x5 


Since the Kerberos client was not uninstalled yet from your Windows laptop, we were expecting the two sample KDC realms and their KDC hosts would need to be removed manually via the following commands. 

- ksetup /delkdc <RealmName> <KDCName> 
- ksetup /removerealm <RealmName> 

Remove each KDC host individually: 

- ksetup /delkdc ATHENA.MIT.EDU kerberos.mit.edu 
- ksetup /delkdc ATHENA.MIT.EDU kerberos-1.mit.edu 
- ksetup /delkdc ATHENA.MIT.EDU kerberos-2.mit.edu 
- ksetup /delkdc CSAIL.MIT.EDU kerberos-1.csail.mit.edu 
- ksetup /delkdc CSAIL.MIT.EDU kerberos-2.csail.mit.edu 

Remove the sample KDC realms: 

- ksetup /removerealm ATHENA.MIT.EDU 
- ksetup /removerealm CSAIL.MIT.EDU 
```
