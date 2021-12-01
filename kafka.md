# Kafka Commands

cdp-dc
https://gist.github.com/rajkrrsingh/e134510d43d47284521b451d021da56f

```
[root@pravin-1 225-kafka-KAFKA_BROKER]# export KAFKA_OPTS='-Djava.security.auth.login.config=/tmp/jaas1.conf'
[root@pravin-1 225-kafka-KAFKA_BROKER]# cat /tmp/jaas1.conf
KafkaClient {
com.sun.security.auth.module.Krb5LoginModule required
useKeyTab=true
keyTab="/var/run/cloudera-scm-agent/process/225-kafka-KAFKA_BROKER/kafka.keytab"
   principal="kafka/pravin-1.pravin.root.hwx.site@ROOT.HWX.SITE";
};
[root@pravin-1 225-kafka-KAFKA_BROKER]# cat /tmp/client.properties
sasl.kerberos.service.name=kafka
security.protocol=SASL_SSL
ssl.truststore.location = /var/run/cloudera-scm-agent/process/225-kafka-KAFKA_BROKER/cm-auto-global_truststore.jks
ssl.truststore.password = 6mYXWUW14va4Y7ZKzAPhhCCO7simpuQHu2YisTlyuuf
[root@pravin-1 225-kafka-KAFKA_BROKER]# kafka-topics --list --bootstrap-server `hostname -f`:9093 --command-config /tmp/client.properties
```
https://docs.cloudera.com/HDPDocuments/HDP3/HDP-3.1.5/authentication-with-kerberos/content/kerberos_kafka_jaas_configuration_file_for_the_kafka_client.html

####### Configuring Kafka Producer and Kafka Consumer
https://docs.cloudera.com/cdp-private-cloud-base/7.1.5/kafka-managing/topics/kafka-manage-cli-overview.html
https://docs.cloudera.com/HDPDocuments/HDP3/HDP-3.0.1/configuring-wire-encryption/content/configuring_kafka_producer_and_kafka_consumer.html

## List
```sh
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --list --zookeeper `hostname -f`:2181
```

## Create
```sh
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --create --topic ATLAS_HOOK --zookeeper `hostname -f`:2181 --partitions 1 --replication-factor 1
```

## Describe topics
```sh
cd /usr/hdp/current/kafka-broker/bin
./kafka-topics.sh --describe --zookeeper <zkHost>:<zkPort> --topic <TopicName>
./kafka-topics.sh --describe --zookeeper `hostname -f`:2181 --topic ATLAS_HOOK
./kafka-topics.sh --describe --zookeeper `hostname -f`:2181 --topic ATLAS_ENTITIES
./kafka-topics.sh --describe --zookeeper `hostname -f`:2181 --topic __consumer_offsets
```

## List Consumer Group
```
./kafka-consumer-groups.sh --bootstrap-server <broker host>:6667 --list --security-protocol SASL_PLAINTEXT
```

## hdp 3.0

```
cat client.properties
security.protocol=SASL_PLAINTEXT
```
```sh
/usr/hdp/current/kafka-broker/bin/kafka-consumer-groups.sh --bootstrap-server <broker host>:6667 --list --command-config /root/client.properties
```

##### HDP 3.1.5 on kerberos env
```
cd /usr/hdp/current/kafka-broker/bin
./kafka-consumer-groups.sh --bootstrap-server <broker host>:6667 --list --consumer-property security.protocol=SASL_PLAINTEXT

cat client.properties
security.protocol=SASL_PLAINTEXT
./kafka-consumer-groups.sh --bootstrap-server <broker host>:6667 --list  --command-config /tmp/client.properties

./kafka-console-consumer.sh --bootstrap-server  <broker host>:6667 --topic ATLAS_ENTITIES --from-beginning --consumer-property security.protocol=SASL_PLAINTEXT
```

We will collect the lag on hourly bases for 24 hrs.

```bash
while true; do date; /usr/hdp/current/kafka-broker/bin/kafka-consumer-groups.sh --describe --bootstrap-server  <broker host>:6667 --group atlas --security-protocol SASL_PLAINTEXT >> /tmp/atlas-lag.txt; sleep 3600; done  > /dev/null &
```

## Describe Consumer Group
```sh
./kafka-consumer-groups.sh --describe --bootstrap-server <broker host>:6667 --group atlas --security-protocol SASL_PLAINTEXT
```

