# Setup freeipa

Used centos 7.3, upgrade it.

```sh
yum update
yum install -y ipa-server bind bind-dyndb-ldap bind-utils vim ipa-server-dns bindipa-server  rng-tools
systemctl start rngd
systemctl enable rngd
systemctl status rngd
systemctl start named
systemctl enable named
systemctl restart  dbus
```
##### Install Free IPA
```
ipa-server-install --setup-dns
```

##### Uninstall Free IPA
```
ipa-server-install --uninstall
```

```bash
Setup complete

Next steps:
	1. You must make sure these network ports are open:
		TCP Ports:
		  * 80, 443: HTTP/HTTPS
		  * 389, 636: LDAP/LDAPS
		  * 88, 464: kerberos
		  * 53: bind
		UDP Ports:
		  * 88, 464: kerberos
		  * 53: bind
		  * 123: ntp

	2. You can now obtain a kerberos ticket using the command: 'kinit admin'
	   This ticket will allow you to use the IPA tools (e.g., ipa user-add)
	   and the web user interface.

Be sure to back up the CA certificates stored in /root/cacert.p12
These files are required to create replicas. The password for these
files is the Directory Manager password
```


## Run FreeIPA Server in Docker
```bash
# If Selinux is enabled
# apt install policycoreutils -y
# setsebool -P container_manage_cgroup 1
mkdir -p /var/lib/ipa-data

# Enable Port forwading
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

git clone https://github.com/freeipa/freeipa-container.git
cd freeipa-container
docker build -t freeipa-server -f Dockerfile.centos-7 .
docker images

# docker run  -e IPA_SERVER_IP=<...ip...> --name freeipa-server -ti -h <HOSTNAME> -p 53:53/udp -p 53:53 -p 80:80 -p 443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 -p 88:88/udp -p 464:464/udp -p 123:123/udp --sysctl net.ipv6.conf.all.disable_ipv6=0 -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/lib/ipa-data1:/data:Z -e PASSWORD=admin-password freeipa-server ipa-server-install -U -r <REALM> --ds-password=admin-password --admin-password=admin-password --domain=<DOMAIN> --no-ntp 

docker run  -e IPA_SERVER_IP=10.90.6.198 --name freeipa-server-adsre3 -ti -h mstr1.odp.u18.adsre \
-p 53:53/udp -p 53:53 -p 80:80 -p 443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 -p 88:88/udp -p 464:464/udp -p 123:123/udp \
--sysctl net.ipv6.conf.all.disable_ipv6=0 -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/lib/ipa-data1:/data:Z \
-e PASSWORD=admin-password freeipa-server ipa-server-install -U -r ADSRE.ACCELO \
--ds-password=admin-password --admin-password=admin-password --domain=u18.adsre --no-ntp 

```



```
##### Update hostname
```
echo "172.26.87.80	     pbhagade-freeipa.openstacklocal" >> /etc/hosts
echo "nameserver 172.26.87.80" >> /etc/resolv.conf
echo "172.26.87.78   dataplane.openstacklocal" >> /etc/hosts
```

# Install Free client
```sh
yum install ipa-client -y

ipa-client-install --uninstall
ipa-client-install --domain=squadron-labs.com \
    --server=c274-node4.squadron-labs.com \
    --realm=SQUADRON-LABS.COM \
    --principal=admin@SQUADRON-LABS.COM \
    --enable-dns-updates
    
ipa-client-install --domain=openstacklocal --server=pbhagade-freeipa.openstacklocal --realm=OPENSTACKLOCAL --principal=admin@OPENSTACKLOCAL --enable-dns-updates
```

```
pssh -h pssh-hosts -l root -A -i "echo "nameserver 172.26.81.236" > /etc/resolv.conf"
pssh -h pssh-hosts -l root -A -i "echo "nameserver 127.0.0.11" > /etc/resolv.conf"
pssh -h pssh-hosts -l root -A -i "yum clean all && yum update all"
ipa group-add ambari-managed-principals
```


##### DNS
```
136.42.25.172.in-addr.arpa.
ipa dnszone-add 0/26.100.51.198.in-addr.arpa.

Howto/DNS classless IN-ADDR.ARPA delegation

