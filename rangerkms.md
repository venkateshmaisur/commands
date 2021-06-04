# Rangerkms

### CDP

```
# Create encryption zones

export NAMENODE_PROCESS_DIR=$(ls -1dtr /var/run/cloudera-scm-agent/process/*hdfs-NAMENODE| tail -1)
kinit -kt $NAMENODE_PROCESS_DIR/hdfs.keytab hdfs/`hostname -f`
hadoop key list
hdfs dfs -mkdir /enczone1
hdfs crypto -createZone -keyName key1 -path /enczone1
hdfs crypto -listZones 

echo "Hello TDE" >> myfile.txt
hadoop dfs -put myfile.txt /enczone1
hdfs dfs -chmod 700 /enczone1



$ hdfs dfs -cat /enczone1/myfile.txt

==> access_log2021-06-04.07.log <==
172.27.133.6 - - [04/Jun/2021:07:54:16 +0000] "OPTIONS /kms/v1/keyversion/key1%400/_eek" 200 644
172.27.133.6 - - [04/Jun/2021:07:54:16 +0000] "POST /kms/v1/keyversion/key1%400/_eek" 200 86
172.27.187.13 - - [04/Jun/2021:07:54:17 +0000] "GET /kms/api/status" 200 53


# List a Directory
https://hadoop.apache.org/docs/r1.0.4/webhdfs.html#LISTSTATUS
curl -ik --negotiate -u :  "https://pbhagade-3.pbhagade.root.hwx.site:20102/webhdfs/v1/enczone1?op=LISTSTATUS"

# Open and Read a File
curl -i -L "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=OPEN
                    [&offset=<LONG>][&length=<LONG>][&buffersize=<INT>]"

curl -ik --negotiate -u :  "https://pbhagade-3.pbhagade.root.hwx.site:20102/webhdfs/v1/enczone1/myfile.txt?op=OPEN"                    

# Location: https://pbhagade-2.pbhagade.root.hwx.site:9865/webhdfs/v1/enczone1/myfile.txt?op=OPEN&delegation=IAAGcHJhdmluBnByYXZpbgCKAXnWDA4OigF5-hiSDh0UFFJCJRjYyffNeFSLHbJN_9cHVGuEE1NXRUJIREZTIGRlbGVnYXRpb24SMTcyLjI3LjE4Ny4xMzo4MDIw&namenoderpcaddress=nameservice1&offset=0

++++++++++++
WWW-Authenticate: Negotiate YGwGCSqGSIb3EgECAgIAb10wW6ADAgEFoQMCAQ+iTzBNoAMCARCiRgRENLnAJ54II818HzDSehFSlaqiX5UTcVURW8ae2aJa/MG4bqdfmpZ3ezexxVgAtdfrQ0u45TH7ZsPapqB9lXxNcP47w+I=
Set-Cookie: hadoop.auth="u=pravin&p=pravin@ROOT.HWX.SITE&t=kerberos&e=1622829784843&s=cWmqgcx4kqUVLgGZtgK7P6/On0ByINf8KwJ4l+hc1sg="; Path=/; Secure; HttpOnly
Location: https://pbhagade-2.pbhagade.root.hwx.site:9865/webhdfs/v1/enczone1/myfile.txt?op=OPEN&delegation=IAAGcHJhdmluBnByYXZpbgCKAXnWDA4OigF5-hiSDh0UFFJCJRjYyffNeFSLHbJN_9cHVGuEE1NXRUJIREZTIGRlbGVnYXRpb24SMTcyLjI3LjE4Ny4xMzo4MDIw&namenoderpcaddress=nameservice1&offset=0
Content-Type: application/octet-stream
Content-Length: 0

[pravin@pbhagade-2 318-hdfs-NAMENODE]$ curl -ik --negotiate -u :  "https://pbhagade-2.pbhagade.root.hwx.site:9865/webhdfs/v1/enczone1/myfile.txt?op=OPEN&delegation=IAAGcHJhdmluBnByYXZpbgCKAXnWDA4OigF5-hiSDh0UFFJCJRjYyffNeFSLHbJN_9cHVGuEE1NXRUJIREZTIGRlbGVnYXRpb24SMTcyLjI3LjE4Ny4xMzo4MDIw&namenoderpcaddress=nameservice1&offset=0"
HTTP/1.1 403 Forbidden
Content-Type: application/json; charset=utf-8
Content-Length: 200
Connection: close

{"RemoteException":{"exception":"AuthorizationException","javaClassName":"org.apache.hadoop.security.authorize.AuthorizationException","message":"User:hdfs not allowed to do 'DECRYPT_EEK' on 'key1'"}}
++++++++++++++++

```