## Let's see what kind of message is flowing in this topic:
```sh
./kafka-console-consumer.sh --zookeeper `hostname -f`:2181 --topic ATLAS_HOOK --from-beginning
```

## Console Producer :
```sh
/usr/hdp/current/kafka-broker/bin/kafka-console-producer.sh --broker-list <broker-hostname:port> --topic <topic-name>
```

## Console Consumer:
```sh
/usr/hdp/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server <BROKER_HOST:PORT> --topic <TOPIC-NAME>
```

## Delete
```sh
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --delete --topic ATLAS_ENTITIES --zookeeper `hostname -f`:2181
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --delete --topic ATLAS_HOOK --zookeeper `hostname -f`:2181
```

delete.topic.enable=true. == it will delete the topics which are marked for delete

## Delete kafka topic from ZK

```sh
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --delete --topic ATLAS_HOOK --zookeeper `hostname -f`:2181
rmr /brokers/topics/ATLAS_HOOK
rmr /admin/delete_topics/ATLAS_HOOK
rmr /config/topics/ATLAS_HOOK
```

```sh
We can cleanup complete Kafka related znode from zookeeper if you don't have other topics 

rmr /cluster 
rmr /controller_epoch 
rmr /controller 
rmr /brokers 
rmr /admin 
rmr /isr_change_notification 
rmr /consumers 
rmr /log_dir_event_notification 
rmr /latest_producer_id_block 
rmr /config 
rmr /kafka-acl 
```

## Connect to Zookeeper
```sh
zookeeper-client -server `hostname -f`:2181
```

##  Start Kafka manually
```bash
su kafka
source /usr/hdp/current/kafka-broker/config/kafka-env.sh
/usr/hdp/current/kafka-broker/bin/kafka start
```

## Enable debug for console producer:
```sh
# vi /usr/hdp/current/kafka-broker/conf/tools-log4j.properties
Change the following value from WARN to DEBUG:
```

## Kafka SSL
```
/usr/hdp/current/kafka-broker/bin/kafka-console-producer.sh --broker-list localhost:6668 --topic test --producer.config client-ssl.properties
/usr/hdp/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server localhost:6668 --topic test --new-consumer --consumer.config client-ssl.properties
```

## kafka acl

`/usr/hdp/current/kafka-broker/bin/kafka-acls.sh --topic test-topic --add --allow-principal user:mirrormaker --operation ALL --config /usr/hdp/current/kafka-broker/config/server.properties`


# Error and its Solution

```
WARN Error while fetching metadata with correlation id 30 : {test=UNKNOWN_TOPIC_OR_PARTITION} (org.apache.kafka.clients.NetworkClient)
WARN Error while fetching metadata with correlation id 31 : {test=UNKNOWN_TOPIC_OR_PARTITION} (org.apache.kafka.clients.NetworkClient)
```
##### Check Ranger Permission
=======================================================================================
                                                                                        

```
WARN Error while fetching metadata with correlation id 26 : {test1=LEADER_NOT_AVAILABLE} (org.apache.kafka.clients.NetworkClient)
WARN Error while fetching metadata with correlation id 27 : {test1=LEADER_NOT_AVAILABLE} (org.apache.kafka.clients.NetworkClient)[2018
```
##### Check server.log or check advertised.host.name
========================================================================================
```
# grep atlas.kafka.security.protocol /etc/hive/conf/atlas-application.properties
# grep atlas.kafka.security.protocol /etc/atlas/conf/atlas-application.properties 
# grep listeners /etc/kafka/conf/server.properties 
```

