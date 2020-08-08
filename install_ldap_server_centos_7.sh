#!/bin/bash

# Usage
# First create an encrypted password to be used as connection pass
# and pass as a parameter with the script. To create use: slappasswd

# Clean packages
sudo yum clean all
# Install openldap as service manager
yum -y install openldap-servers openldap-clients openldap-* nss-pam-ldap* php70w-ldap --skip-broken

# If no pass defined do not execute script
if [[ -z $1 ]]; then
cat << EOF
= = = = = = = = = =
You must pass a password as first parameter!
Use the command "slappasswd" to generate a password and pass as first parameter along this script
= = = = = = = = = =
EOF
        exit;
fi
# If config is not set get new one
if [ ! -f /var/lib/ldap/DB_CONFIG ]; then
    sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
fi

# Add user ldap to group
sudo chown ldap. /var/lib/ldap/DB_CONFIG

# Start and restart ldap and apache service
sudo systemctl start slapd
sudo systemctl enable slapd
sudo service httpd restart

# Increase search limits
define(){ IFS='\n' read -r -d '' ${1} || true; }
define LDAP_CONFIG << EOF
dn: cn=config
changetype: modify
replace: olcSizeLimit
olcSizeLimit: -1
EOF
echo "$LDAP_CONFIG" > increase_limits.ldif
ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f increase_limits.ldif

# Add root to LDAP Server
define LDAP_ROOT << EOF
dn: olcDatabase={0}config,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $1
EOF

# Move to tmp file because badlt support of stdin on ldap commands
echo "$LDAP_ROOT" > chrootpw.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f chrootpw.ldif

# Import basic schemas
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/core.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/openldap.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/collective.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/corba.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/duaconf.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/java.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/pmi.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/ppolicy.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/dyngroup.ldif
# Add domain to LDAP Server
define LDAP_DOMAIN << EOF
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
  read by dn.base="cn=Manager,dc=pravin,dc=com" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=pravin,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=pravin,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $1

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn="cn=Manager,dc=pravin,dc=com" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=pravin,dc=com" write by * read
EOF

# Move to tmp file because ldap support of stdin on ldap commands
echo "$LDAP_DOMAIN" > chdomain.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f chdomain.ldif



service slapd restart

define LDAP_BASE_DOMAIN << EOF
dn: dc=pravin,dc=com
objectClass: dcObject
objectClass: organization
o: pravin.com
dc: pravin


dn: ou=users,dc=pravin,dc=com
objectClass: organizationalUnit
objectClass: top
ou: users

dn: ou=groups,dc=pravin,dc=com
objectClass: organizationalUnit
objectClass: top
ou: groups
EOF

# Move to tmp file because badlt support of stdin on ldap commands
echo "$LDAP_BASE_DOMAIN" > basedomain.ldif
sudo ldapadd -x -D cn=Manager,dc=pravin,dc=com -W -f basedomain.ldif

define LDAP_FAKE_USER << EOF
dn: uid=pbhagade,ou=users,dc=pravin,dc=com
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: pbhagade
uid: pbhagade
uidNumber: 10001
gidNumber: 500
homeDirectory: /home/pbhagade
loginShell: /bin/bash
gecos: pbhagade
userPassword: Welcome
shadowLastChange: 0
shadowMax: 0
shadowWarning: 0

dn: cn=group1,ou=groups,dc=pravin,dc=com
objectClass: groupOfNames
cn: itpeople
cn: group1
description: IT security group
member: uid=pbhagade,ou=users,dc=pravin,dc=com
EOF

# ADD Fake user to GROUP LAPLACE
echo "$LDAP_FAKE_USER" > fakeuser.ldif
sudo ldapadd -x -D cn=Manager,dc=pravin,dc=com -W -f fakeuser.ldif

### INSTAL LDAPADMINi
### FOLLOW HERE http://www.server-world.info/en/note?os=CentOS_7&p=openldap&f=7
sudo yum --enablerepo=epel -y install phpldapadmin -y