ipa dnszone-add 42.25.172.in-addr.arpa.
ipa dnszone-add 43.25.172.in-addr.arpa.

Ref: https://www.freeipa.org/page/Howto/DNS_classless_IN-ADDR.ARPA_delegation

# SetUP DNS Server:

yum install bind bind-utils -y
```

# Ldapsearch cmds

```sh
For user:
uid=pravin,cn=users,cn=accounts,dc=openstacklocal

For groups:
dn: cn=support,cn=groups,cn=compat,dc=openstacklocal

ldapsearch -x -D "cn=Directory Manager" -w Welcome@123 -b "cn=users,cn=accounts,dc=openstacklocal"   "(uid=pravin)"
ldapsearch -x -D "cn=Directory Manager" -w Welcome@123 -b "cn=groups,cn=compat,dc=openstacklocal"   "(cn=support)"

echo -n | openssl s_client -connect 172.26.87.80:636 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/freeipacert.crt
```

##### LDAP Setting/Atlas
```sh
ldaps://172.26.87.80:636
person
uid
cn=users,cn=accounts,dc=openstacklocal
memberUid
cn
posixGroup
cn=groups,cn=compat,dc=openstacklocal

(memberOf=cn={0},cn=groups,cn=compat,dc=openstacklocal)


+++++++ ATLAS LDAP +++++++++
atlas.authentication.method.ldap.url = ldaps://172.26.87.80:636
atlas.authentication.method.ldap.userDNpattern=uid={0},cn=users,cn=accounts,dc=openstacklocal
atlas.authentication.method.ldap.groupSearchBase=cn=groups,cn=compat,dc=openstacklocal
atlas.authentication.method.ldap.groupSearchFilter=(memberOf=cn={0},cn=groups,cn=compat,dc=openstacklocal)
atlas.authentication.method.ldap.groupRoleAttribute=cn
atlas.authentication.method.ldap.base.dn=dc=openstacklocal
atlas.authentication.method.ldap.bind.dn=cn=Directory Manager
atlas.authentication.method.ldap.bind.password=Welcome@123
atlas.authentication.method.ldap.referral=ignore
atlas.authentication.method.ldap.user.searchfilter=(uid={0})
atlas.authentication.method.ldap.default.role=ROLE_USER
```

##### keytool
```
echo -n | openssl s_client -connect 172.26.87.80:636 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/freeipacert.crt
keytool -import -file /tmp/freeipacert.crt -keystore /etc/pki/java/cacerts -alias LDAPS -storepass changeit
/usr/jdk64/jdk1.8.0_112/bin/keytool -import -file /tmp/freeipacert.crt -keystore /usr/jdk64/jdk1.8.0_112/jre/lib/security/cacerts -alias LDAPS -storepass 	changeit
```

##### Latest Ambari 2.7.4 ######

```
$ ambari-server setup-ldap \
--ldap-url=pbhagade-freeipa.openstacklocal:636  \
--ldap-user-class=person \
--ldap-user-attr=uid \
--ldap-group-class=posixGroup \
--ldap-ssl=true \
--ldap-referral="ignore" \
--ldap-group-attr=cn \
--ldap-member-attr=memberUid \
--ldap-dn=dn \
--ldap-base-dn=cn=users,cn=accounts,dc=openstacklocal \
--ldap-bind-anonym=false \
--ldap-manager-dn="cn=Directory Manager" \
--ldap-manager-password=Welcome@123 \
--ldap-save-settings \
--ldap-sync-username-collisions-behavior=convert  \
--ldap-force-setup \
--ldap-force-lowercase-usernames=true \
--ldap-pagination-enabled=false \
--ambari-admin-username=admin \
--ambari-admin-password=pbhagade \
--truststore-type=jks \
--truststore-path=/etc/pki/java/cacerts \
--truststore-password=changeit \
--ldap-secondary-host="" \
--ldap-secondary-port=0 \
--ldap-sync-disable-endpoint-identification=true

# ambari-server restart
# ambari-server sync-ldap --all

ambari=> UPDATE users SET user_type = 'LOCAL' WHERE user_id = '1';
UPDATE 1
ambari=> \q

```
