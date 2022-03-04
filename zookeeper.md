### Access zookeeper znode 

When we get below error
```
Authentication is not valid : /znode
```

znode only allow specific user to access.
There are multuple ways to access that zonde

##### Method I : 

a. Create a jaas file with below content and kinit with user principal 

Create the `zookeeper_client_jaas.conf` file.
```
Client {
com.sun.security.auth.module.Krb5LoginModule required
useKeyTab=false
useTicketCache=true;
}; 
```
b. run below export cmd and zookeeper client cmd to connect

```
export JVMFLAGS="-Djava.security.auth.login.config=/tmp/zookeeper_client_jaas.conf"
zookeeper-client -server zk:2181
```

Access the znode


##### Method II: 

###### Zookeeper - Super User Authentication and Authorization

1) In `CM --> Zookeeper --> Configuration add the following to "Java Configuration Options for ZooKeeper Server"`
```
    -Dzookeeper.DigestAuthenticationProvider.superDigest=super:cY+9eK20soteVC3fQ83SXDvwlP0=
```
    
This will reset the zookeeper super digest temporarily

2) Restart Zookeeper.  You can do rolling restart if needed.
3) SSH into any of the Zookeeper hosts and launch zookeeper shell:
```
    # zookeeper-client
    # addauth digest super:cloudera
```
and access the znode

```
