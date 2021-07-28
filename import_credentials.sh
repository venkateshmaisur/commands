cat import_credentials.sh
#!/usr/bin/env bash

# Copyright (c) 2014 Cloudera, Inc. All rights reserved.

set -e
set -x

# Explicitly add RHEL5/6 and SLES11/12 locations to path
export PATH=/usr/kerberos/bin:/usr/kerberos/sbin:/usr/lib/mit/sbin:/usr/sbin:/usr/lib/mit/bin:/usr/bin:$PATH

KEYTAB_OUT=$1
USER=$2
PASSWD=$3
KVNO=$4

# Determine if sleep is needed before echoing password.
# This is needed on Centos/RHEL 5 where ktutil doesn't
# accept password from stdin.
SLEEP=0
RHEL_FILE=/etc/redhat-release
if [ -f $RHEL_FILE ]; then
  set +e # Ignore errors in grep
  grep Tikanga $RHEL_FILE
  if [ $? -eq 0 ]; then
    SLEEP=1
  fi
  if [ $SLEEP -eq 0 ]; then
    grep 'CentOS release 5' $RHEL_FILE
    if [ $? -eq 0 ]; then
      SLEEP=1
    fi
  fi
  if [ $SLEEP -eq 0 ]; then
    grep 'Scientific Linux release 5' $RHEL_FILE
    if [ $? -eq 0 ]; then
      SLEEP=1
    fi
  fi
  set -e
fi

if [ -z "$KRB5_CONFIG" ]; then
  echo "Using system default krb5.conf path."
else
  echo "Using custom config path '$KRB5_CONFIG', contents below:"
  cat $KRB5_CONFIG
fi

# Export password to keytab
IFS=' ' read -a ENC_ARR <<< "$ENC_TYPES"
{
  for ENC in "${ENC_ARR[@]}"
  do
    echo "addent -password -p $USER -k $KVNO -e $ENC"
    if [ $SLEEP -eq 1 ]; then
      sleep 1
    fi
    echo "$PASSWD"
  done
  echo "wkt $KEYTAB_OUT"
} | ktutil

chmod 600 $KEYTAB_OUT

# Do a kinit to validate that everything works
kinit -k -t $KEYTAB_OUT $USER

# If this is not AD admin account, return from here
if [ "$AD_ADMIN" != "true" ]; then
  exit 0
fi

# With AD do a simple search to make sure everything works.
# Set properties needed for ldapsearch to work.
# Tell GSSAPI not to negotiate a security or privacy layer since
# AD doesn't support nested security or privacy layers
LDAP_CONF=`mktemp /tmp/cm_ldap.XXXXXXXX`
echo "TLS_REQCERT     never" >> $LDAP_CONF
echo "sasl_secprops   minssf=0,maxssf=0" >> $LDAP_CONF

export LDAPCONF=$LDAP_CONF

set +e # Allow failures to SASL so we can see if simple auth works
#ldapsearch -LLL -H "$AD_SERVER" -b "$DOMAIN" "userPrincipalName=$USER"
ldapsearch -LLL -H ldap://host-10-17-102-177.coe.cloudera.com:389 -b OU=kerberos,DC=coe,DC=cloudera,DC=com userPrincipalName=krbadmin@COE.CLOUDERA.COM -D krbadmin@coe.cloudera.com -w Cl0udera
if [ $? -ne 0 ]; then
  echo "ldapsearch did not work with SASL authentication. Trying with simple authentication"
  #ldapsearch -LLL -H "$AD_SERVER" -b "$DOMAIN" -x -D $USER -w $PASSWD "userPrincipalName=$USER"
  ldapsearch -LLL -H ldap://host-10-17-102-177.coe.cloudera.com:389 -b OU=kerberos,DC=coe,DC=cloudera,DC=com userPrincipalName=krbadmin@COE.CLOUDERA.COM -D krbadmin@coe.cloudera.com -w Cl0udera
  if [ $? -ne 0 ]; then
    echo "Failed to do ldapsearch."
    echo "Please make sure Active Directory configuration is correctly specified and LDAP over SSL is enabled."
    exit 1
  fi
  # Simple authentication worked. Store the password in output file.
  echo -n $PASSWD > $KEYTAB_OUT
fi
set -e
rm -f $LDAP_CONF