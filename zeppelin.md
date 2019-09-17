# Zepplein Cheats

su zeppelin
/usr/hdp/current/zeppelin-server/bin/zeppelin-daemon.sh stop

## JDBC Interpreter



```mysql
%jdbc(hive)
CREATE DATABASE books;
USE books;
CREATE TABLE authors (id INT, name VARCHAR(20), email VARCHAR(20));
SHOW TABLES;
INSERT INTO authors (id,name,email) VALUES(1,"Vivek","xuz@abc.com");
INSERT INTO authors (id,name,email) VALUES(2,"Priya","p@gmail.com");
INSERT INTO authors (id,name,email) VALUES(3,"Tom","tom@yahoo.com");
SELECT * FROM authors;
```

## Livy Interpreter

```
%livy
sc.version
```
https://community.cloudera.com/t5/Community-Articles/How-to-configure-zeppelin-livy-interpreter-for-secure-HDP/ta-p/249267


## AD authentication

https://community.hortonworks.com/articles/70392/how-to-configure-zeppelin-for-active-directory-use.html

```sh
1. From Ambari Dashboard, navigate to Zeppelin Notebook > Configs > Advanced zeppelin-config section.
zeppelin.anonymous.allowed = false

2. On the same Ambari page, navigate to next section called "Advanced zeppelin-env".

Zeppelin

activeDirectoryRealm = org.apache.zeppelin.server.ActiveDirectoryGroupRealm 
activeDirectoryRealm.systemUsername = CN=Pravin Bhagade,OU=Support,OU=APAC,OU=hortonworks,DC=support,DC=com
activeDirectoryRealm.systemPassword = hadoop12345!
#activeDirectoryRealm.hadoopSecurityCredentialPath = jceks://file/etc/zeppelin/conf/zeppelin.jceks
activeDirectoryRealm.searchBase = DC=support,DC=com
activeDirectoryRealm.url = ldaps://sme-2012-ad.support.com:636
activeDirectoryRealm.authorizationCachingEnabled = false

sessionManager = org.apache.shiro.web.session.mgt.DefaultWebSessionManager
securityManager.sessionManager = $sessionManager
securityManager.realms = $activeDirectoryRealm
# 86,400,000 milliseconds = 24 hour
securityManager.sessionManager.globalSessionTimeout = 86400000
shiro.loginUrl = /api/login

## LDAPS

If LDAP is using a self-signed certificate, import the certificate into the truststore of JVM running Zeppelin:

echo -n | openssl s_client –connect sme-2012-ad.support.com:636 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/examplecert.crt  
keytool –import -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit -noprompt -alias mycert -file /tmp/examplecert.crt
```

## AD role mapping 

```sh
[users] 
# List of users with their password allowed to access Zeppelin. 
# To use a different strategy (LDAP / Database / ...) check the shiro doc at http://shiro.apache.org/configuration.html#Configuration-INISections 
admin = password1, admin 
#user1 = password2, role1, role2 
#user2 = password3, role3 
#user3 = password4, role2 
# Sample LDAP configuration, for user Authentication, currently tested for single Realm 
[main] 

### org.apache.zeppelin.realm.ActiveDirectoryGroupRealm
activeDirectoryRealm = org.apache.zeppelin.server.ActiveDirectoryGroupRealm 
activeDirectoryRealm.systemUsername = <UserName> 
activeDirectoryRealm.systemPassword = <Password> 
activeDirectoryRealm.searchBase = OU=US-TEST,OU=Accounts,OU=NBCU,OU=TV-Companies,OU=Media,DC=raghav,DC=com 
activeDirectoryRealm.url = ldap://192.168.56.120:389 
activeDirectoryRealm.principalSuffix = @raghav.com 
activeDirectoryRealm.groupRolesMap = "CN=APL-BigData_AdminTestUser,OU=AppGroups,OU=Groups,OU=ITInfrastructure,DC=raghav,DC=com":"admin" 
activeDirectoryRealm.authorizationCachingEnabled = true 
sessionManager = org.apache.shiro.web.session.mgt.DefaultWebSessionManager 
cacheManager = org.apache.shiro.cache.MemoryConstrainedCacheManager 
securityManager.cacheManager = $cacheManager 
securityManager.sessionManager = $sessionManager 
securityManager.sessionManager.globalSessionTimeout = 86400000 
shiro.loginUrl = /api/login 

[roles] 
admin = * 


[urls] 
# This section is used for url-based security. 
# You can secure interpreter, configuration and credential information by urls. Comment or uncomment the below urls that you want to hide. 
# anon means the access is anonymous. 
# authc means Form based Auth Security 
# To enfore security, comment the line below and uncomment the next one 
/api/version = anon 
/api/interpreter/** = authc, roles[admin] 
/api/configurations/** = authc, roles[admin] 
/api/credential/** = authc, roles[admin] 
#/** = anon 
/** = authc 

Here I have a "admin" account which is not AD and other user account which are AD. 

I assigned the role "admin" to the account admin, to all the users in the AD group "CN=APL-BigData_AdminTestUser" with groupRolesMap. 

And in urls I set the URL /api/interpreter/** to need authenitcation and the authenticated account should be admin role to access the interpreter config. 

With this config all the users with admin roles (AD group members, and "admin" account) should be able to see and edit interpreter config. 

```
##### Example
```bash
activeDirectoryRealm = org.apache.zeppelin.realm.ActiveDirectoryGroupRealm 
activeDirectoryRealm.systemUsername = test1 
activeDirectoryRealm.systemPassword = hadoop12345! 
activeDirectoryRealm.searchBase = ou=hortonworks,dc=support,dc=com 
activeDirectoryRealm.url = ldap://172.26.126.78:389 
activeDirectoryRealm.principalSuffix = @support.com 
activeDirectoryRealm.groupRolesMap = "CN=support,OU=groups,OU=hortonworks,DC=support,DC=com":"admin" 
activeDirectoryRealm.authorizationCachingEnabled = true 
```





