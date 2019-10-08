# Setup NiFi:

 - [x] Setup NiFi SSL https://github.com/bhagadepravin/commands/blob/master/nifi.md#1-enabling-ssl-with-a-nifi-certificate-authority
 - [x] Setup NiFi+Knox https://github.com/bhagadepravin/commands/blob/master/nifi.md#3-configuring-nifi-authentication-and-proxying-with-apache-knox
 - [x] NiFi LDAP https://github.com/bhagadepravin/commands/blob/master/nifi.md#9-nifi-lightweight-directory-access-protocol-ldap
 - [x] NiFi SSL Troubleshooting https://github.com/bhagadepravin/commands/blob/master/nifi.md#ii-troubleshooting-nifi-ssl-using-nifi-ca-and-nifi-ranger-plugin-configured-with-internalpublic-ca-using-san-entry
 
https://www.evernote.com/l/AjKET3tRTm1IUKLpKbDFQag-BRbMWbdvU9E

## 1. [Enabling SSL with a NiFi Certificate Authority](https://docs.cloudera.com/HDPDocuments/HDF3/HDF-3.4.0/nifi-authentication/content/enabling_ssl_with_a_nifi_certificate_authority.html)

```bash
If you want to enable SSL with a NiFi CA installed, and are not yet using Ranger to manage authorization:
1. Check the Enable SSL? box.
2. Specify the NiFi CA Token.
3. Verify that the authorizations.xml file on each node does not contain policies. The authorizations.xml is located in {nifi_internal_dir}/conf. By default, this location is /var/lib/nifi/conf/, and the value of {nifi_internal_dir} is specified in the NiFi internal dir field under Advanced nifi-ambari-config.


Note
If authorizations.xml does contain policies, you must delete it from each node. If you do not, your Initial Admin Identity and Node Identities changes do not take effect.

4. Specify the Initial Admin Identity. The Initial Admin Identity is the identity of an initial administrator and is granted access to the UI and has the ability to create additional users, groups, and policies. This is a required value when you are not using the Ranger plugin for NiFi for authorization.
The Initial Admin Identity format is CN=admin, OU=NIFI.
After you have added the Initial Admin Identity, you must immediately generate certificate for this user.
5. Specify the Node Identities. This indicates the identity of each node in a NiFi cluster and allows clustered nodes to communicate. This is a required value when you are not using the Ranger plugin for NiFi for authorization.
<property name="Node Identity 1">CN=node1.fqdn, OU=NIFI</property>
<property name="Node Identity 2">CN=node2.fqdn, OU=NIFI</property>
<property name="Node Identity 3">CN=node3.fqdn, OU=NIFI</property>
Replace node1.fqdn, node2.fqdn, and node3.fqdn with their respective fully qualified domain names.

```

## 2. [Generating Client Certificates](https://docs.cloudera.com/HDPDocuments/HDF3/HDF-3.4.0/nifi-authentication/content/generating_client_certificates.html)


```java
[root@c374-node4 nifi-toolkit-1.5.0.3.1.2.0-7]# bin/tls-toolkit.sh
tls-toolkit.sh: JAVA_HOME not set; results may vary
Expected at least a service argument.

Usage: tls-toolkit service [-h] [args]

Services:
   standalone: Creates certificates and config files for nifi cluster.
   server: Acts as a Certificate Authority that can be used by clients to get Certificates
   client: Generates a private key and gets it signed by the certificate authority.
   status: Checks the status of an HTTPS endpoint by making a GET request using a supplied keystore and truststore.
```

##### ERROR:

