# Setup Hive LDAP and troubleshooting

##### Configuring HiveServer2 for LDAP and for LDAP over SSL

https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.5/bk_data-access/content/ch02s05s02.html

```sh
hive.server2.authentication = LDAP
hive.server2.authentication.ldap.url = ldap://hulk1.openstacklocal:33389
hive.server2.authentication.ldap.baseDN=ou=people,dc=pravin,dc=com
```

`ldapsearch  -h <ldap-server-hostname> -p 389 -D "cn=Manager,dc=pravin,dc=com" -W -b "dc=pravin,dc=com"`


# AD
```sh
hive.server2.authentication.ldap.url=ldap://ad-21115.lab.hortonworks.net
hive.server2.authentication.ldap.baseDN=empty
hive.server2.authentication.ldap.Domain=lab.hortonworks.net
```

`beeline -u 'jdbc:hive2://HS2-server:10001/default;transportMode=http;httpPath=cliservice' -n username -p password`



# ERROR's

```
Caused by: javax.naming.AuthenticationException: [LDAP: error code 49 - 80090308: LdapErr: DSID-0C0903D9, comment: AcceptSecurityContext error, data 52e, v2580] 
```

--> Verify hive.server2.authentication.ldap.baseDN and hive.server2.authentication.ldap.Domain

