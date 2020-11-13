# SSL commands

```sh
echo -n | openssl s_client -connect <hostname>:<port> | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/examplecert.crt
```

##### Convert DER to PEM
```sh
openssl x509 -inform der -in certificate.cer -out certificate.pem
```

##### Convert P7B to PEM
```sh
openssl pkcs7 -print_certs -in certificate.p7b -out certificate.pem
```

##### Convert PFX to PEM
```sh
openssl pkcs12 -in certificate.pfx -out certificate.pem -nodes
```

##### View certificate

```sh
openssl x509 -in certificate.pem -text -noout
```

##### Create pkcs12 cert
```sh
openssl pkcs12 -export -out /root/ca/intermediate/private/ranger-plugin.pkcs12 -inkey /root/ca/intermediate/private/client.key.pem -in /root/ca/intermediate/certs/client.cert.pem -certfile /root/ca/certs/ca.cert.pem -certfile /root/ca/intermediate/certs/intermediate.cert.pem
```

##### Create a keystore in PKCS12 format from your private key file, certificate and root public certificate
```sh
openssl pkcs12 -export -out corp_cert_chain.pfx -inkey <private-key>.key -in <cert.cer> -certfile <root_intermediate>.cer
```

##### Export the private key file from the pfx file
```sh
openssl pkcs12 -in filename.pfx -nocerts -out key.pem
```

##### Export the certificate file from the pfx file
```sh
openssl pkcs12 -in filename.pfx -clcerts -nokeys -out cert.pem
```

##### Remove the passphrase from the private key
```sh
openssl rsa -in key.pem -out server.key
```

##### Convert .p7b file to .pem
```sh
openssl pkcs7 -print_certs -in wildcard_intermediate_ca_.p7b -out file.pem
```

##### Export .pem with private key in .p12
```sh
openssl pkcs12 -export -name Wildcard -in file.pem -inkey wildcard_intermediate_ca_.key -out file.p12
```

##### Import .p12 file in keystore
```sh
keytool -importkeystore -srcstoretype pkcs12 -srckeystore file.p12 -destkeystore file.jks
```

```sh
keytool -importkeystore -srckeystore [MY_FILE.p12] -srcstoretype pkcs12 -srcalias [ALIAS_SRC] -destkeystore [MY_KEYSTORE.jks] -deststoretype jks -deststorepass [PASSWORD_JKS] -destalias [ALIAS_DEST]
```

# Internal CA
```shell
1. Create CA key pair 
openssl req -new -x509 -keyout ca.key -out ca.crt -days 365

2. Generate server key (server.keystore.jks) with extensions
keytool -keystore server.keystore.jks -alias gal4.openstacklocal -validity 365 -genkey -keyalg RSA -ext EKU:true=clientAuth,serverAuth -storepass hadoop

3. Generate CSR with extensions (critical!)
keytool -certreq -keystore server.keystore.jks -storepass hadoop -alias gal4.openstacklocal -file server.csr -ext EKU:true=clientAuth,serverAuth

4. Check content of CSR via any of these commands (you should see extensions in the output)
keytool -printcertreq -file server.csr -v
openssl req -in server.csr -text -noout

5. Sign the CSR with CA from step#1 (notice the new ca.ext file)
openssl x509 -req -CA ca.crt -CAkey ca.key -in server.csr -out server.signed.crt -days 365 -CAcreateserial -passin pass:hadoop -extfile ca.ext

Where ca.ext has these two lines:
extendedKeyUsage = serverAuth, clientAuth
basicConstraints = CA:FALSE

6. Check content of new server.signed.crt via any of these commands (you should see extensions in the output)
keytool -printcert -file server.signed.crt -v
openssl x509 -in server.signed.crt -text -noout

7. Finally, lets import root CA cert and above signed cert back into server.keystore.jks:
keytool -import -keystore server.keystore.jks -storepass hadoop -alias CARoot -file ca.crt
keytool -import -keystore server.keystore.jks -storepass hadoop -alias gal4.openstacklocal -file server.signed.crt

8. Import root CA cert in a new truststore:
keytool -import -keystore server.truststore.jks -storepass hadoop -alias CARoot -file ca.crt
```