```java
[root@c374-node4 nifi-toolkit-1.5.0.3.1.2.0-7]# bin/tls-toolkit.sh client -c c374-node4.squadron.support.hortonworks.com -D "CN=admin, OU=NIFI" -t nifi -p 10443 -T pkcs12
2019/10/04 11:45:26 INFO [main] org.apache.nifi.toolkit.tls.commandLine.BaseTlsToolkitCommandLine: Command line argument --keyStoreType=pkcs12 only applies to keystore, recommended truststore type of JKS unaffected.
2019/10/04 11:45:26 INFO [main] org.apache.nifi.toolkit.tls.service.client.TlsCertificateAuthorityClient: Requesting new certificate from c374-node4.squadron.support.hortonworks.com:10443
2019/10/04 11:45:27 INFO [main] org.apache.nifi.toolkit.tls.service.client.TlsCertificateSigningRequestPerformer: Requesting certificate with dn CN=admin,OU=NIFI from c374-node4.squadron.support.hortonworks.com:10443
Service client error: Received response code 403 with payload {"hmac":null,"pemEncodedCertificate":null,"error":"forbidden"}
```
##### Resolution:--->
```sh
-t nifi
We need to pass the NiFi token password:
Step 2>>create keystore for that user bin/tls-toolkit.sh client -c <NIFI CA HOSTNAME> -D 'CN=username, OU=NIFI' -p <NIFI CA port> -t "toolkit token" -T pkcs12


++++++++++
[root@c374-node4 nifi-toolkit-1.5.0.3.1.2.0-7]# bin/tls-toolkit.sh client -c c374-node4.squadron.support.hortonworks.com -D "CN=admin, OU=NIFI" -t Welcome@12345 -p 10443 -T pkcs12
2019/10/04 11:50:20 INFO [main] org.apache.nifi.toolkit.tls.commandLine.BaseTlsToolkitCommandLine: Command line argument --keyStoreType=pkcs12 only applies to keystore, recommended truststore type of JKS unaffected.
2019/10/04 11:50:20 INFO [main] org.apache.nifi.toolkit.tls.service.client.TlsCertificateAuthorityClient: Requesting new certificate from c374-node4.squadron.support.hortonworks.com:10443
2019/10/04 11:50:22 INFO [main] org.apache.nifi.toolkit.tls.service.client.TlsCertificateSigningRequestPerformer: Requesting certificate with dn CN=admin,OU=NIFI from c374-node4.squadron.support.hortonworks.com:10443
2019/10/04 11:50:22 INFO [main] org.apache.nifi.toolkit.tls.service.client.TlsCertificateSigningRequestPerformer: Got certificate with dn CN=admin, OU=NIFI

========================================

[root@c374-node4 nifi-toolkit-1.5.0.3.1.2.0-7]# ls -ltr
total 56
-rw-r--r-- 1 root root  5473 Oct  4 11:23 NOTICE
-rw-r--r-- 1 root root 14253 Oct  4 11:23 LICENSE
drwxr-xr-x 2 root root  8192 Oct  4 11:23 lib
drwxr-xr-x 2 root root    58 Oct  4 11:23 conf
drwxr-xr-x 2 root root  4096 Oct  4 11:23 bin
drwxr-xr-x 3 root root    69 Oct  4 11:23 classpath
-rw------- 1 root root  3554 Oct  4 11:50 keystore.pkcs12
-rw------- 1 root root   979 Oct  4 11:50 truststore.jks
-rw------- 1 root root   649 Oct  4 11:50 config.json
-rw------- 1 root root  1294 Oct  4 11:50 nifi-cert.pem
[root@c374-node4 nifi-toolkit-1.5.0.3.1.2.0-7]#

[root@c374-node4 nifi-toolkit-1.5.0.3.1.2.0-7]# cat config.json
{
  "days" : 1095,
  "keySize" : 2048,
  "keyPairAlgorithm" : "RSA",
  "signingAlgorithm" : "SHA256WITHRSA",
  "dn" : "CN=admin, OU=NIFI",
  "domainAlternativeNames" : null,
  "keyStore" : "keystore.pkcs12",
  "keyStoreType" : "pkcs12",
  "keyStorePassword" : "ARgQMZD/1BVQZKnQOZuQrYn6K95HOGs9K5CT3llK1m0",
  "keyPassword" : null,
  "token" : "Welcome@12345",
  "caHostname" : "c374-node4.squadron.support.hortonworks.com",
  "port" : 10443,
  "dnPrefix" : "CN=",
  "dnSuffix" : ", OU=NIFI",
  "reorderDn" : true,
  "trustStore" : "truststore.jks",
  "trustStorePassword" : "kEJJvyomDKbPGCjz8ROtTJxn/tHbcVoGE12gRv9d0QU",
  "trustStoreType" : "jks"
```
Issue: After enabling SSL on Nifi, UI still popup for Usernmae password:
—> Open the UI in `Incognito Mode` and check
For me it worked for default CA cert.

