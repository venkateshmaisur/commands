 - [x] Solr Commands https://bhagadepravin.github.io/commands/solr
 - [x] Ambari Commands https://bhagadepravin.github.io/commands/ambari
 - [x] Ranger Commands https://bhagadepravin.github.io/commands/ranger
 - [x] Haproxy Commands https://bhagadepravin.github.io/commands/haproxy-tcp-mode
 - [X] SSL Commands https://bhagadepravin.github.io/commands/ssl
 - [X] Kafka Commands https://bhagadepravin.github.io/commands/kafka
 - [] Useful Commands https://bhagadepravin.github.io/commands
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
watch -n 1 'netstat -anp | grep `cat /var/run/knox/gateway.pid` | grep ESTABLISHED | wc -l' 
{GATEWAY_HOME}/bin/knoxcli.sh create-alias ldcSystemPassword --cluster hdp --value hadoop
ldapsearch -h <ldap-hostname> -p <port> -D <bind-dn> -w <bind_DN_password> -b <base_search> "(cn=<username>)"
```

```
env GZIP=-9 tar czhvf ./knox_all_conf_$(hostname)_$(date +"%Y%m%d%H%M%S").tgz /usr/hdp/current/knox-server/conf/ /etc/ranger/*/policycache /usr/hdp/current/knox-server/data/deployments/ /var/log/knox/gateway.log /var/log/knox/gateway-audit.log 2>/dev/null
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

## MyISAM to InnoDB using command:
alter table ranger.table_name Engine = InnoDB;

```sql
[ERROR] /usr/libexec/mysqld: Table './ranger/x_auth_sess' is marked as crashed and should be repaired 
mysql> repair table x_auth_sess; 
```

## tcpdump commands for ldap troubleshooting
```
tcpdump -i any -s 10000 -A 'host <ranger host> and port 9292'
tcpdump -ni any -nvvvXSs 4096 host localhost and port 389 -w tcpdump.pcap
tcpdump -ni any -nvvvXSs 4096 host localhost and port 8443 -w knox.pcap
tcpdump -ni any -nvvvXSs 4096 host sme-2012-ad.support.com and port 636 -w tcpdump.pcap
tcpdump -ni any -nvvvXSs 4096 host <host> and port 636 -w tcpdump.pcap

tcpdump -i eth0 -w /var/tmp/ldap3.pcap port 389 &
tcpdump -i any -w /var/tmp/ldap3.pcap port 389 &

tshark -r /var/tmp/ldap.pcap
tshark -r /var/tmp/ldap.pcap -V
tshark -r /var/tmp/ldap.pcap  -frame == 7

-i interface (an interface argument of ‘‘any’’)
-n Don’t convert host addresses to names.
-vvv Even more verbose output
-X When parsing and printing, in addition to printing the headers of each packet, print the data of each packet (minus its link level header) in hex and ASCII. This is very
-S Print absolute, rather than relative, TCP sequence numbers.
-s Snarf snaplen bytes of data from each packet rather than the default of 65535 bytes.
```


## Hive beeline command
```
beeline -u "jdbc:hive2://KnoxserverInternalHostName:8443/;ssl=true;transportMode=http;httpPath=gateway/default/hive" -n <username> -p <password>
```

## OS cmds

```shell
ps auxwww > /tmp/ps_$(hostname)_$(date +'%Y%m%d%H%M%S').out 2>&1 
free -m > /tmp/free_$(hostname)_$(date +'%Y%m%d%H%M%S').out 2>&1 
top -b -c -n 1 > /tmp/top_$(hostname)_$(date +'%Y%m%d%H%M%S').out 2>&1 

( date;set -x;hostname -A;uname -a;top -b -n 1 -c;ps auxwwwf;netstat -aopen;ifconfig;iptables -t nat -nL;cat /proc/meminfo;df -h;mount;vmstat -d; ls -l /etc/security/keytabs/ ) &> /tmp/os_cmds.out; tar czhvf ./hdp_all_conf_$(hostname)_$(date +"%Y%m%d%H%M%S").tgz /usr/hdp/current/*/conf /etc/{ams,ambari}-* /etc/ranger/*/policycache /etc/hosts /etc/krb5.conf /tmp/os_cmds.out 2>/dev/null

( date;set -x;hostname -A;uname -a;top -b -n 1 -c;ps auxwwwf;netstat -aopen;ifconfig;iptables -t nat -nL;cat /proc/meminfo;df -h;mount;vmstat -d;vmstat 1 5 ) &> /tmp/os_cmds.out

env GZIP=-9 tar cvzf /tmp/ranger_admin.tar.gz /etc/ranger/admin/conf/* /var/log/ranger/admin/xa_portal.log /var/log/ranger/admin/catalina.out /tmp/os_cmds.out

( date;set -x;hostname -A;uptime;last reboot;df -h; mount;free -g ) &> /tmp/os_cmds.out  ; env GZIP=-9 tar czhvf ./hdp_$(hostname)_$(date +"%Y%m%d%H%M%S").tgz /var/log/messages

```

## Kerberos JCE verification

```bash
grep -i java_home /etc/hadoop/conf/hadoop-env.sh
JAVA_HOME=/usr/jdk64/jdk1.8.0_77
export JAVA_HOME=/usr/jdk64/jdk1.8.0_77
source /etc/hadoop/conf/hadoop-env.sh && zipgrep CryptoAllPermission $JAVA_HOME/jre/lib/security/local_policy.jar
source /etc/hadoop/conf/hadoop-env.sh && zipgrep CryptoAllPermission $JAVA_HOME/jre/lib/security/US_export_policy.jar
```

## delete alias from keystore
`keytool -delete -noprompt -alias ${cert.alias} -keystore ${keystore.file} -storepass ${keystore.pass}`

## Hadoop debug
```sh
export HADOOP_ROOT_LOGGER=DEBUG,console
export HADOOP_OPTS="-Dsun.security.krb5.debug=true ${HADOOP_OPTS}"
```

## network tunning ####
```
lease tune below parameters and then test the Alteryx job. 
10 Gbits - Socket tunings. 

1. /etc/sysctl.conf 
net.core.rmem_max = 134217728 
net.core.wmem_max = 134217728 
net.ipv4.tcp_rmem = 4096 65536 134217728 
net.ipv4.tcp_wmem = 4096 65536 134217728 
net.core.netdev_max_backlog = 250000 
net.core.somaxconn = 4096 
net.ipv4.tcp_sack = 1 
net.ipv4.tcp_max_syn_backlog = 8192 
net.ipv4.tcp_syncookies = 1 

2. Reflect the above settings. 
#sysctl -p 

3. Increase the MTU value. 
/etc/sysconfig/network-scripts/<interface> 
MTU=9000 

4. Increase the txqueuelen. 
# ifconfig <interface> txqueuelen 10000 
```

## nfs gateway
```
hostname:/ on /HDFS_ROOT type nfs (rw,relatime,sync,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=ip-address,mountvers=3,mountport=4242,mountproto=tcp,local_lock=all,addr=ip-address)
```

