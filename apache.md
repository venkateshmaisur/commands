# Apache Loadbalancer

```sh
cd /usr/local
wget https://archive.apache.org/dist/httpd/httpd-2.4.16.tar.gz
wget https://archive.apache.org/dist/apr/apr-1.5.2.tar.gz 
wget https://archive.apache.org/dist/apr/apr-util-1.5.4.tar.gz
tar -xvf httpd-2.4.16.tar.gz
tar -xvf apr-1.5.2.tar.gz 
tar -xvf apr-util-1.5.4.tar.gz
mv apr-1.5.2/ apr
mv apr httpd-2.4.16/srclib/ 
mv apr-util-1.5.4/ apr-util
mv apr-util httpd-2.4.16/srclib/
yum groupinstall "Development Tools" -y
yum install openssl-devel pcre-devel -y 
cd /usr/local/httpd-2.4.16
./configure --enable-so --enable-ssl --with-mpm=prefork --with-included-apr
make && make install
cd /usr/local/apache2/bin
./apachectl start
curl localhost
```

#### Edit the httpd.conf file:
```sh
vi /usr/local/apache2/conf/httpd.conf
add
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule proxy_ajp_module modules/mod_proxy_ajp.so            
LoadModule proxy_balancer_module modules/mod_proxy_balancer.so
LoadModule slotmem_shm_module modules/mod_slotmem_shm.so
LoadModule lbmethod_byrequests_module modules/mod_lbmethod_byrequests.so
LoadModule lbmethod_bytraffic_module modules/mod_lbmethod_bytraffic.so
LoadModule lbmethod_bybusyness_module modules/mod_lbmethod_bybusyness.so
LoadModule ssl_module modules/mod_ssl.so
```

#### Run the following command to restart the httpd server:
`/usr/local/apache2/bin/apachectl restart`

#### Create a custom conf file for the load-balancer SSL configuration:
`vi /usr/local/apache2/conf/ranger-lb-ssl.conf`
```sh
<VirtualHost *:8443>

        SSLEngine On
        SSLProxyEngine On
        SSLCertificateFile /usr/local/apache2/conf/server.crt
        SSLCertificateKeyFile /usr/local/apache2/conf/server.key

        #SSLCACertificateFile /usr/local/apache2/conf/ranger_lb_crt.pem
        #SSLProxyCACertificateFile /usr/local/apache2/conf/ranger_lb_crt.pem
        SSLVerifyClient optional
        SSLOptions +ExportCertData
        SSLProxyVerify none
        SSLProxyCheckPeerCN off
        SSLProxyCheckPeerName off
        SSLProxyCheckPeerExpire off
        ProxyRequests off
        ProxyPreserveHost off

        Header add Set-Cookie "ROUTEID=.%{BALANCER_WORKER_ROUTE}e; path=/" env=BALANCER_ROUTE_CHANGED

        <Proxy balancer://rangercluster>
               BalancerMember http://172.22.71.39:6080 loadfactor=1 route=1
               BalancerMember http://172.22.71.38:6080 loadfactor=1 route=2
        

                Order Deny,Allow
                Deny from none
                Allow from all

                ProxySet lbmethod=byrequests scolonpathdelim=On stickysession=ROUTEID maxattempts=1 failonstatus=500,501,502,503 nofailover=Off
        </Proxy>

        # balancer-manager
        # This tool is built into the mod_proxy_balancer
        # module and will allow you to do some simple
        # modifications to the balanced group via a gui
        # web interface.
        <Location /balancer-manager>
                SetHandler balancer-manager
                Order deny,allow
                Allow from all
        </Location>


       ProxyPass /balancer-manager !
       ProxyPass / balancer://rangercluster/
       ProxyPassReverse / balancer://rangercluster/

</VirtualHost>
```


Ref: https://docs.cloudera.com/HDPDocuments/HDP3/HDP-3.1.4/fault-tolerance/content/configuring_ranger_admin_ha_with_ssl.html
