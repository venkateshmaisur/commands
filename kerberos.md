
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

## Enable Pre-Authentication

```
# Enable by Default
default_principal_flags = +preauth

cat /var/kerberos/krb5kdc/kdc.conf
[kdcdefaults]
 kdc_ports = 88
 kdc_tcp_ports = 88

[realms]
 PRAVIN.COM = {
default_principal_flags = +preauth


++++++++++++++++++++++++++++++++++
# kdb5_util dump -verbose dumpfile
Capture the list of principals

# kadmin.local -q listprincs > principals.sh
# for i in `cat principals.sh`; do kadmin.local -q "modprinc +requires_preauth $i"; done

# How check

getprinc <principal>

Attributes: REQUIRES_PRE_AUTH
```

## Debug
```
yum install -y tcpdump wireshark
tcpdump -i eth0 -w /var/tmp/krb_phase1.pcap port 88 &
tshark -r /var/tmp/krb_phase1.pcap
tshark -r /var/tmp/krb_phase1.pcap -O kerberos
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

##### Windows kerberos debug:
```
Use below java code to get the kerberos debug from windows client. 

#vi GetURL.java 

import java.io.*; 
import java.net.*; 

public class GetURL { 
public static void main(String[] args) { 
InputStream in = null; 
OutputStream out = null; 
System.setProperty("sun.security.krb5.debug","true"); 
System.setProperty("sun.security.spnego.debug","true"); 
try { 
if ((args.length < 1)) 
throw new IllegalArgumentException("Provide URL to access"); 

URL url = new URL(args[0]); 
in = url.openStream(); 
out = System.out; 

byte[] buffer = new byte[4096]; 
int bytes_read; 
while((bytes_read = in.read(buffer)) != -1) 
out.write(buffer, 0, bytes_read); 
} 
catch (Exception e) { 
System.err.println(e); 
System.err.println("Usage: java GetURL <URL> "); 
} 
finally { 
try { in.close(); out.close(); } catch (Exception e) {} 
} 
} 
} 


#javac GetURL.java 

#java -Djavax.net.ssl.trustStore=<truststorePath> -Djavax.net.ssl.trustStorePassword=<Password> GetURL https://hdpl07oozie.service.group:11443/oozie 

trsuststore path is a jks file where SSL CA cert chain of Oozie is imported. trustStorePassword is the truststore password. 

A temp jks can be created on Linux and transferred to Windows client (windows java will also have keytool command that can be used to create jks on windows client from PEM certs) . 


Above command will print kerberos debug on stdout, collect the output for both working and not working oozie urls.
```

###### java 242/252 known issue
```
Back-Up the Kerberos Database

# kdb5_util dump -verbose dumpfile
Capture the list of principals

# kadmin.local -q listprincs > principals.sh
If krb5.conf has renew_lifetime = 7d, run below cmds

# for i in `cat principals.sh`; do kadmin.local -q "modprinc -maxlife 168hours $i"; done
# for i in `cat principals.sh`; do kadmin.local -q "modprinc -maxrenewlife 168hours $i"; done
```


### Ambari kerberos creation phase debug
```bash
$ kinit -S kadmin/c174-node1.supportlab.cloudera.com@SUPPORTLAB.CLOUDERA.COM admin/admin@SUPPORTLAB.CLOUDERA.COM  -c /tmp/cache

that cache will have service principal  kadmin/ambari-host

[root@c174-node2 ~]# klist -c /tmp/cache
Ticket cache: FILE:/tmp/cache
Default principal: admin/admin@SUPPORTLAB.CLOUDERA.COM
Valid starting     Expires            Service principal
10/13/20 11:16:59  10/20/20 11:16:59  kadmin/c174-node1.supportlab.cloudera.com@SUPPORTLAB.CLOUDERA.COM


Then only you can use that cache to perform any activity like

# kadmin -r SUPPORTLAB.CLOUDERA.COM -s c174-node1.supportlab.cloudera.com -c /tmp/cache -q 'get_principal admin/admin'


Normal user or admin user cache wont work here, it needs kadmin service principal
```

### Enable renewable

```bash
[root@c274-node1 ~]# kinit test
Password for test@SUPPORTLAB.CLOUDERA.COM:
[root@c274-node1 ~]# klist -f
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: test@SUPPORTLAB.CLOUDERA.COM

