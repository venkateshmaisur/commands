# 1. Setup Self Signed Certificates.

Prerequisite: Install openssl. For example, on CentOS run yum install openssl

## Create keystore with Self Signed Certificate

`keytool -genkey -keyalg RSA -alias hive -keystore keystore.jks -storepass Welcome -validity 360 -keysize 2048 -dname "CN=c174-node3.squadron-labs.com, OU=SU, O=HWX, L=BNG, ST=KN, C=IN"`

## Export certificate from the keystore
```sh
keytool -export -keystore  keystore.jks -alias hive -file cert.cer -storepass Welcome
```

## Create trustsore by import certificate
```
keytool -import -file cert.cer -alias hive -keystore mytruststore.jks -storepass Welcome
```

# 2. Create and Set Up an Internal CA (OpenSSL)

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

# 3. Obtain a Certificate from a Trusted Third-Party Certification Authority (CA)
Ref: https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.5/bk_security/content/ch_obtain-trusted-cert.html

```sh
1. Use the openssl utility, create the private key: 
* openssl genrsa -out key/privatekey.key 2048 
Use you can an existing privatekey if you have one. 

2. Create the CSR using openssl: 
* openssl req -new -sha256 -key key/privatekey.key -out onegov.nsw.gov.au.csr 

This will prompt for certificate distinguished name starting with Country and then state. Please use the following details to enter in the prompt. You can keep the email empty: 
CN=*.onegov.nsw.gov.au, OU=OneGov GLS, O=Department of Finance Services and Innovation, L=Sydney, ST=New South Wales, C=AU 

This will create a file named onegov.nsw.gov.au.csr with the content similar to below: 
******* 
-----BEGIN CERTIFICATE REQUEST----- 
MIIC6TCCAdECAQAwgaMxCzAJBgNVBAYTAkFVMRgwFgYDVQQIDA9OZXcgU291dGgg 
..... 
..... 
bil1VGtOjlrO2EmYhedxJX5fJKuCIIlPUeznxE0= 
-----END CERTIFICATE REQUEST----- 
******* 

3. You need to provide this file/content (CSR) to the CA authority (Thwate in your case) and then they will sign the certificate and share you the certificate. The format of the certificate may vary. 

4. Please run the following command to delete the existing certificate from the keystore (hive-prd.jksjks) file: 
* keytool -delete -alias alias -keystore /etc/hive/conf/keystore.jks 


5. The below are the steps to import the certificate issued by CA into the keystore: 
* openssl pkcs12 -export -in certificate.crt -inkey key/privatekey.key -name "onegov.nsw.gov.au" -out onegov.nsw.gov.au.p12 

6. Now import the p12 certificate in keystore using the following command: 
* keytool -importkeystore -deststorepass <password> -destkeystore /etc/hive/conf/keystore.jks -srckeystore onegov.nsw.gov.au.p12 -srcstoretype PKCS12 
```