## Setting Up Identity Mapping

```java

The following examples demonstrate normalizing DNs from certificates and principals from Kerberos:
nifi.security.identity.mapping.pattern.dn=^CN=(.*?), OU=(.*?), O=(.*?), L=(.*?), ST=(.*?), C=(.*?)$
nifi.security.identity.mapping.value.dn=$1@$2
nifi.security.identity.mapping.pattern.kerb=^(.*?)/instance@(.*?)$
nifi.security.identity.mapping.value.kerb=$1@$2
```
## 3. [Configuring NiFi Authentication and Proxying with Apache Knox](https://docs.cloudera.com/HDPDocuments/HDF3/HDF-3.4.0/nifi-knox/content/configuring_nifi_for_knox_authentication.html)

```sh
We recommend that NiFi is installed on a different host than Knox.

1. In Advanced nifi-ambari-ssl-config, the Initial Admin Identity value must specify a user that Apache Knox can authenticate.
2. In Advanced nifi-ambari-ssl-config, add a node identity for the Knox node:
<property name="Node Identity 1">CN=$NIFI_HOSTNAME, OU=NIFI</property>
<property name="Node Identity 2">CN=$NIFI_HOSTNAME, OU=NIFI</property>
<property name="Node Identity 3">CN=$NIFI_HOSTNAME, OU=NIFI</property>
<property name="Node Identity 4">CN=$KNOX_HOSTNAME, OU=KNOX</property>
3. Update the nifi.web.proxy.context.path property in Advanced nifi-properties:
nifi.web.proxy.context.path=/$GATEWAY_CONTEXT/flow-management/nifi-app
nifi.web.proxy.context.path=/gateway/flow-management/nifi-app
$GATEWAY_CONTEXT is the value in the Advanced gateway-site gateway.path field in the Ambari Configs for Knox.
4. Update the nifi.web.proxy.host property in Advanced nifi-properties with a comma-separated list of the host name and port for each Knox host, if you are deploying in a container or cloud environment.
For example:
knox-host1:18443, knox-host2:443
```

## 4. [Preparing to Generate Knox Certificates using the TLS Toolkit](https://docs.cloudera.com/HDPDocuments/HDF3/HDF-3.4.0/nifi-knox/content/creating-knox-certificates-using-the-tls-toolkit.html)

```sh

sudo su - knox
vi /home/knox/nifi-ca-config.json 

{
  "dn" : "CN=c374-node4.squadron.support.hortonworks.com, OU=KNOX",
  "keyStore" : "/home/knox/knox-nifi-keystore.jks",
  "keyStoreType" : "jks",
  "keyStorePassword" : "Welcome@12345",
  "keyPassword" : "Welcome@12345",
  "token" : "Welcome@12345",
  "caHostname" : "c374-node4.squadron.support.hortonworks.com",
  "port" : 10443,
  "trustStore" : "/home/knox/knox-nifi-truststore.jks",
  "trustStorePassword" : "Welcome@12345",
  "trustStoreType" : "jks"
}
```

