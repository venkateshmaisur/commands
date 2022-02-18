# Cloudera Manager

### Custom kerberos krb5.conf file

```
Set below value in /etc/default/cloudera-scm-agent
CMF_AGENT_KRB5_CONFIG=/tmp/krb5.conf
KRB5_CONFIG=/tmp/krb5.conf
```

### Cm agent kerbeors debug
```
Set below value in /etc/default/cloudera-scm-agent
KRB5_TRACE=/tmp/krb.log

systemctl restart cloudera-scm-agent
```

### auto tls using existing certificate:

```
curl -i -u admin:pbhagade -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
"location" : "/opt/cloudera/AutoTLS",
"customCA" : true,
"interpretAsFilenames" : true,
"cmHostCert" : "/tmp/auto-tls/certificate.pem",
"cmHostKey" : "/tmp/auto-tls/key.pem",
"caCert" : "/tmp/auto-tls/ca-certs.pem",
"keystorePasswd" : "/tmp/auto-tls/key.pwd",
"truststorePasswd" : "/tmp/auto-tls/truststore.pwd",
"hostCerts" : [ {
"hostname" : "c374-node1.coelab.cloudera.com",
"certificate" : "/tmp/auto-tls/certificate.pem",
"key" : "/tmp/auto-tls/key.pem"
}, {
"hostname" : "c374-node2.coelab.cloudera.com",
"certificate" : "/tmp/auto-tls/certificate.pem",
"key" : "/tmp/auto-tls/key.pem"
}, {
"hostname" : "c374-node3.coelab.cloudera.com",
"certificate" : "/tmp/auto-tls/certificate.pem",
"key" : "/tmp/auto-tls/key.pem"
}, {
"hostname" : "c374-node4.coelab.cloudera.com",
"certificate" : "/tmp/auto-tls/certificate.pem",
"key" : "/tmp/auto-tls/key.pem"
} ],
"configureAllServices" : "true",
"sshPort" : 22,
"userName" : "root",
"password" : "",
"privateKey": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAuVguCViH3FllZzNYLPbtk4sEpVA2CK9Yp5obAgM4GnH3URE0\ngJx7hLtOkOrYbbmuUc5DJvp6JJ9W/rIvnqFQmifHxpBRjj7N+BN98nVOA709lZoG\n+qHvR1oVlDCiNmvo46MP7jXriQce6sVB0/LvmaHVXU5SbXLFVLEU3nQIBv6lbsqB\n11wWitaDHF4AaPMS6rCOR4MFPoeSNPEAvE8FEBH4YJj6NPaPisB3s9291ZmOB9/P\nZ0ZAVyN+eidGrjWr0/oX8n+wcp5Xa4A3URY5hNiTI9Qq8yc9cFGrwUxH0EqKo4RU\nCZNzdnpnHc0dUiWPDO/Kw2jkOFo5X5djVGVaAwIDAQABAoIBAFw+Z8Mc/ZkMIOyo\n4CSYzIrW8Hv6HLpb0oqvputsgLqgp87/+hpcRxk7Q5HaX9bUR87NEhzPIoUhjGF8\nezi+3meqjsHjR8O8vDPQN6m4+hfgUksnenu4pmbjjcPQJJtjP2gz2pTa3xu2oIuF\nmwqKaPcUVSV3+owgR9ervlAsfWZE8w3b/wG/AFQqQdVdqjNRgHNfIWGGAsyLHrt6\nhynV+TUt0fsCD343OJ7/0uSOtRINeb84gxLjNVPavrE+8LkWOXJtEB5iCdF5cPtO\nG7lpBKqpOvZVE0ZvVbXDh6CO6ZrC1q+ajLXAbA1lwPqAZTxkGY3zYYay/IukcLpK\n/6bTUtECgYEA5unmrsDj2y5EZn99NfLFmNPsoEMq7is7UKK7X4oWwtw2w2KPGBRs\nB4tT4jyukPatz1VgdHYj6SkZGHgtAgglcd/in2+Z9ZLU4Id8V8IKgAGW/L5QjNdZ\nidxg/Ig3X1cDcjfmNY76xGdRcgRk6PYr3VeHDifwDh+ftfcDWnUWFSsCgYEAzXrr\n9vVNFlCIvY+AAykZJJAf7wxAosL5qZW3PtFvz6ZqS3jmvar6ak/2tJ8tJzq++klm\n23PwFXZjmiWA6YyKOM1u2H89GYpwQr8CCVVKGvLXblkansfanfweqilWyJuRhASlnojdL+C1lQ\nDcJE+LJj5+NPo+f+MyH89IFA4ZkJ6FQqgHzFEokCgYEAjnDcvxH3vJ3Wzc95Ao1m\nfLbF8bpdQhvi9APeR7ob/knvcilbEcSPOzwkG5vJJ10zrIEDBfRWhJ64f1KqmOVD\ni/JKjoU+WLEhpfuNpWjqJzpT1Ebl02uILTWHkl/IoIRBePSoioNPh1YgdI/nW5l3\nR4uVoRLbzyqMz6e3JtaxL48CgYEAts7/k80Vch7gKNW8bBNqXQ8kegaKksOoXunm\nB6tJMJK7yr2be27cLy1JLdTX1Sj8s6wOKHvzQwT7BC8Ni7sPVg3e6hn5f/mceqV4\n6FjK/0LByvaPAyV3OgeLWxq2PUdT4UDqafNGbYQ4QhwHxKknjNJWPCmqUYtYNyx6\nS6m1oxECgYAwroa4H1mos6X1rnLk30qiym4gi/BfUnjjDGrBuZfwjzXX7GEEy6OU\niVKb3Ni1GgM7FApGWDDnzj8D/4IufYRMYvVXyGkgPXBpyaDil2so+zlL+v+g4o5X\ncEn9s5fA4gkM0jVCrFAIY7nDuED1xGghyswV0AH8KMEWFfpXbhO3fQ==\n-----END RSA PRIVATE KEY-----"
}' 'http://c374-node1.coelab.cloudera.com:7180/api/v41/cm/commands/generateCmca'
```
for private use below cmd to add \n
```bash
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' ~/.ssh/id_rsa
```