Valid starting     Expires            Service principal
10/28/20 09:16:58  10/29/20 09:16:58  krbtgt/SUPPORTLAB.CLOUDERA.COM@SUPPORTLAB.CLOUDERA.COM
  Flags: FI


==> I dont see R in Flags means this principal dont have reneweable enabled.

As its MIT KDC, you can enabled it.


Login into MIT KDC node.

# you can check the Renewable details using below cmds

kadmin.local -q "getprinc test@SUPPORTLAB.CLOUDERA.COM"
kadmin.local -q "getprinc test@SUPPORTLAB.CLOUDERA.COM"   | grep renewable

# Update the principal with renewable
kadmin.local -q "modprinc -maxlife 24hours test@SUPPORTLAB.CLOUDERA.COM"
kadmin.local -q "modprinc -maxrenewlife 168hours test@SUPPORTLAB.CLOUDERA.COM"

kadmin.local -q "modprinc -maxlife 24hours krbtgt/SUPPORTLAB.CLOUDERA.COM@SUPPORTLAB.CLOUDERA.COM"
kadmin.local -q "modprinc -maxrenewlife 168hours krbtgt/SUPPORTLAB.CLOUDERA.COM@SUPPORTLAB.CLOUDERA.COM"

kinit user

klist -f

you will see "Flags: FRI" with R flag now.

Generate new ticket in Windows and test MIT kerberos client.


If you want to make sure all new principals which will be created in MIT should have Renewable flag, so make sure you have below properties in /var/kerberos/krb5kdc/kdc.conf Under  [realms] section

max_life = 1d 0h 0m 0s
max_renewable_life = 7d 0h 0m 0s

```

## Custom krb5.conf in cdp
```
1. Created the krb5.conf under $JAVA_HOME/jre/lib/security on all the nodes
2. Updated Cloudera Manager's environment variables:

In /etc/default/cloudera-scm-server we changed the following default:
export CMF_JAVA_OPTS="-Xmx2G -XX:MaxPermSize=256m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp"
to
export CMF_JAVA_OPTS="-Xmx2G -XX:MaxPermSize=256m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp -Djava.security.krb5.conf=/usr/java/jdk1.8.0_181-cloudera/jre/lib/security/cloudera_krb5.conf"

3. Updated the Agent's environment variables:

In /etc/default/cloudera-scm-agent we added the following on a new line: CMF_AGENT_KRB5_CONFIG=/usr/java/jdk1.8.0_181-cloudera/jre/lib/security/cloudera_krb5.conf

4. Then we updated the following under 'Advanced Java Configuration' for each of the services

-Djava.security.krb5.conf=/usr/java/jdk1.8.0_181-cloudera/jre/lib/security/cloudera_krb5.conf

5. Then restarted Zookeeper service and it came right up

6. Then restarting the HDFS services, the following roles did not start : NameNode, Failover controllers etc. So we added the following line [****] to this file: /opt/cloudera/parcels/CDH-6.3.0-1.cdh6.3.0.p0.1279813/meta/cdh_env.sh
[****] export KRB5_CONFIG=/usr/java/jdk1.8.0_181-cloudera/jre/lib/security/cloudera_krb5.conf

7. Then the HDFS roles started but the RPC communication failed on both the NameNodes. So we added the following to the Safety Value 'Environment Variable' section:
HADOOP_OPTS="-Djava.security.krb5.conf=/usr/java/jdk1.8.0_181-cloudera/jre/lib/security/cloudera_krb5.conf"

8. Finally, running the hdfs command failed with the error regarding TGT missing and we resolved that by export this variable which may need to be set at user profile
export HADOOP_OPTS="-Djava.security.krb5.conf=/usr/java/jdk1.8.0_181-cloudera/jre/lib/security/cloudera_krb5.conf"
```

```

RULE:[1:$1@$0](.*@PRAVIN.COM)s/@.*//

By default, translations based on rules are done maintaining the case of the input principal. For example, given the rule

RULE:[1:$1@$0](.*@EXAMPLE.COM)s/@.*//

If the source string is ambari-qa@EXAMPLE.COM, the result is ambari-qa
```
