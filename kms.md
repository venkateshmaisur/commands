```sh
=============
Key Trustee KMS
=============

useradd keyadmin
useradd pravin


hadoop.kms.acl.CREATE= keyadmin keyadmingroup
hadoop.kms.acl.GET_KEYS= keyadmin,pravin keyadmingroup



#as hdfs create dirs for EZs
sudo -u hdfs hdfs dfs -mkdir /zone_encr
sudo -u hdfs hdfs dfs -mkdir /zone_encr2

sudo -u hdfs hdfs dfs -chown pravin /zone_encr
sudo -u hdfs hdfs dfs -chown pravin /zone_encr2

# create keys
sudo -u keyadmin hadoop key create testkey
sudo -u keyadmin hadoop key create testkey2

#as pravin list the keys and their metadata
sudo -u pravin hadoop key list -metadata


[root@c474-node4 ~]# sudo -u pravin hadoop key list
Listing keys for KeyProvider: org.apache.hadoop.crypto.key.kms.LoadBalancingKMSClientProvider@510f3d34
testkey2
testkey

#as hdfs create 2 EZs using the 2 keys
sudo -u hdfs hdfs crypto -createZone -keyName testkey -path /zone_encr
sudo -u hdfs hdfs crypto -createZone -keyName testkey2 -path /zone_encr2

#check EZs got created
sudo -u hdfs hdfs crypto -listZones  

#create test files
sudo -u pravin echo "My test file1" > /tmp/test1.log
sudo -u pravin echo "My test file2" > /tmp/test2.log

#copy files to EZs
sudo -u pravin hdfs dfs -copyFromLocal /tmp/test1.log /zone_encr
sudo -u pravin hdfs dfs -copyFromLocal /tmp/test2.log /zone_encr

sudo -u pravin hdfs dfs -copyFromLocal /tmp/test2.log /zone_encr2

sudo -u pravin hdfs dfs -cat /zone_encr/test1.log
sudo -u pravin hdfs dfs -cat /zone_encr2/test2.log

sudo -u pbhagade hdfs dfs -cat /zone_encr/test1.log



#try to remove file from EZ using usual -rm command 
sudo -u pravin hdfs dfs -rm /zone_encr/test2.log

#confirm that test2.log was deleted and that zone_encr only contains test1.log
sudo -u pravin hdfs dfs -ls  /zone_encr/

#copy a file between EZs using distcp with -skipcrccheck option
sudo -u pravin hadoop distcp -skipcrccheck -update /zone_encr2/test2.log /zone_encr/
```

```
ERROR:
======[root@c474-node4 ~]# sudo -u pravin hadoop key list -metadata
Listing keys for KeyProvider: org.apache.hadoop.crypto.key.kms.LoadBalancingKMSClientProvider@510f3d34
Cannot list keys for KeyProvider: org.apache.hadoop.crypto.key.kms.LoadBalancingKMSClientProvider@510f3d34
list [-provider <provider>] [-strict] [-metadata] [-help]:

The list subcommand displays the keynames contained within
a particular provider as configured in core-site.xml or
specified with the -provider argument. -metadata displays
the metadata. If -strict is supplied, fail immediately if
the provider requires a password and none is given.
Executing command failed with the following exception: AuthorizationException: User [pravin] is not authorized to perform [READ] on key with ACL name [testkey]!!
```

===> 
default.key.acl.READ=pravin

```
ERROR:
=======
copyFromLocal: User [pravin] is not authorized to perform [DECRYPT_EEK] on key with ACL name [testkey]!!
```
default.key.acl.DECRYPT_EEK=pravin



ADD ->
key.acl.testkey.DECRYPT_EEK=pravin
