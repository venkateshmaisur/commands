```bash


+++++++++++++++++++++++++++++++++++++
Login into Queue Manager Node

openssl s_client -connect queue-manager:8082 -showcerts > /tmp/queuemangercert.txt
openssl s_client -connect yarn-hostname:8090 -showcerts > /tmp/yarncert.txt
openssl s_client -connect <cm-hostname>:port -showcerts > /tmp/cmcert.txt

Check TLS connectivity:
# get the truststore path and password:

export QUEUEMANAGER_WEBAPP_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*QUEUEMANAGER_WEBAPP| tail -1)
grep CLIENT_TRUSTSTORE_PASSWORD $QUEUEMANAGER_WEBAPP_PROCESS_DIR/proc.json
grep queuemanager.webapp.ssl.truststore.location $QUEUEMANAGER_WEBAPP_PROCESS_DIR/conf/webapp.properties

 Check TLS connectivity for queuemanager
# openssl s_client -verify 100 -showcerts -CAfile <($JAVA_HOME/bin/keytool -list -rfc -keystore <path to truststore> -storepass <truststore_pass>) -connect <queuemanager>:8082 > /tmp/queuemanagertls.txt

Check TLS connectivity for CM
# openssl s_client -verify 100 -showcerts -CAfile <($JAVA_HOME/bin/keytool -list -rfc -keystore <path to truststore> -storepass <truststore_pass>) -connect <clouderamanager>:7183 > /tmp/clouderamanagertls.txt

Check TLS connectivity for yarn
# openssl s_client -verify 100 -showcerts -CAfile <($JAVA_HOME/bin/keytool -list -rfc -keystore <path to truststore> -storepass <truststore_pass>) -connect yarn-resourcemanager:8090 > /tmp/yarntls.txt


Navigate clusters -> queuemanager -> configuration -> search bar type -> YARN Queue Manager Webapp Environment Advanced Configuration Snippet (Safety Valve)
add the below to the key
JAVA_TOOL_OPTIONS = -Djavax.net.debug=ssl

Restart queuemanager

export QUEUEMANAGER_WEBAPP_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*QUEUEMANAGER_WEBAPP| tail -1)
tar -cvzf queuemanager-may-18.tar.gz  $QUEUEMANAGER_WEBAPP_PROCESS_DIR /var/lib/cloudera-scm-agent/agent-cert/ /etc/cloudera-scm-agent/config.ini /tmp/queuemangercert.txt /tmp/yarncert.txt /tmp/cmcert.txt /tmp/yarncert.txt /tmp/yarntls.txt /tmp/clouderamanagertls.txt /tmp/queuemanagertls.txt


attach queuemanager-may-18.tar.gz 

+++++++++++++++++++++++++++++++++++++
Now Login into Cloudera Manager Node:

ps aux | grep com.cloudera.server.cmf.Main > /tmp/cm-process.txt

tar -cvzf cm-may-18.tar.gz /var/lib/cloudera-scm-agent/agent-cert/ /etc/default/cloudera-scm-server /etc/cloudera-scm-agent/config.ini

Uploaded Latest bundle to the case.

 
Execute below command and restart queuemanager to get start up logs:
$ tailf /var/log/yarn/queuemanager/queuemanager-webapp.log   | tee /tmp/startup.log
```
