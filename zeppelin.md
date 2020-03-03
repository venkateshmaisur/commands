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

### Setup HWC with livy interpreter
https://github.com/bhagadepravin/commands/blob/master/spark.md#7-integrate-hwc-in-livy2-interpreter-in-zeppelin

## Python Interpreter

```
# Login into Zepplein node:

/usr/hdp/2.6.5.0-292/zeppelin/bin/install-interpreter.sh -n python

Install python(org.apache.zeppelin:zeppelin-python:0.7.0) to /usr/hdp/2.6.5.0-292/zeppelin/interpreter/python ...
Interpreter python installed under /usr/hdp/2.6.5.0-292/zeppelin/interpreter/python.

1. Restart Zeppelin
2. Create interpreter setting in 'Interpreter' menu on Zeppelin GUI
3. Then you can bind the interpreter on your note

officially we dont support Python Interpreter, you can use 
```

```sh
# su - zeppelin 
# cd /usr/hdp/current/zeppelin-server/bin/ 
# ./install-interpreter.sh -n python 

After installing python it was not showing in interpreter group so we added the blow property in 
zeppelin.interpreters in Advance zeppelin configs 

" org.apache.zeppelin.python.PythonInterpreter " 

Then after restarting zeppelin we were able to see python in interpreter groups and we created Python interpreter with python as interpreter group. 
```

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

## LDAP Authentication

```
[users]
# List of users with their password allowed to access Zeppelin.
# To use a different strategy (LDAP / Database / ...) check the shiro doc at http://shiro.apache.org/configuration.html#Configuration-INISections
admin = admin, admin
#user1 = password2, role1, role2
#user2 = password3, role3
#user3 = password4, role2
# Sample LDAP configuration, for user Authentication, currently tested for single Realm

[main]

ldapRealm = org.apache.zeppelin.server.LdapGroupRealm
ldapRealm.contextFactory.environment[ldap.searchBase] = dc=raghav,dc=com
ldapRealm.contextFactory.url = ldap://hdp1.raghav.com:389
ldapRealm.userDnTemplate = uid={0},ou=users,dc=raghav,dc=com
ldapRealm.contextFactory.authenticationMechanism = SIMPLE
ldapRealm.contextFactory.systemUsername = cn=Manager,dc=raghav,dc=com
ldapRealm.contextFactory.systemPassword = <Password>

sessionManager = org.apache.shiro.web.session.mgt.DefaultWebSessionManager
cacheManager = org.apache.shiro.cache.MemoryConstrainedCacheManager
securityManager.realm = $ldapRealm
securityManager.cacheManager = $cacheManager
securityManager.sessionManager = $sessionManager
securityManager.sessionManager.globalSessionTimeout = 86400000
shiro.loginUrl = /api/login

[roles]
admin = *

###ldap Group zeppelinadmin###
zeppelinadmin = *


[urls]
# This section is used for url-based security.
# You can secure interpreter, configuration and credential information by urls. Comment or uncomment the below urls that you want to hide.
# anon means the access is anonymous.
# authc means Form based Auth Security
# To enfore security, comment the line below and uncomment the next one
/api/version = anon

#Providing access to specific url for zeppelinadmin group###
/api/interpreter/** = authc, roles[zeppelinadmin]
/api/configurations/** = authc, roles[zeppelinadmin]
/api/credential/** = authc, roles[zeppelinadmin]
#/** = anon
/** = authc
```
## LDAP rolebygroup