```sh
openssl s_client -connect <HS@-hostname>:<port> -tls1

openssl s_client -connect <HS@-hostname>:<port> -tls1_1

openssl s_client -connect <HS@-hostname>:<port> -tls1_2
```
  
  ##### Create a keystore JKS
  ```sh
  Create a keystore in PKCS12 format from your private key file, certificate and root public certificate
[~]$ openssl pkcs12 -export -out corp_cert_chain.pfx -inkey <private-key>.key -in <cert.cer> -certfile <root_intermediate>.cer

Generate  keystore
[~]$ keytool -importkeystore  -srckeystore corp_cert_chain.pfx -srcstoretype pkcs12 -destkeystore keystore.jks -deststoretype jks -srcstorepass password -deststorepass password -destkeypass <password>
```

## LLAP Slider agent SSL
```java
openssl genrsa -des3 -passout pass:**** -out /tmp/sec1568724372347/security/ca.key 4096 

openssl req -passin pass:**** -new -key /tmp/sec1568724372347/security/ca.key -out /tmp/sec1568724372347/security/ca.csr -config /tmp/sec1568724372347/security/ca.config -subj /CN=squadron.support.hortonworks.com/OU=container_e13_1568701214962_0001_01_000001/OU=llap0 -batch 

openssl ca -create_serial -out /tmp/sec1568724372347/security/ca.crt -days 365 -keyfile /tmp/sec1568724372347/security/ca.key -key kQY4KiLDQBOHmE5o86l1PjLQcghWrvpPJ7btZKm04evyhBbgv1 -selfsign -extensions jdk7_ca -config /tmp/sec1568724372347/security/ca.config -batch -infiles /tmp/sec1568724372347/security/ca.csr 

openssl pkcs12 -export -in /tmp/sec1568724372347/security/ca.crt -inkey /tmp/sec1568724372347/security/ca.key -certfile /tmp/sec1568724372347/security/ca.crt -out /tmp/sec1568724372347/security/keystore.p12 -password pass:**** -passin pass:**** 


# keytool -importkeystore -deststorepass changeit -destkeypass changeit -destkeystore myServerKeystore.jks -srckeystore /etc/pki/tls/tomcat6-CAS-certs/216-113-229-31-serverCertAsPK12.p12  -srcstoretype PKCS12 -alias servercertificate 

++++++++++++++++++
keytool -list -keystore keystore1.p12 -storetype PKCS12 -v -storepass hadoop@12345

# keytool -importkeystore -deststorepass hadoop@12345 -destkeypass hadoop@12345 -destkeystore myServerKeystore.jks -srckeystore keystore1.p12  -srcstoretype PKCS12 -alias 1 

# keytool -list -keystore myServerKeystore.jks -storepass hadoop@12345 -v

```

## Self Signed cert. using keytool
```java
# Create self signed cert
keytool -genkey -alias `hostname` -keyalg RSA -keysize 1024 -dname "CN=`hostname -f`,OU=SU,O=HWX,L=BNG,ST=KN,C=IN" -keypass Welcome -keystore keystore.jks -storepass Welcome -keypass Welcome

# Export certificate
keytool -export -alias  `hostname` -keystore keystore.jks -file  ams1.crt -storepass Welcome

# Create trustStore
keytool -import -file ams1.crt -keystore truststore.jks -alias  `hostname`-trust  -storepass Welcome
```


## SSL ciper

```
 nmap -sV --script ssl-enum-ciphers -p 8443 pbhagade-1.pbhagade.root.hwx.site
 ```
 
 ```
 #!/bin/bash
# OpenSSL requires the port number.
SERVER=$1
DELAY=1
ciphers=$(openssl ciphers 'ALL:eNULL' | sed -e 's/:/ /g')
echo Obtaining cipher list from $(openssl version)
for cipher in ${ciphers[@]}
do
echo -n Testing $cipher...
result=$(echo -n | openssl s_client -cipher "$cipher" -connect $SERVER 2>&1)
if [[ "$result" =~ ":error:" ]] ; then
  error=$(echo -n $result | cut -d':' -f6)
  echo NO \($error\)
else
  if [[ "$result" =~ "Cipher is ${cipher}" || "$result" =~ "Cipher    :" ]] ; then
    echo YES
  else
    echo UNKNOWN RESPONSE
    echo $result
  fi
fi
sleep $DELAY
done
 ```
 
 https://www.openssl.org/docs/man1.0.2/man1/ciphers.html
