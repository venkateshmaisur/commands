#/bin/bash

## wget https://raw.githubusercontent.com/bhagadepravin/commands/master/sssd.sh && chmod +x sssd.sh && ./sssd.sh
## Update the Krb5.conf accordingly
#[realms]
# SUPPORT.COM = {
# admin_server = sme-2012-ad.support.com
# kdc = sme-2012-ad.support.com
# }

AD_USER="test1"
AD_DOMAIN="support.com"
AD_DC="sme-2012-ad.support.com"
AD_ROOT="dc=support,dc=com"
AD_OU="dc=support,dc=com"
AD_REALM=${AD_DOMAIN^^}

yum clean all -q && yum update all -q
yum -y install epel-release sssd oddjob-mkhomedir authconfig sssd-krb5 sssd-ad sssd-tools adcli -q krb5-libs krb5-workstation
echo hadoop12345! | kinit test1@SUPPORT.COM
adcli join -v --domain-controller=${AD_DC} --domain-ou="${AD_OU}" --login-ccache="/tmp/krb5cc_0" --login-user="${AD_USER}" -v --show-details
sudo tee /etc/sssd/sssd.conf > /dev/null <<EOF
[sssd]
## master & data nodes only require nss. Edge nodes require pam.
services = nss, pam, ssh, autofs, pac
config_file_version = 2
domains = ${AD_REALM}
override_space = _
[domain/${AD_REALM}]	
id_provider = ad
ad_server = ${AD_DC}
#ad_server = ad01, ad02, ad03
#ad_backup_server = ad-backup01, 02, 03
auth_provider = ad
chpass_provider = ad
access_provider = ad
#enumerate = False
enumerate = False
krb5_realm = ${AD_REALM}
ldap_schema = ad
ldap_id_mapping = True
cache_credentials = True
ldap_access_order = expire
ldap_account_expire_policy = ad
ldap_force_upper_case_realm = true
fallback_homedir = /home/%d/%u
default_shell = /bin/false
ldap_referrals = false
#ldap_enumeration_refresh_timeout = 300 #Default
[nss]
memcache_timeout = 3600
override_shell = /bin/bash
EOF
chmod 0600 /etc/sssd/sssd.conf
service sssd restart
authconfig --enablesssd --enablesssdauth --enablemkhomedir --enablelocauthorize --update
chkconfig oddjobd on
service oddjobd restart
chkconfig sssd on
service sssd restart



# For Ranger to use nss Please enable "enumerate = True"
# By default it would take 5 mins to fetch the user locally, it may be based on 
#ldap_enumeration_refresh_timeout (integer)
#Specifies how many seconds SSSD has to wait before refreshing its cache of enumerated records.
#Default: 300

#Also, looks likes minimum is 1 min.
#Few ref article regarding performance:
#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/deployment_guide/configuring_services
#https://access.redhat.com/solutions/3352181
#https://access.redhat.com/articles/2133801