##### Auto-TLS Use case 2: Enabling Auto-TLS with an intermediate CA signed by an existing Root CA
```
https://github.com/arlotito/my-simple-bash-ca

https://docs.cloudera.com/cdp-private-cloud-base/7.1.6/security-encrypting-data-in-transit/topics/cm-security-use-case-2.html

export JAVA_HOME=/usr/java/jdk1.8.0_232-cloudera/; /opt/cloudera/cm-agent/bin/certmanager --location /var/lib/cloudera-scm-server/certmanager setup --configure-services --stop-at-csr




export JAVA_HOME=/usr/java/jdk1.8.0_232-cloudera/; /opt/cloudera/cm-agent/bin/certmanager --location /var/lib/cloudera-scm-server/certmanager setup --configure-services --stop-at-csr

INFO:root:Logging to /var/log/cloudera-scm-agent/certmanager.log
Stopping after CSR generation. CSR is located at: /var/lib/cloudera-scm-server/certmanager/CMCA/private/ca_csr.pem
After signing the CSR, continue Auto-TLS setup by rerunning certmanager setup and passing in --signed-ca-cert <signed_ca_chain.pem>




 openssl pkcs7 -text -inform DER -in ca_csr.p7r | openssl pkcs7 -print_certs -out ca_csr1.pem


export JAVA_HOME=/usr/java/jdk1.8.0_232-cloudera/; /opt/cloudera/cm-agent/bin/certmanager --location /var/lib/cloudera-scm-server/certmanager setup --configure-services --signed-ca-cert=/home/ca_csr_new.pem



openssl x509 -req -in /var/lib/cloudera-scm-server/certmanager/CMCA/private/ca_csr.pem -CA /root/ca/certs/ca.cert.pem -CAkey /root/ca/private/ca.key.pem -out /home/intermediate.crt -days 365 -sha512 -CAcreateserial -extensions v3_ca -extfile openssl.cnf


```