```bash
[main]
ldapRealm=org.apache.zeppelin.realm.LdapRealm
anyofrolesuser = org.apache.zeppelin.utils.AnyOfRolesUserAuthorizationFilter
ldapRealm.contextFactory.systemUsername =cn=Manager,dc=pravin,dc=com
ldapRealm.contextFactory.systemPassword =tender12
ldapRealm.contextFactory.authenticationMechanism=simple
ldapRealm.contextFactory.url=ldap://pbhagade-oraclemaster.openstacklocal:389
ldapRealm.authorizationEnabled=true
ldapRealm.pagingSize = 20000
ldapRealm.searchBase=dc=pravin,dc=com
ldapRealm.userSearchBase=ou=users,dc=pravin,dc=com
ldapRealm.groupSearchBase=ou=groups,dc=pravin,dc=com
ldapRealm.userObjectClass=posixAccount
ldapRealm.groupObjectClass=groupOfNames
ldapRealm.userSearchAttributeName = uid
ldapRealm.userSearchScope = subtree
ldapRealm.groupSearchScope = subtree
ldapRealm.userSearchFilter= (&(objectclass=posixAccount)(uid={0}))
ldapRealm.groupSearchFilter = (&(objectclass=groupOfNames)(cn={0}))
ldapRealm.memberAttribute = member
#ldapRealm.memberAttributeValueTemplate=(name={0})
ldapRealm.rolesByGroup = "itpeople":admin_role
# securityManager.realm = $ldapRealm #comment this authenticate both users
### A sample PAM configuration
#pamRealm=org.apache.zeppelin.realm.PamRealm
#pamRealm.service=sshd
shiro.loginUrl = /api/login
sessionManager = org.apache.shiro.web.session.mgt.DefaultWebSessionManager
### If caching of user is required then uncomment below lines
cacheManager = org.apache.shiro.cache.MemoryConstrainedCacheManager
securityManager.cacheManager = $cacheManager
cookie = org.apache.shiro.web.servlet.SimpleCookie
cookie.name = JSESSIONID
#Uncomment the line below when running Zeppelin-Server in HTTPS mode
#cookie.secure = true
cookie.httpOnly = true
sessionManager.sessionIdCookie = $cookie
securityManager.sessionManager = $sessionManager
# 86,400,000 milliseconds = 24 hour
securityManager.sessionManager.globalSessionTimeout = 86400000
shiro.loginUrl = /api/login

#[roles]
#admin = *
admin_role = *

[urls]
# This section is used for url-based security.
# You can secure interpreter, configuration and credential information by urls. Comment or uncomment the below urls that you want to hide.
# anon means the access is anonymous.
# authc means Form based Auth Security
# To enfore security, comment the line below and uncomment the next one
#/api/version = anon
/api/version=authc, anyofrolesuser[admin_role]
/api/interpreter/** = authc, anyofrolesuser[admin_role]
/api/configurations/** = authc, roles[admin_role]
/api/credential/** = authc, roles[admin_role]
#/** = anon
/** = authc
```

## SH impersonation

