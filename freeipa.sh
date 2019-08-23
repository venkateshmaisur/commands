# Setup freeipa

Welcome@123
Use centos 7.3, upgrade it.

yum update

# yum install ipa-server ipa-server-dns -y
yum install -y ipa-server bind bind-dyndb-ldap bind-utils vim ipa-server-dns bindipa-server  rng-tools

systemctl start rngd
systemctl enable rngd
systemctl status rngd

systemctl start named
systemctl enable named
# ipa-server-install --setup-dns


   34  systemctl status dbus
   35  systemctl restart  dbus
   36  systemctl status dbus
   37  certmonger -S -d 10

   ipa-server-install --uninstall

Skipping synchronizing time with NTP server.
New SSSD config will be created
Configured sudoers in /etc/nsswitch.conf
Configured /etc/sssd/sssd.conf
trying https://c174-node2.squadron-labs.com/ipa/json
[try 1]: Forwarding 'schema' to json server 'https://c174-node2.squadron-labs.com/ipa/json'
trying https://c174-node2.squadron-labs.com/ipa/session/json
[try 1]: Forwarding 'ping' to json server 'https://c174-node2.squadron-labs.com/ipa/session/json'
[try 1]: Forwarding 'ca_is_enabled' to json server 'https://c174-node2.squadron-labs.com/ipa/session/json'
Systemwide CA database updated.
Adding SSH public key from /etc/ssh/ssh_host_rsa_key.pub
Adding SSH public key from /etc/ssh/ssh_host_ecdsa_key.pub
Adding SSH public key from /etc/ssh/ssh_host_ed25519_key.pub
[try 1]: Forwarding 'host_mod' to json server 'https://c174-node2.squadron-labs.com/ipa/session/json'
SSSD enabled
Configured /etc/openldap/ldap.conf
Configured /etc/ssh/ssh_config
Configured /etc/ssh/sshd_config
Configuring squadron-labs.com as NIS domain.
Client configuration complete.
The ipa-client-install command was successful

