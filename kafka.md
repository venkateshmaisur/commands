# Kafka Commands

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
/usr/hdp/current/kafka-broker/bin/bin/kafka-console-producer.sh --broker-list <broker-hostname:port> --topic <topic-name>
```

## Console Consumer:
```sh
/usr/hdp/current/kafka-broker/bin/bin/kafka-console-consumer.sh --bootstrap-server <BROKER_HOST:PORT> --topic <TOPIC-NAME>
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
