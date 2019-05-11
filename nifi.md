# Troubleshooting Nifi SSL using NiFi CA and Nifi, Ranger Plugin configured with InterCA using SAN entry

1. Use openssl command to see what server certificate was being presented by Ranger to client (nifi):

--> `openssl s_client -connect <ranger-hostname>:<ranger-port>`

Check what it shows, a single certificate that was signed by an intermediate CA (the intermediate CA was signed by a root CA)

2. Check the truststore used on the NiFi nodes to see if they were capable of trusting that complete certificate chain (intermediate and root CAs). 
--> By using below cmds:
* Check the truststore used by nifi.

`grep "nifi.security.truststore" /etc/nifi/conf/nifi.properties  | grep "jks"`

`keytool -v -list -keystore truststore.jks`

* Verify if you see trusted authority of Ranger Certs.

If not, Use the openssl command to retrieve the public certificates for the intermediate and root CA for rangers certificate: 

```sh
openssl s_client -connect <ranger-hostname>:<ranger-port> --showcerts 
```

* The above command will output the public certificate for the server cert, intermediate cert, and root cert. 
* We only need to trust the complete trust chain, so only need to copy certs for intermediate and root CA. 
* Each certificate starts with "-----BEGIN CERTIFICATE-----" and ends with "-----END CERTIFICATE-----". 

So We need to create  a inter-ca.crt file and a root-ca.crt file on each NiFi node. 
Use the keytool command to import both certificates into NiFi truststore on each nifi node.

```bash
$ /usr/jdk64/jdk1.8.0_112/bin/keytool -import -alias inter-ca -file inter-ca.crt -keystore <nifi-truststore.jks> 
$ /usr/jdk64/jdk1.8.0_112/bin/keytool -import -alias root-ca -file root-ca.crt -keystore <nifi-truststore.jks> 
```

Then restart the Nifi Service.


3.Use openssl command to see what CA authorities (trusts) the Ranger endpoint allowed: 

`$ openssl s_client -connect <ranger-hostname>:<ranger-port> `

* We expect to see was a line in the output that matched "Acceptable client certificate CA names" followed by a list of trust authorities, but if not present. 
* Check the Ranger configs in Ambari and checked what value was set for `ranger.service.https.attrib.clientAuth`. 
If its false which means it will not ask client to identify itself. So We need to change this config to "want" and restart the Ranger Service. 

* Verify with openssl command above that Ranger, it will list of trust authorities.
* Check if NiFi was now able to successfully pull the latest policies from Ranger. 
* Check for all NiFi nodes successfully. 


4. Verify if Ranger was capable of retrieving a list of policies from NiFi. 
If not
--> * Check configured truststore being used by the "c274_nifi" service in ranger, Check if it includes NiFi CA as a trusted authority. Use opessl command above with -showcerts option to get the public cert for the NiFi CA. 
* Import that nifi-ca.crt file in to the truststore. 

`/usr/jdk64/jdk1.8.0_112/bin/keytool -import -alias nifi-ca -file nifi-ca.crt -keystore truststorejks`

*Click on test connection. If you see 403 response (this indicates user authentication was successful but authorization was not) 

* Add new policy authorizing the ranger user (from keystore configured in service) access to read on /resources policy.

`$ CN=c274-node1.squadron-labs.com, OU=Support, O=Hortonworks, L=BNG, ST=KNK, C=IN`
    
If Mapping is enabled, use like below.
    
```
$ c274-node1.squadron-labs.com@Support, O=Hortonworks, L=BNG, ST=KNK, C=IN
```

* Now test connection should be successful. 
* Verify by  adding a new policy, upon entering just "/" in the "NiFi resource Identifier" field triggered all available policies retrieved from NiFi to list. 
```

## TIPS:
```bash
If you have 3 nifi and certificate CN name of different node use regex expression.

In Ranger: commonNameForCertificate=regex:c274-node[1-4]\.squadron-labs\.com

In Ambari -> NiFi -> Advanced ranger-nifi-plugin-properties
Owner for Certificate = Enter the identity `Owner:` of the certificate used by ranger

`$ /usr/jdk64/jdk1.8.0_112/bin/keytool -v -list -keystore keystore.jks`

In Ambari -> NiFi -> Advanced ranger-nifi-policymgr-ssl
owner.for.certificate = Enter the identity (Distinguished Name or DN) of the nifi node(s) that will communicate with Ranger. 
Referring to multiple nodes identities this value use regex by adding a regex prefix along with the expression 

(E.g.: `CN=regex:c274-node[1-4]\.squadron-labs\.com, OU=Support, O=Hortonworks, L=BNG, ST=KNK, C=IN` to match multiple DN using 1 through 9). 
This value is not required if Kerberos is enabled on HDF.
```
