### Access zookeeper znode 

 znode only allow HTTP user to access.
There are multuple ways to access zonde

1. 
a. Create a jaas file with below content and kinit with HTTP principal 

Create the zookeeper_client_jaas.conf file.
```
Client {
com.sun.security.auth.module.Krb5LoginModule required
useKeyTab=false
useTicketCache=true;
}; 
```

`export JVMFLAGS="-Djava.security.auth.login.config=/tmp/zookeeper_client_jaas.conf"`

`zookeeper-client -server zk:2181`

access the znode


2. second method i
#### Zookeeper - Super User Authentication and Authorization

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
