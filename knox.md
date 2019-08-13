# Knox troubleshooting

##### Use LB for KnoxSSO where you have multiple knox instances

```sh 
-->Create a new keystore: 

#keytool -genkey -keystore knoxSSO.jks -alias knoxsso -keyalg rsa -keysize 2048 

(First name and Lastname is set as KnoxSSO, or it can be anything) 

-->Create passphrase alias, here the passphrase alias prompts for the password, which is same password set for knoxSSO.jks in step1 

# /usr/hdp/current/knox-server/bin/knoxcli.sh create-alias signing.key.passphrase --cluster knoxsso 

-->Extract the public key from the knox SSO.jks which is in the DER format, 
# /usr/jdk64/jdk1.8.0_112/bin/keytool -export -file /tmp/sign.crt -alias knoxsso -keystore knoxSSO.jks 

-->Convert the DER to PEM format which can be used configure ambari server jwt-cert.pem 

# openssl x509 -in /tmp/sign.crt -inform DER -outform PEM 

(copy the content and in the file /etc/ambari-server/conf/jwt-cert.pem) 

-->Copy the knoxSSO.jks to keystore path of knox 

#cp /var/tmp/knoxSSO.jks /usr/hdp/current/knox-server/data/security/keystores/ 

-->Copy the knoxSSO.jks to the second knox instance: 
#scp knoxSSO.jks <knox2>:/usr/hdp/current/knox-server/data/security/keystores/ 

-->On Knox 2 host create the passphrase alias(step was done on knox 1 already): 
# /usr/hdp/current/knox-server/bin/knoxcli.sh create-alias signing.key.passphrase --cluster knoxsso 

Configure gateway-site with below two properties: 

Ambari>Knox>Configs>Custom gateway-site>Add 

gateway.signing.keystore.name=knoxSSO.jks 
gateway.signing.key.alias=knoxsso
```