https://zeppelin.apache.org/docs/0.7.0/manual/userimpersonation.html
```
+++++ error ++++++

org.apache.zeppelin.interpreter.InterpreterException: id: user1: No such user
sudo: unknown user: user1
sudo: unable to initialize policy plugin

	at org.apache.zeppelin.interpreter.remote.RemoteInterpreterManagedProcess.start(RemoteInterpreterManagedProcess.java:149)
	at org.apache.zeppelin.interpreter.remote.RemoteInterpreterProcess.reference(RemoteInterpreterProcess.java:73)
	at org.apache.zeppelin.interpreter.remote.RemoteInterpreter.open(RemoteInterpreter.java:290)
	at org.apache.zeppelin.interpreter.remote.RemoteInterpreter.getFormType(RemoteInterpreter.java:455)
	at org.apache.zeppelin.interpreter.LazyOpenInterpreter.getFormType(LazyOpenInterpreter.java:115)
	at org.apache.zeppelin.notebook.Paragraph.jobRun(Paragraph.java:391)
	at org.apache.zeppelin.scheduler.Job.run(Job.java:175)
	at org.apache.zeppelin.scheduler.RemoteScheduler$JobRunner.run(RemoteScheduler.java:329)
	at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
	at java.util.concurrent.FutureTask.run(FutureTask.java:266)
	at java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.access$201(ScheduledThreadPoolExecutor.java:180)
	at java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:293)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
	at java.lang.Thread.run(Thread.java:745)
++++++++++++++++++

Solution:=> useradd user1

—+++++ error +++++—— Logged in as user1

org.apache.zeppelin.interpreter.InterpreterException: sudo: sorry, you must have a tty to run sudo

	at org.apache.zeppelin.interpreter.remote.RemoteInterpreterManagedProcess.start(RemoteInterpreterManagedProcess.java:149)
	at org.apache.zeppelin.interpreter.remote.RemoteInterpreterProcess.reference(RemoteInterpreterProcess.java:73)
	at org.apache.zeppelin.interpreter.remote.RemoteInterpreter.open(RemoteInterpreter.java:290)
	at org.apache.zeppelin.interpreter.remote.RemoteInterpreter.getFormType(RemoteInterpreter.java:455)
	at org.apache.zeppelin.interpreter.LazyOpenInterpreter.getFormType(LazyOpenInterpreter.java:115)
	at org.apache.zeppelin.notebook.Paragraph.jobRun(Paragraph.java:391)
	at org.apache.zeppelin.scheduler.Job.run(Job.java:175)
	at org.apache.zeppelin.scheduler.RemoteScheduler$JobRunner.run(RemoteScheduler.java:329)
	at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
	at java.util.concurrent.FutureTask.run(FutureTask.java:266)
	at java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.access$201(ScheduledThreadPoolExecutor.java:180)
	at java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:293)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
	at java.lang.Thread.run(Thread.java:745)


Solution:=> 
On the Zeppelin server node make sure to add the below to /etc/sudoers:  With the root user:  
$visudo  zeppelin ALL=(ALL) NOPASSWD: ALL 

#comment below line
#Defaults    requiretty

You confirm the access by switch to zeppelin user and switch user you want to impersonate. 

sudo su zeppelin 
sudo su <user> 

++++
org.apache.commons.exec.ExecuteException: Process exited with an error: 1 (Exit value: 1)
	at org.apache.commons.exec.DefaultExecutor.executeInternal(DefaultExecutor.java:404)
	at org.apache.commons.exec.DefaultExecutor.execute(DefaultExecutor.java:166)
	at org.apache.commons.exec.DefaultExecutor.execute(DefaultExecutor.java:153)
	at org.apache.zeppelin.shell.security.ShellSecurityImpl.createSecureConfiguration(ShellSecurityImpl.java:52)
	at org.apache.zeppelin.shell.ShellInterpreter.open(ShellInterpreter.java:63)
	at org.apache.zeppelin.interpreter.LazyOpenInterpreter.open(LazyOpenInterpreter.java:70)
	at org.apache.zeppelin.interpreter.remote.RemoteInterpreterServer$InterpretJob.jobRun(RemoteInterpreterServer.java:483)
	at org.apache.zeppelin.scheduler.Job.run(Job.java:175)
	at org.apache.zeppelin.scheduler.ParallelScheduler$JobRunner.run(ParallelScheduler.java:162)
	at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
	at java.util.concurrent.FutureTask.run(FutureTask.java:266)
	at java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.access$201(ScheduledThreadPoolExecutor.java:180)
	at java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:293)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
	at java.lang.Thread.run(Thread.java:745)
```
## kinit in shell interpreter

```sh
Zeppelin shell interpreter cannot do kinit for the users. User should execute kinit either by using below command, or create a .bash profile to execute kinit on login. 

echo "password" | kinit >> ~/.bash_profile

or create a shell script with restricted permissions and set it in bash_profile. 

vi ~/kinit_script.sh or
echo "password" | kinit
chmod 700 ~/kinit_script.sh 
chown <user> ~/kinit_script.sh 
```

## JDBC Impersonnation

```
from Zeppelin UI ---> credentials tab in zeppelin UI set the user name and password with below line.

jdbc.jdbc <userName> <Password>
```
