## Apache Loadbalancer
# https://docs.cloudera.com/HDPDocuments/HDP3/HDP-3.1.5/fault-tolerance/content/configuring_ranger_admin_ha_with_ssl.html
#/bin/bash
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
yum install openssl-devel -y
yum install pcre-devel -y
cd /usr/local/httpd-2.4.16
./configure --enable-so --enable-ssl --with-mpm=prefork --with-included-apr
make && make install
cd /usr/local/apache2/bin
./apachectl start
cd /usr/local/apache2/conf
cp httpd.conf ~/httpd.conf.backup
