# Install Gnome Desktop on CentOS 6, Configure VNC Server and install Oracle Database 11g Release 2

```sh
yum clean all & yum update all & yum update -y
yum -y groupinstall "X Window System" 
yum -y groupinstall "Desktop"
yum -y groupinstall "General Purpose Desktop"
yum -y install xorg-x11-apps java gnome-core xfce4 firefox expect tigervnc-server wget ntp mlocate
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
# reboot
```
##### Install Oracle 11.g R2

```sh
cd /etc/yum.repos.d
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

cat >> ~/.bash_profile <<EOF
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

------------------------------------------------------------------------------------------------------------------------------------------------------------

# Centos 7 Oracle 12c r2

### Install Gnome GUI on CentOS 7 / RHEL 7
 https://www.itzgeek.com/how-tos/linux/centos-how-tos/install-gnome-gui-on-centos-7-rhel-7.html
```bash
yum groupinstall "GNOME Desktop" "Graphical Administration Tools" -y
ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target
reboot

yum install -y tigervnc-server xorg-x11-fonts-Type1 -y

cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:5.service
vi /etc/systemd/system/vncserver@:5.service

useradd oracle
passwd oracle
su oracle
vncserver
su -
systemctl daemon-reload
systemctl restart vncserver@:5.service
```
## 
oracle
https://medium.com/@anuketjain007/how-to-install-oracle-database-12c-release-2-in-linux-7-35923db49487
https://www.tecmint.com/install-oracle-database-12c-on-centos-7/

wget https://download.oracle.com/otn/linux/oracle12c/122010/linuxx64_12201_database.zip?AuthParam=1604678623_6312bff246bda3a3c5a35576a25943ec


https://host-10-17-103-192.coe.cloudera.com:5500/em

#### SQL Developer queries

```sql
select * from dba_tablespaces;
select * from v$tablespace;
select * from dba_data_files;

create TABLESPACE example datafile'/u01/app/oracle/oradata/orcl/example.dbf' size 800m;
alter session set "_ORACLE_SCRIPT"=true;  
CREATE USER USERB IDENTIFIED BY "Welcome" DEFAULT TABLESPACE example TEMPORARY TABLESPACE TEMP PROFILE DEFAULT ACCOUNT UNLOCK;

GRANT SELECT_CATALOG_ROLE TO USERB;
GRANT CONNECT, RESOURCE TO USERB; 
GRANT CREATE SESSION TO USERB;

connect USERB;

select user from dual;

SELECT 
    username, 
    default_tablespace, 
    profile, 
    authentication_type
FROM
    dba_users
WHERE 
    account_status = 'OPEN';


## Drop
alter session set "_ORACLE_SCRIPT"=true; 
DROP TABLESPACE example INCLUDING CONTENTS;
DROP USER USERB CASCADE;

SQL> drop table X_DB_VERSION_H;
SQL> DROP SEQUENCE X_DB_VERSION_H_SEQ;
```

## Example:

```sql
SELECT 
    username, 
    default_tablespace, 
    profile, 
    authentication_type
FROM
    dba_users
WHERE 
    account_status = 'OPEN';

SELECT * FROM user_users;

alter session set "_ORACLE_SCRIPT"=true; 
DROP TABLESPACE RANGERTEST INCLUDING CONTENTS;
DROP USER RANGERDBA11 CASCADE;

create TABLESPACE RANGERTEST datafile'/u01/app/oracle/oradata/orcl/RANGERTEST.dbf' size 500m;
CREATE USER RANGERDBA11 IDENTIFIED BY "Welcome" DEFAULT TABLESPACE RANGERTEST TEMPORARY TABLESPACE TEMP PROFILE DEFAULT ACCOUNT UNLOCK;

GRANT SELECT_CATALOG_ROLE TO RANGERDBA11;
GRANT CONNECT, RESOURCE TO RANGERDBA11; 
GRANT CREATE SESSION TO RANGERDBA11;
GRANT CREATE VIEW TO RANGERDBA11;
GRANT UNLIMITED TABLESPACE TO RANGERDBA11;
```

`select username, default_tablespace from user_users;`

![Ranger Oracle](https://github.com/bhagadepravin/commands/blob/master/jpeg/image%20(5).png)


## Oracle Setup via Docker
```sql
oracle

https://dbtut.com/index.php/2020/01/09/how-to-install-oracle-database-in-docker/

docker pull store/oracle/database-enterprise:12.2.0.1

download sqlplus:

https://www.oracle.com/tools/downloads/sqlcl-downloads.html
cd ~/Downloads
#Note: version/filename of file will change for each release
unzip sqlcl-19.2.1.206.1649.zip

#Assuming you already have an /oracle directory (I had one for the instant client)
cp -r sqlcl /oracle

#Give sqlcl execute permission
cd /oracle/sqlcl/bin
chmod 755 sql

#rename to sqlcl so no confusion (optional)
mv sql sqlcl

#Add directory to path so can run anywhere in the command line:

#Temporary access:
PATH=$PATH:/oracle/sqlcl/bin

#Permanent access:
#Note: See Barry's comment below about storing in /etc/paths.d on Mac
vi ~/.bash_profile
#Add just above the export PATH line
PATH=$PATH:/oracle/sqlcl/bin


Use below cmd to connect,grant:
sqlcl system/Welcome@//localhost:1521/ORCLPDB1
 grant connect, resource to pravin identified by Welcome;
conn pravin/Welcome@//localhost:1521/ORCLPDB1


alter session set "_ORACLE_SCRIPT"=true;
create user oracle identified by oracle;

GRANT ALL PRIVILEGES TO oracle;
grant sysdba to oracle;

```
