#### User authentication from Windows Workstation to HDP Realm Using MIT Kerberos Client (with Firefox) 
https://community.cloudera.com/t5/Community-Articles/User-authentication-from-Windows-Workstation-to-HDP-Realm/ta-p/245957

Open Firefox, type about:config in URL and hit enter Search for and change below parameters

```sh
network.negotiate-auth.trusted-uris = .domain.com
network.negotiate-auth.using-native-gsslib = false
network.negotiate-auth.delegation-uris = .domain.com
network.auth.use-sspi = false
network.negotiate-auth.allow-non-fqdn = true
```

#### Configure Mac and Firefox to access HDP/HDF SPNEGO UI
https://community.cloudera.com/t5/Community-Articles/Configure-Mac-and-Firefox-to-access-HDP-HDF-SPNEGO-UI/ta-p/249092


#### Firefox kerberos debug
1. Close all instances of Firefox.
2. In a command prompt, export values for the NSPR_LOG_* variables:
```bash
export NSPR_LOG_MODULES=negotiateauth:5
export NSPR_LOG_FILE=/tmp/moz.log
```
3. Restart Firefox from that shell, and visit the website where Kerberos authentication is failing.
4. Check the /tmp/moz.log file for error messages with nsNegotiateAuth in the message.


* Info: https://www.ietf.org/rfc/rfc2478.txt



### CDP HIVE Spnego WebUI troubleshooting.

Set below configs to enable WebUI when Kerberos is enabled.

```xml
hive.server2.webui.spnego.keytab=hive.keytab
hive.server2.webui.spnego.principal=HTTP/_HOST@ROOT.HWX.SITE
hive.server2.webui.use.spnego=true
hive.users.in.admin.role=*


XML:

<property><name>hive.server2.webui.spnego.keytab</name><value>hive.keytab</value></property><property><name>hive.server2.webui.spnego.principal</name><value>HTTP/_HOST@ROOT.HWX.SITE</value></property><property><name>hive.server2.webui.use.spnego</name><value>true</value></property><property><name>hive.users.in.admin.role</name><value>*</value></property>
```

HiveServer2 GUI/ Web UI does not display active client connections after enabling Kerberos.
This issue occurs when Spnego authentication is disabled.

https://docs.cloudera.com/cdp-private-cloud-base/7.1.6/securing-hive/topics/hive-spnego.html 

##### troubleshooting
1. Login into HS2 node.

```bash
export HIVESERVER2_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*hive_on_tez-HIVESERVER2 | tail -1)
kinit -kt $HIVESERVER2_PROCESS_DIR/hive.keytab hive/`hostname -f`
```

Connect to beeline and run single cmd "use any-database-name"
exit.
run curl cmd and share us the output. previous ran curl cmd was incorrect.

```
curl -ik -v --negotiate -u : "https://$(hostname -f):10002" |  tee /tmp/curl-hive.txt
```

if curl cmd shows the output of `use any-database-name`

cat /tmp/curl-hive.txt | grep hive -a2
this means spnego is working fine.. We need to check on Browser side.

If it fails or does not show expected outputs, please share us below details.

```bash
export HIVESERVER2_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*hive_on_tez-HIVESERVER2 | tail -1)

tar -cvzf hive.tar.gz $HIVESERVER2_PROCESS_DIR  /tmp/curl-hive.txt /etc/krb5.conf /tmp/nslookup.txt
```
attach hive.tar.gz

2. Regarding browser:

Please share us the klist output from machine where you are trying to access HS2 WebUI.

Goto Firefox browser. make sure below setting are set.

Open Firefox, type about:config in URL and hit enter Search for and change below parameters

```bash
network.negotiate-auth.trusted-uris = .dti.co.id,dbigdatam01.dti.co.id
network.negotiate-auth.delegation-uris = .dti.co.id,dbigdatam01.dti.co.id
network.negotiate-auth.using-native-gsslib = false
network.auth.use-sspi = false
network.negotiate-auth.allow-non-fqdn = true
```
Once above settings are set, close the browser and try to access the HS2 WebUI.

If it still fails.

Please collect HAR file.

https://support.ringcentral.com/article/1043.html 

