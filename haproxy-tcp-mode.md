# Haproxy setup

************************************************************************************* 
* Step 1: Environment Information: 

```sh
hn3.hwxblr.com(Load Balancer) --> 10.0.1.4 
hn1.hwxblr.com(Ranger Admin) --> 10.0.1.3 
hn2.hwxblr.com(Ranger Admin) --> 10.0.1.5 
```

* Step 2: On HAProxy Server 
Before Installing HAProxy on the server we need to install epel repository on our system depending on our operating system version using following command. 

```sh
CentOS/RHEL 5 , 32 bit: 
 rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm 
CentOS/RHEL 5 , 64 bit: 
 rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm 
CentOS/RHEL 6 , 32 bit: 
 rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm 
CentOS/RHEL 6 , 64 bit: 
 rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm 
```

* Step 3: Install HAProxy using Yum. 

`yum install haproxy `

* Step 4: Now we will configure HAProxy 
```bash
[root@hn3 ~]# cat /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Example configuration for a possible web application. See the
# full configuration options online.
#
# http://haproxy.1wt.eu/download/1.4/doc/configuration.txt
#
#---------------------------------------------------------------------
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
# to have these messages end up in /var/log/haproxy.log you will
# need to:
#
# 1) configure syslog to accept network log events. This is done
# by adding the '-r' option to the SYSLOGD_OPTIONS in
# /etc/sysconfig/syslog
#
# 2) configure local2 events to go to the /var/log/haproxy.log
# file. A line like the following can be added to
# /etc/sysconfig/syslog
#
# local2.* /var/log/haproxy.log
#
log 127.0.0.1 local2
chroot /var/lib/haproxy
pidfile /var/run/haproxy.pid
maxconn 45000
user haproxy
group haproxy
daemon
# turn on stats unix socket
stats socket /var/lib/haproxy/stats
#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
mode http
log global
option httplog
option dontlognull
option http-server-close
option forwardfor except 127.0.0.0/8
option redispatch
retries 3
timeout http-request 10s
timeout queue 1000s
timeout connect 86400000
timeout client 86400000
timeout server 86400000
timeout http-keep-alive 10s
timeout check 10s
maxconn 3000
#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
#frontend main *:5000
# acl url_static path_beg -i /static /images /javascript /stylesheets
# acl url_static path_end -i .jpg .gif .png .css .js
# use_backend static if url_static
# default_backend app
frontend main
bind 10.0.1.4:6080
default_backend ranger
#---------------------------------------------------------------------
# static backend for serving up images, stylesheets and such
#---------------------------------------------------------------------
backend static
balance roundrobin
server static 127.0.0.1:4331 check
#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend ranger
balance roundrobin
server hn1.hwxblr.com 10.0.1.3:6080 check
server hn2.hwxblr.com 10.0.1.5:6080 check
```

Please refer for brief documentation before editing this file : https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Load_Balancer_Administration/ch-haproxy-setup-VSA.html 

* Step 5: Start the HAProxy service 
`service haproxy start` // STARTING HAPROXY 

* Step 6: To make the HAProxy service persist through reboots 
`chkconfig haproxy on`


##### Logging for ha proxy

`yum install rsyslog -y`
```shell
╰─➤ add /etc/rsyslog.d/haproxy.conf 130 ↵
local2.* /var/log/haproxy.log
```
```shell
add /etc/rsyslog.conf
$ModLoad imudp
$UDPServerRun 514
$UDPServerAddress 127.0.0.1
```
`/etc/init.d/rsyslog restart`
`/etc/init.d/haproxy restart`


##### Get the private key from KNOX server 
`keytool -importkeystore -srckeystore gateway.jks -srcstorepass admin -srckeypass admin -destkeystore keystore.p12 -deststoretype PKCS12 -srcalias gateway-identity -deststorepass Welcome -destkeypass Welcome`
`openssl pkcs12 -in keystore.p12 -passin pass:Welcome -nocerts -out hostname.key -passout pass:Welcome`
`openssl rsa -in hostname.key -out server.key `

##### add knox2 certificate into haproxy.cfg
```    
cat cert1.pem key1.pem > haproxy1.pem 
cat cert2.pem key2.pem > haproxy2.pem 
```
`bind 0.0.0.0:443 ssl crt /certs/haproxy1.pem crt /certs/haproxy2.pem`

##### Enable rsyslog for haproxy to check the request 
```bash
╰─➤add /etc/rsyslog.conf 
$ModLoad imudp 
$UDPServerRun 514 
$UDPServerAddress 127.0.0.1 
```
```sh
╰─➤ add /etc/rsyslog.d/haproxy.conf 
local2.* /var/log/haproxy.log 
```
`service rsyslog restart` 
`service haproxy restart`

`tailf /var/log/haproxy.log`