https://docs.cloudera.com/HDPDocuments/HDF3/HDF-3.4.0/nifi-knox/content/creating_certificates_for_knox.html
```java
1.
export JAVA_HOME=/usr/jdk64/jdk1.8.0_112
/var/lib/ambari-agent/tmp/nifi-toolkit-1.5.0.3.1.2.0-7/bin/tls-toolkit.sh client --subjectAlternativeNames "CN=c374-node4.squadron.support.hortonworks.com, OU=KNOX" -F -f /home/knox/nifi-ca-config.json

/home/knox
-rw------- 1 knox hadoop 3246 Oct  5 08:50 knox-nifi-keystore.jks
-rw------- 1 knox hadoop  979 Oct  5 08:50 knox-nifi-truststore.jks
-rw-r--r-- 1 knox hadoop  674 Oct  5 08:50 nifi-ca-config.json
-rw------- 1 knox hadoop 1294 Oct  5 08:50 nifi-cert.pem
2. Import the Knox certificate for NiFi into the Knox gateway.jks file:
keytool -importkeystore -srckeystore /home/knox/knox-nifi-keystore.jks -destkeystore /usr/hdp/current/knox-server/data/security/keystores/gateway.jks -deststoretype JKS -srcstorepass Welcome@12345 -deststorepass Welcome@12345

3. Import the NiFi CA truststore into the Knox gateway.jks file:
keytool -importkeystore -srckeystore /home/knox/knox-nifi-truststore.jks -destkeystore /usr/hdp/current/knox-server/data/security/keystores/gateway.jks -deststoretype JKS -srcstorepass Welcome@12345 -deststorepass Welcome@12345

4. Verify that the proper keys are in the gateway.jks file:
keytool -keystore /usr/hdp/current/knox-server/data/security/keystores/gateway.jks -storepass Welcome@12345 -list -v
```

## 5. [Configuring the Knox SSO Topology](https://docs.cloudera.com/HDPDocuments/HDF3/HDF-3.4.0/nifi-knox/content/configuring_the_knox_admin_ui.html)

```sh
Navigate to Advanced knoxsso-topology and, in the KNOXSSO service definition, edit the Knox SSO token time-to-live value. For example, for a 10 hour time-to-live:
<param>
   <name>knoxsso.token.ttl</name>
   <value>36000000</value>
</param>


Update the knoxsso.redirect.whitelist.regex property with a regex value that represents the host or domain in which the NiFi host is running. If the knoxsso.redirect.whitelist.regex property does not exist, you must add it. For example:
```

## 6. [Creating an Advanced Topology](https://docs.cloudera.com/HDPDocuments/HDF3/HDF-3.4.0/nifi-knox/content/creating-an-advanced-topology.html)

