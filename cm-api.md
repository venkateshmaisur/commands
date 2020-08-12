## CM api
```
# To check the api version

curl -k -u batchhk:<password> "https://arch-messaging-master0.arch-env.u55l-xcud.cloudera.site/clouderamanager/api/version"


# To check if we are able to fetch the hosts

curl -k -u batchhk:<password> "https://arch-messaging-master0.arch-env.u55l-xcud.cloudera.site/clouderamanager/api/v42/hosts"


# To check if we can fetch cluster details for cluster “arch-messaging”

curl -k -u batchhk:<password> "https://arch-messaging-master0.arch-env.u55l-xcud.cloudera.site/clouderamanager/api/v42/clusters/arch-messaging"


# To fetch the service names and grep to know the Knox service name

curl -k -u batchhk:<password> "https://arch-messaging-master0.arch-env.u55l-xcud.cloudera.site/clouderamanager/api/v42/clusters/arch-messaging/services"|grep name |grep -i knox 

"name" : "knox-99cb",


# To stop the Knox service. The stop command also starts Knox service as Knox is not supposed to be stopped ever.

curl -k -u "batchhk:<password>" -X POST "https://arch-messaging-master0.arch-env.u55l-xcud.cloudera.site/clouderamanager/api/v42/clusters/arch-messaging/services/knox-99cb/commands/stop"
~~~

```