##### Kafka Ranger Group permission not working
```
Use below command to find if kafka ranger plugin is able to get the group info for the user, without debug. 

On Kafka host : 

#su - <EffectedUser> 
# id -Gn 

#KAFKA_RANGER_CLASSPATH=`echo /usr/hdp/current/kafka-broker/libs/ranger-kafka-plugin-impl/*.jar|tr ' ' ':'` 
#export KAFKA_RANGER_CLASSPATH=$KAFKA_RANGER_CLASSPATH:/usr/hdp/current/kafka-broker/libs/slf4j-api-1.7.25.jar:/usr/hdp/current/kafka-broker/libs/slf4j-log4j12-1.7.25.jar:/usr/hdp/current/kafka-broker/libs/log4j-1.2.17.jar:/usr/hdp/current/kafka-broker/libs/guava-20.0.jar 
#/usr/jdk64/jdk1.8.0_112/bin/java -cp ${KAFKA_RANGER_CLASSPATH} org.apache.hadoop.security.UserGroupInformation 


This should return the group info for the user, id -Gn should show the group names without any name resolution error.
```

## Triage
```
Replace `hostname -f` with zookeeper hostname:

List
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --list --zookeeper `hostname -f`:2181

Describe topics

cd /usr/hdp/current/kafka-broker/bin
./kafka-topics.sh --describe --zookeeper `hostname -f`:2181 --topic ATLAS_HOOK
./kafka-topics.sh --describe --zookeeper `hostname -f`:2181 --topic ATLAS_ENTITIES
./kafka-topics.sh --describe --zookeeper `hostname -f`:2181 --topic __consumer_offsets

vi client.properties
security.protocol=SASL_PLAINTEXT

/usr/hdp/current/kafka-broker/bin/kafka-consumer-groups.sh --bootstrap-server <broker host>:6667 --list --command-config client.properties

Share the output of the above cmds in a text file.

Login into Kafka node:

tar -cvzf kafka.tar.gz /etc/kafka/conf/* /etc/ranger/*
```


### Steps to use delegation token

```bash

# Generate the ticket

cat /tmp/jaas_keytab.conf 
KafkaClient {
com.sun.security.auth.module.Krb5LoginModule required
useKeyTab=true
keyTab="/var/run/cloudera-scm-agent/process/328-kafka-KAFKA_BROKER/kafka.keytab"
principal="kafka/cdh-63x-ja-2.cdh-63x-ja.root.hwx.site@ROOT.HWX.SITE";
};

cat /tmp/client.properties
security.protocol=SASL_SSL
ssl.truststore.location=/etc/cdep-ssl-conf/CA_STANDARD/truststore.jks
sasl.kerberos.service.name=kafka

export KAFKA_OPTS="-Djava.security.auth.login.config=/tmp/jaas_keytab.conf"

kafka-delegation-tokens --bootstrap-server cdh-63x-ja-2.cdh-63x-ja.root.hwx.site:9093 --create   --max-life-time-period -1 --command-config /tmp/client.properties --renewer-principal User:kafka

Op
Calling create token operation with renewers :[User:kafka] , max-life-time-period :-1
Created delegation token with tokenId : rqzabJYgS46df4acJ54Phg

TOKENID         HMAC                           OWNER           RENEWERS                  ISSUEDATE       EXPIRYDATE      MAXDATE        
rqzabJYgS46df4acJ54Phg IHZqKd+i9VTjEdOLOOqNeP3uFOS3Iz7i/1Tgnoims8kRiAa8jWe/EGPwIFX7yHCutz0T38w/d7hsVkgbNQnJ+Q== User:kafka      [User:kafka]              2021-12-01T05:51 2021-12-02T05:51 2021-12-08T05:51
2. Use this delegation token
cat /tmp/jaas_dt.conf
KafkaClient {
    org.apache.kafka.common.security.scram.ScramLoginModule required
    username="rqzabJYgS46df4acJ54Phg"
    password="IHZqKd+i9VTjEdOLOOqNeP3uFOS3Iz7i/1Tgnoims8kRiAa8jWe/EGPwIFX7yHCutz0T38w/d7hsVkgbNQnJ+Q=="
    tokenauth="true";
};

# ADD in client.properties - sasl.mechanism=SCRAM-SHA-512

cat /tmp/client.properties
security.protocol=SASL_SSL
ssl.truststore.location=/etc/cdep-ssl-conf/CA_STANDARD/truststore.jks
sasl.kerberos.service.name=kafka
sasl.mechanism=SCRAM-SHA-512

export KAFKA_OPTS="-Djava.security.auth.login.config=/tmp/jaas_dt.conf"

kafka-console-producer --broker-list  cdh-63x-ja-2.cdh-63x-ja.root.hwx.site:9093 --producer.config   /tmp/client.properties --topic test
Reference: https://docs.cloudera.com/documentation/enterprise/6/6.3/topics/kafka_delegation_tokens_manage.html
11:31
# For security reasons, max lifetime for delegation token is restricted to 24days

# As a workaround, these properties can be configured inside a safety valve to override these restrictions

Steps:
1) Navigate to CM -> Kafka -> Configuration -> "Kafka Broker Advanced Configuration Snippet (Safety Valve) for kafka.properties"
2) Add the following 
delegation.token.max.lifetime.ms=31536000000
delegation.token.expiry.time.ms=31536000000
3) Restart Kafka
```
