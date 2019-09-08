# Install Gnome Desktop on CentOS 6, Configure VNC Server and install Oracle Database 11g Release 2

```sh
yum groupinstall "X Window System" -y
yum -y groupinstall "Desktop"
yum -y groupinstall "General Purpose Desktop"
yum install -y xorg-x11-apps java gnome-core xfce4 firefox expect tigervnc-server
service messagebus restart
chkconfig vncserver on
```
##### Configure VNC Server
```sh
useradd -p $(echo Welcome | openssl passwd -1 -stdin) oracle
su oracle
#!/bin/sh
prog=/usr/bin/vncpasswd
mypass="Welcome"

/usr/bin/expect <<EOF
spawn "$prog"
expect "Password:"
send "$mypass\r"
expect "Verify:"
send "$mypass\r"
expect eof
exit
EOF
exit
echo "vncpasswd configure"

echo "configuring VNC server..............."
echo "VNCSERVERS="1:oracle"" >> /etc/sysconfig/vncservers
echo 'VNCSERVERARGS[1]="-geometry 1024x768"' >> /etc/sysconfig/vncservers

service vncserver restart
pkill vnc
echo "exec gnome-session &" >> /home/oracle/.vnc/xstartup
```
##### Install Oracle 11.g R2

```sh
cd /etc/yum.repos.d
yum install wget ntp mlocate -y
wget https://public-yum.oracle.com/public-yum-ol6.repo
wget https://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol6 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
yum install oracle-rdbms-server-11gR2-preinstall -y

echo "*       -       nproc           16384"  >>  /etc/security/limits.d/90-nproc.conf
chkconfig iptables off
/etc/init.d/iptables stop
setenforce 0
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
sestatus
/etc/init.d/network restart

cat > ~/.bash_profile <<EOF
HOSTNAME=$(hostname -f)
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR

ORACLE_HOSTNAME=${HOSTNAME}; export ORACLE_HOSTNAME
ORACLE_UNQNAME=DB11G; export ORACLE_UNQNAME
ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1; export ORACLE_HOME
ORACLE_SID=DB11G; export ORACLE_SID
PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH export PATH
EOF

mkdir -p /u01/app/oracle/product/11.2.0/dbhome_1
chown -R oracle:oinstall /u01
chmod -R 775 /u01

wget https://www.oracle.com/webapps/redirect/signon?nexturl=https://download.oracle.com/otn/linux/oracle11g/R2/linux.x64_11gR2_database_1of2.zip
wget https://www.oracle.com/webapps/redirect/signon?nexturl=https://download.oracle.com/otn/linux/oracle11g/R2/linux.x64_11gR2_database_2of2.zip

unzip linux_11gR2_database_1of2.zip
unzip linux_11gR2_database_2of2.zip


DISPLAY=hostname:0.0;export DISPLAY
```

##### Login into VNC server, enable port forwarding:
```sh
ssh -L 5901:127.0.0.1:5901 -N -f -l oracle <db-hostname>
```

##### Acess VNC server using localhost:5901
```sh
cd database
./runInstaller
```
Ref: https://www.tecmint.com/oracle-database-11g-release-2-installation-in-linux/