==============================================================================
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
[root

8.8.8.8

1.168.192.in-addr.arpa.


yum install ipa-client -y


ipa-client-install --uninstall
ipa-client-install --domain=squadron-labs.com \
    --server=c274-node4.squadron-labs.com \
    --realm=SQUADRON-LABS.COM \
    --principal=admin@SQUADRON-LABS.COM \
    --enable-dns-updates
    

    ipa-client-install --domain=openstacklocal --server=pbhagade-freeipa.openstacklocal --realm=OPENSTACKLOCAL --principal=admin@OPENSTACKLOCAL --enable-dns-updates

 echo "172.26.81.236 pbhagade-freeipa.openstacklocal" >> /etc/hosts

echo "nameserver 172.25.39.166" > /etc/resolv.conf

hostnamectl set-hostname pravin.squadron-labs.com

pssh -h pssh-hosts -l root -A -i "echo "nameserver 172.26.81.236" > /etc/resolv.conf"
pssh -h pssh-hosts -l root -A -i "echo "nameserver 127.0.0.11" > /etc/resolv.conf"
pssh -h pssh-hosts -l root -A -i "yum clean all && yum update all"
ipa group-add ambari-managed-principals




136.42.25.172.in-addr.arpa.
ipa dnszone-add 0/26.100.51.198.in-addr.arpa.

Howto/DNS classless IN-ADDR.ARPA delegation

ipa dnszone-add 42.25.172.in-addr.arpa.
ipa dnszone-add 43.25.172.in-addr.arpa.

Ref: https://www.freeipa.org/page/Howto/DNS_classless_IN-ADDR.ARPA_delegation

# SetUP DNS Server:

yum install bind bind-utils -y



ipa-client-install --domain=squadron-labs.com 
--server=c274-node4.squadron-labs.com 
--realm=SQUADRON-LABS.COM 
--principal=admin@SQUADRON-LABS.COM 
--enable-dns-updates

zone "pravin.local" IN {
type master;
file "forward.pravin";
allow-update { none; };
};
zone "1.168.192.in-addr.arpa" IN {
type master;
file "reverse.pravin";
allow-update { none; };
};





For user:
uid=pravin,cn=users,cn=accounts,dc=openstacklocal

For groups:
dn: cn=support,cn=groups,cn=compat,dc=openstacklocal

ldapsearch -x -D "cn=Directory Manager" -w Welcome@123 -b "cn=users,cn=accounts,dc=openstacklocal"   "(uid=pravin)"

ldapsearch -x -D "cn=Directory Manager" -w Welcome@123 -b "cn=groups,cn=compat,dc=openstacklocal"   "(cn=support)"


echo -n | openssl s_client -connect 172.26.87.80:636 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/freeipacert.crt

#ldapsearch -h 172.26.87.80 -p 636 -D "cn=Directory Manager" -w Welcome@123 -b "cn=users,cn=accounts,dc=openstacklocal"
Does not work


cat /etc/openldap/ldap.conf
SASL_NOCANON	on
URI ldaps://pbhagade-freeipa.openstacklocal
BASE dc=openstacklocal
TLS_CACERT /etc/ipa/ca.crt

[root@pbhagade-freeipa ~]# cat /etc/ipa/ca.crt
-----BEGIN CERTIFICATE-----
MIIDlDCCAnygAwIBAgIBATANBgkqhkiG9w0BAQsFADA5MRcwFQYDVQQKDA5PUEVO
U1RBQ0tMT0NBTDEeMBwGA1UEAwwVQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTE5
MDgyMzE0MDM1MVoXDTM5MDgyMzE0MDM1MVowOTEXMBUGA1UECgwOT1BFTlNUQUNL
TE9DQUwxHjAcBgNVBAMMFUNlcnRpZmljYXRlIEF1dGhvcml0eTCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBAMo/PGPrvv8GRGiLdqjPz1UX7E2oOgmwloI0
Ma2uAzIdsBnqoDE6iht+qQmGDSelZZAMRSYvUu7j9JK1D/MgwP78csCyk4RqxXki
1Ftsb2+cO28K7KsxqL9nrcKBdXalM85JlDJXUmKi0BEfzmnVlnjlAV1xf1OpnNZl
ZBmTXTmMr1/BUmA3EDLyu0HeKlP5kt45YAwvicc/KuatXSnPoBEUFYu/E2b1ScUa
yugh2BcQxpwsdtnbrmmh7Fv5iTVhIWUK/w5QnfVawtLSmfU9//e5Fk6ajWAFkMV1
3oUcrMotkh3gYnNJG2pl9OaIQMCdeX63UVlFFh9hwp7sPbIPfB8CAwEAAaOBpjCB
ozAfBgNVHSMEGDAWgBQO45YRux789h+XRnNF9yxqA2KxNzAPBgNVHRMBAf8EBTAD
AQH/MA4GA1UdDwEB/wQEAwIBxjAdBgNVHQ4EFgQUDuOWEbse/PYfl0ZzRfcsagNi
sTcwQAYIKwYBBQUHAQEENDAyMDAGCCsGAQUFBzABhiRodHRwOi8vaXBhLWNhLm9w
ZW5zdGFja2xvY2FsL2NhL29jc3AwDQYJKoZIhvcNAQELBQADggEBAIpiVwaUYeuZ
umA71+bBC5+q7vNCUtUK8zbuAtS8xT+/k1HjRcBfwvYm2P8T+kmANH+GRyMAC0ns
8XCc84uuUygFgzpkD6qX5oi9c85r5QFOG0L2Mv5PiSICSotFqQ7tEY7PqAr31yln
4nUsDpx4+X8aEzerd9dqFMb1b+7uzQgQZqFgW3/1ORhvOGx9FHkwm9OSCtAw8z06
dAPPbkA7L0iztnqUZ0r7Lr3JWTmr2OUqtXgvGtmJXl+cEZquikg5KgaigaXgG3vp
5jaVlBAMEL7DUdJF9d+m8pLQKbTKSqZtUai6KuGtbm0OSEC1bzLWYP8zacXuR5eq
EbADqTXRkY8=
-----END CERTIFICATE-----


