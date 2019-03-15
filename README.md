 - [x] Solr Commands https://bhagadepravin.github.io/commands/solr
 - [x] Ambari Commands https://bhagadepravin.github.io/commands/ambari
 - [x] Ranger Commands https://bhagadepravin.github.io/commands/ranger
 - [x] Haproxy Commands https://bhagadepravin.github.io/commands/haproxy-tcp-mode
 - [X] SSL Commands https://bhagadepravin.github.io/commands/ssl
 - [X] Kafka Commands https://bhagadepravin.github.io/commands/kafka
 - [] Useful Commands https://bhagadepravin.github.io/commands/commands
 - [] 


```bash
env GZIP=-9 tar cvzf ambari-log.tar.gz <log file>
tshark -r /var/tmp/ldap.pcap -R frame.number==7 -V
/usr/bin/ambari-python-wrap -c 'import sys;print (sys.version)'
python -c 'import socket;print socket.getfqdn()'
find / -executable -name java
echo stat |nc localhost 2181 
openssl s_client -showcerts -connect hostname:port
echo -n | openssl s_client -connect ${knoxserver}:8443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/knoxcert.crt



```

```java
JAVA_HOME=/usr/jdk64/jdk1.8.0_112/
export PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME=/usr/jdk64/jdk1.8.0_112/
```

## SSL Poke Test
```java
wget https://confluence.atlassian.com/download/attachments/117455/SSLPoke.java
javac SSLPoke.java
java SSLPoke -Djavax.net.debug=ssl SSLPoke sme-2012-ad.support.com 636
java SSLPoke hostname port
```

## LDAP test
```java
https://github.com/hajimeo/samples/blob/master/java/LDAPTest.java

java -Djavax.net.debug=ssl,keymanager -Djavax.net.ssl.trustStore=/path/to/truststore.jks LDAPTest "ldap://ad.your-server.com:389" "dc=ad,dc=my-domain,dc=com" myLdapUsername myLdapPassword

Please enable certpath debugging (java -Djava.security.debug=certpath) 
```
