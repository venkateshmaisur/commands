  # dp-proxy.xml
  
 ```xml
 cd /etc/knox/conf/topologies
 vi dp-proxy.xml
 Topology dp-proxy.xml

<?xml version="1.0" encoding="utf-8"?>
<topology>
  <gateway>
    <provider>
        <role>federation</role>
        <name>SSOCookieProvider</name>
        <enabled>true</enabled>
        <param>
            <name>sso.authentication.provider.url</name>
            <value>https://localhost:8443/gateway/knoxsso/api/v1/websso</value>
        </param>
      </provider>
    <provider><role>identity-assertion</role>
      <name>Default</name>
      <enabled>true</enabled>
    </provider>
   </gateway>

  <service>
    <role>AMBARI</role>
    <url>http://<localhost>:8080</url>
  </service>
  <service>
    <role>AMBARIUI</role>
    <url>http://<localhost>:8080</url>
  </service>
  <service>
    <role>RANGER</role>
    <url>http://<localhost>:6080</url>
  </service>
  <service>
    <role>RANGERUI</role>
    <url>http://<localhost>:6080</url>
  </service>
  <service>
    <role>ATLAS</role>
    <url>http://<localhost>:21000</url>
  </service>
  <service>
    <role>ATLAS-API</role>
    <url>http://<localhost>:21000</url>
  </service>
  <service>
   <role>BEACON</role>    ##The DLM Engine
   <url>http://<localhost>:25968</url>
  </service>

  <service>
   <role>PROFILER-AGENT</role>    <!-- The DSS Agent -->
   <url>http://<localhost>:21900</url>
  </service>

</topology>
 
 ```
 ref: https://docs.hortonworks.com/HDPDocuments/DP/DP-1.2.2/administration/content/dp_configure_knox_gateway_for_dp_and_hdp.html
 
 # token.xml
 
 ```
 In a terminal, SSH to the DP host.
 cd /usr/dp/current/core/bin/certs/
 cat ssl-cert.pem
 ```
 
 ```xml
 <?xml version="1.0" encoding="UTF-8"?>
<topology>
   <uri>https://$KNOX_HOSTNAME_FQDN:8443/gateway/token</uri>
   <name>token</name>
   <gateway>
      <provider>
         <role>federation</role>
         <name>SSOCookieProvider</name>
         <enabled>true</enabled>
         <param>
            <name>sso.authentication.provider.url</name>
            <value>https://$KNOX_HOSTNAME_FQDN:8443/gateway/knoxsso/api/v1/websso</value>
         </param>
         <param>
            <name>sso.token.verification.pem</name>
            <value>
                $ADD_THE_PUBLIC_KEY_HERE
            </value>
         </param>
      </provider>
      <provider>
         <role>identity-assertion</role>
         <name>HadoopGroupProvider</name>
         <enabled>true</enabled>
      </provider>
      
   </gateway>

   <service>
      <role>KNOXTOKEN</role>
      <param>
         <name>knox.token.ttl</name>
         <value>100000</value>
      </param>
      <param>
         <name>knox.token.client.data</name>
         <value>cookie.name=hadoop-jwt</value>
      </param>
      <param>
         <name>main.ldapRealm.authorizationEnabled</name>
         <value>true</value>
      </param>
   </service>
</topology>
 ```
 
 # redirect.xml
 
 ```xml
 <topology>
    <name>tokensso</name>
    <gateway>
        <provider>
            <role>federation</role>
            <name>JWTProvider</name>
            <enabled>true</enabled>
        </provider>
        <provider>
            <role>identity-assertion</role>
            <name>Default</name>
            <enabled>true</enabled>
        </provider>
    </gateway>
    <service>
        <role>KNOXSSO</role>
        <param>
            <name>knoxsso.cookie.secure.only</name>
            <value>true</value>
        </param>
        <param>
            <name>knoxsso.token.ttl</name>
            <value>600000</value>
        </param>
        <param>
            <name>knoxsso.redirect.whitelist.regex</name>
            <value>^https?:\/\/(DOMAIN_OF_CLUSTER|localhost|127\.0\.0\.1|0:0:0:0:0:0:0:1|::1):[0-9].*$</value>
        </param>
    </service>
</topology> 
```