As the Knox user, create `flow-management.xml` in `usr/hdp/current/knox-server/conf/topologies`

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<topology>
  <gateway>
    <provider>
      <role>authentication</role>
      <name>ShiroProvider</name>
      <enabled>true</enabled>
      <param>
        <name>sessionTimeout</name>
        <value>30</value>
      </param>
      <param>
        <name>redirectToUrl</name>
        <value>/gateway/knoxsso/knoxauth/login.html</value>
      </param>
      <param>
        <name>restrictedCookies</name>
        <value>rememberme,WWW-Authenticate</value>
      </param>
      <param>
        <name>main.ldapRealm</name>
        <value>org.apache.hadoop.gateway.shirorealm.KnoxLdapRealm</value>
      </param>
      <param>
        <name>main.ldapContextFactory</name>
        <value>org.apache.hadoop.gateway.shirorealm.KnoxLdapContextFactory</value>
      </param>
      <param>
        <name>main.ldapRealm.contextFactory</name>
        <value>$ldapContextFactory</value>
      </param>
      <param>
        <name>main.ldapRealm.userDnTemplate</name>
        <value>uid={0},ou=people,dc=hadoop,dc=apache,dc=org</value>
      </param>
      <param>
        <name>main.ldapRealm.contextFactory.url</name>
        <value>ldap://localhost:33389</value>
      </param>
      <param>
        <name>main.ldapRealm.authenticationCachingEnabled</name>
        <value>false</value>
      </param>
      <param>
        <name>main.ldapRealm.contextFactory.authenticationMechanism</name>
        <value>simple</value>
      </param>
      <param>
        <name>urls./**</name>
        <value>authcBasic</value>
      </param>
    </provider>
    <provider>
      <role>identity-assertion</role>
      <name>Default</name>
      <enabled>true</enabled>
    </provider>
  </gateway>
  <service>
    <role>NIFI</role>
    <url>https://c374-node4.squadron.support.hortonworks.com:9091</url>
    <param name="useTwoWaySsl" value="true"/>
  </service>
</topology>
```

## 7. [Configuring Knox SSO](https://docs.cloudera.com/HDPDocuments/HDF3/HDF-3.4.0/nifi-knox/content/configuring_knox_sso.html)

If you want to use Knox SSO authentication, perform the following steps:
1. On each cluster node with Knox installed, replace the ShiroProvider federation provider in the 1flow-management.xml1 file with the following content:

```xml
<provider>
   <role>federation</role>
   <name>SSOCookieProvider</name>
   <enabled>true</enabled>
   <param>
      <name>sso.authentication.provider.url</name>
      <value>https://c374-node4.squadron.support.hortonworks.com:8443/gateway/knoxsso/api/v1/websso</value>
   </param>
</provider>
```
Your new flow-management.xml file looks similar to the following:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<topology>
  <gateway>
    <provider>
      <role>federation</role>
      <name>SSOCookieProvider</name>
      <enabled>true</enabled>
      <param>
        <name>sso.authentication.provider.url</name>
        <value>https://c374-node4.squadron.support.hortonworks.com:8443/gateway/knoxsso/api/v1/websso</value>
      </param>
    </provider>
    <provider>
      <role>identity-assertion</role>
      <name>Default</name>
      <enabled>true</enabled>
    </provider>
  </gateway>
  <service>
    <role>NIFI</role>
    <url>https://c374-node4.squadron.support.hortonworks.com:9091</url>
    <param>
      <name>useTwoWaySsl</name>
      <value>true</value>
    </param>
  </service>
</topology>
```
```sh
1. If you want to access NiFi directly and still use Knox SSO:
  * Export the Knox SSO certificate:
$KNOX_INSTALL_DIR/bin/knoxcli.sh export-cert 
  * Set the following properties in the Advanced nifi-properties section in Ambari:
nifi.security.user.knox.url=https://c374-node4.squadron.support.hortonworks.com:8443/gateway/knoxsso/api/v1/websso
nifi.security.user.knox.publicKey=/home/knox/gateway-identity.pem
nifi.security.user.knox.cookieName=hadoop-jwt
nifi.security.user.knox.audiences=

The cookieName property must align with what is configured in Knox. 
The audiences property is used to only accept tokens from a particular audience. The audiences value is configured as part of Knox SSO.
2. Save the configuration and restart Knox.
```

##### ERROR

```java
Knox DOWN —> Nifi and KNox are on same host
9-10-05 09:17:05,479 FATAL hadoop.gateway (GatewayServer.java:main(164)) - Failed to start gateway: java.security.UnrecoverableKeyException: Cannot recover key
```

##### Resolution:--->

```java
The error usually occurs when we importing a new certificate, which private key password is different from gateway.jks's password, into Knox's keystore gateway.jks. 
If this is the case, then could you please try changing the private key password by using something similar to the following command and try to restart the knox-server again and share the result.

keytool -keypasswd -alias gateway-identity -new <same_as_store_pass> -keystore gateway.jks

Rename _gateway-credentials.jceks\

keytool -keypasswd -alias gateway-identity -new Welcome@12345 -keystore /usr/hdp/current/knox-server/data/security/keystores/gateway.jks
```
https://community.cloudera.com/t5/Community-Articles/Replace-Cloudbreak-Mini-Knox-self-signed-certificate-with-CA/ta-p/247110

## 8. [Adding a NiFi Policy for Knox](https://docs.cloudera.com/HDPDocuments/HDF3/HDF-3.4.0/nifi-knox/content/adding_a_nifi_policy_for_knox.html)

```xml
<property name="Node Identity 1">CN=c374-node4.squadron.support.hortonworks.com, OU=NIFI</property>
<property name="Node Identity 2">CN=c374-node4.squadron.support.hortonworks.com, OU=KNOX</property>
```
https://$KNOX_HOST:$KNOX_PORT/$GATEWAY_CONTEXT/default/nifi-app/nifi

##### ERROR:

```java
/var/log/nifi/nifi-user.log
2019-10-05 14:13:43,727 ERROR [NiFi Web Server-386] o.a.nifi.web.api.config.ThrowableMapper An unexpected error has occurred: javax.ws.rs.core.UriBuilderException: The provided context path [/gateway/default/nifi-app] was not whitelisted [/gateway/flow-management/nifi-app]. Returning Internal Server Error response.
javax.ws.rs.core.UriBuilderException: The provided context path [/gateway/default/nifi-app] was not whitelisted [/gateway/flow-management/nifi-app]
```

##### Resolution:--->

```sh
Used below url to access the Nifi UI.
https://c374-node4.squadron.support.hortonworks.com:8443/gateway/flow-management/nifi-app/nifi/
```

# 9. NiFI Lightweight Directory Access Protocol (LDAP)

```xml
            <provider>
            <identifier>ldap-provider</identifier>
            <class>org.apache.nifi.ldap.LdapProvider</class>
            <property name="Identity Strategy">USE_USERNAME</property>
            <property name="Authentication Strategy">SIMPLE</property>
    <property name="Manager DN">test1@SUPPORT.COM</property>
    <property name="Manager Password">hadoop12345!</property>
     <property name="Authentication Strategy">SIMPLE</property>
    <property name="TLS - Keystore"></property>
    <property name="TLS - Keystore Password"></property>
    <property name="TLS - Keystore Type"></property>
    <property name="TLS - Truststore"></property>
    <property name="TLS - Truststore Password"></property>
    <property name="TLS - Truststore Type"></property>
    <property name="TLS - Client Auth"></property>
    <property name="TLS - Protocol"></property>
    <property name="TLS - Shutdown Gracefully"></property>

    <property name="Referral Strategy">FOLLOW</property>
    <property name="Connect Timeout">10 secs</property>
    <property name="Read Timeout">10 secs</property>

    <property name="Url">ldap://172.26.126.78:389</property>
    <property name="User Search Base">OU=hortonworks,DC=support,DC=com</property>
    <property name="User Search Filter">(samaccountname={0})</property>

    <property name="Identity Strategy">USE_USERNAME</property>
    <property name="Authentication Expiration">12 hours</property>
</provider>
```

With this configuration, username/password authentication can be enabled by referencing this provider in nifi.properties.
`nifi.security.user.login.identity.provider=ldap-provider`


# II. Troubleshooting Nifi SSL using NiFi CA and Nifi, Ranger Plugin configured with Internal/Public CA using SAN entry

##### 1. Use openssl command to see what server certificate was being presented by Ranger to client (nifi):
```sh
openssl s_client -connect <ranger-hostname>:<ranger-port>
```

Check what it shows, a single certificate that was signed by an intermediate CA (the intermediate CA was signed by a root CA)

##### 2. Check the truststore used on the NiFi nodes to see if they were capable of trusting that complete certificate chain (intermediate and root CAs). 
--> By using below cmds:
* Check the truststore used by nifi.

```sh
$ grep "nifi.security.truststore" /etc/nifi/conf/nifi.properties  | grep "jks"
$ keytool -v -list -keystore truststore.jks
```

* Verify if you see trusted authority of Ranger Certs.

If not, Use the openssl command to retrieve the public certificates for the intermediate and root CA for rangers certificate: 

```sh
$ openssl s_client -connect <ranger-hostname>:<ranger-port> --showcerts 
```

* The above command will output the public certificate for the server cert, intermediate cert, and root cert. 
* We only need to trust the complete trust chain, so only need to copy certs for intermediate and root CA. 
* Each certificate starts with "-----BEGIN CERTIFICATE-----" and ends with "-----END CERTIFICATE-----". 

So We need to create  a inter-ca.crt file and a root-ca.crt file on each NiFi node. 
Use the keytool command to import both certificates into NiFi truststore on each nifi node.

```bash
$ keytool -import -alias inter-ca -file inter-ca.crt -keystore <nifi-truststore.jks> 
$ keytool -import -alias root-ca -file root-ca.crt -keystore <nifi-truststore.jks> 
```

Then restart the Nifi Service.


##### 3.Use openssl command to see what CA authorities (trusts) the Ranger endpoint allowed: 

```bash
$ openssl s_client -connect <ranger-hostname>:<ranger-port>
```

* We expect to see was a line in the output that matched "Acceptable client certificate CA names" followed by a list of trust authorities, but if not present. 
* Check the Ranger configs in Ambari and checked what value was set for `ranger.service.https.attrib.clientAuth`. 
If its false which means it will not ask client to identify itself. So We need to change this config to "want" and restart the Ranger Service. 

* Verify with openssl command above that Ranger, it will list of trust authorities.
* Check if NiFi was now able to successfully pull the latest policies from Ranger. 
* Check for all NiFi nodes successfully. 


##### 4. Verify if Ranger was capable of retrieving a list of policies from NiFi. 
If not
--> * Check configured truststore being used by the "c274_nifi" service in ranger, Check if it includes NiFi CA as a trusted authority. Use opessl command above with -showcerts option to get the public cert for the NiFi CA. 
* Import that nifi-ca.crt file in to the truststore. 

```bash
keytool -import -alias nifi-ca -file nifi-ca.crt -keystore truststorejks
```

*Click on test connection. If you see 403 response (this indicates user authentication was successful but authorization was not) 

* Add new policy authorizing the ranger user (from keystore configured in service) access to read on /resources policy.

```bash
$ CN=c274-node1.squadron-labs.com, OU=Support, O=Hortonworks, L=BNG, ST=KNK, C=IN
```
    
If Mapping is enabled, use like below.
    
```
$ c274-node1.squadron-labs.com@Support, O=Hortonworks, L=BNG, ST=KNK, C=IN
```

* Now test connection should be successful. 
* Verify by  adding a new policy, upon entering just "/" in the "NiFi resource Identifier" field triggered all available policies retrieved from NiFi to list. 


## TIPS:->

If you have 3 nifi and certificate CN name of different node use regex expression.

In Ranger: 
```bash
commonNameForCertificate=regex:c274-node[1-4]\.squadron-labs\.com
```

In `Ambari -> NiFi -> Advanced ranger-nifi-plugin-properties`

Owner for Certificate = Enter the identity `Owner:` of the certificate used by ranger

```sh
$ /usr/jdk64/jdk1.8.0_112/bin/keytool -v -list -keystore keystore.jks
```

In `Ambari -> NiFi -> Advanced ranger-nifi-policymgr-ssl`

owner.for.certificate = Enter the identity (Distinguished Name or DN) of the nifi node(s) that will communicate with Ranger. 
Referring to multiple nodes identities this value use regex by adding a regex prefix along with the expression 

(E.g.: `CN=regex:c274-node[1-4]\.squadron-labs\.com, OU=Support, O=Hortonworks, L=BNG, ST=KNK, C=IN` 
to match multiple DN using 1 through 4). 
This value is not required if Kerberos is enabled on HDF.

