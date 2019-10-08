# Setup NiFi SSL

## 1. Enabling SSL with a NiFi Certificate Authority
https://docs.cloudera.com/HDPDocuments/HDF3/HDF-3.4.0/nifi-authentication/content/enabling_ssl_with_a_nifi_certificate_authority.html

```sh
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

## 2. Generating Client Certificates
https://docs.cloudera.com/HDPDocuments/HDF3/HDF-3.4.0/nifi-authentication/content/generating_client_certificates.html

```sh
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

```sh
[root@c374-node4 nifi-toolkit-1.5.0.3.1.2.0-7]# bin/tls-toolkit.sh client -c c374-node4.squadron.support.hortonworks.com -D "CN=admin, OU=NIFI" -t nifi -p 10443 -T pkcs12
2019/10/04 11:45:26 INFO [main] org.apache.nifi.toolkit.tls.commandLine.BaseTlsToolkitCommandLine: Command line argument --keyStoreType=pkcs12 only applies to keystore, recommended truststore type of JKS unaffected.
2019/10/04 11:45:26 INFO [main] org.apache.nifi.toolkit.tls.service.client.TlsCertificateAuthorityClient: Requesting new certificate from c374-node4.squadron.support.hortonworks.com:10443
2019/10/04 11:45:27 INFO [main] org.apache.nifi.toolkit.tls.service.client.TlsCertificateSigningRequestPerformer: Requesting certificate with dn CN=admin,OU=NIFI from c374-node4.squadron.support.hortonworks.com:10443
Service client error: Received response code 403 with payload {"hmac":null,"pemEncodedCertificate":null,"error":"forbidden"}
```
##### Resolution:
```sh
-t nifi
We need to pass the NiFi token password:
Step 2>>create keystore for that user bin/tls-toolkit.sh client -c <NIFI CA HOSTNAME> -D 'CN=username, OU=NIFI' -p <NIFI CA port> -t <<toolkit token>> -T pkcs12
```


# Troubleshooting Nifi SSL using NiFi CA and Nifi, Ranger Plugin configured with Internal/Public CA using SAN entry

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

