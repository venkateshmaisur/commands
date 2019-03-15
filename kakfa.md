# Kafka Commands

##### List
`/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --list --zookeeper `hostname -f`:2181`

##### Create
`/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --create --topic ATLAS_HOOK --zookeeper `hostname -f`:2181 --partitions 1 --replication-factor 1`

##### Describe topics
`/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --describe --zookeeper <zkHost>:<zkPort> --topic <TopicName>`
`/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --describe --zookeeper `hostname -f`:2181 --topic ATLAS_HOOK`
`/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --describe --zookeeper `hostname -f`:2181 --topic ATLAS_ENTITIES`

##### List Consumer Group
`/usr/hdp/current/kafka-broker/bin/kafka-consumer-groups.sh --bootstrap-server <broker host>:6667 --list --security-protocol SASL_PLAINTEXT` 

##### Describe Consumer Group
`/usr/hdp/current/kafka-broker/bin/kafka-consumer-groups.sh --describe --zookeeper <zkHost>:<zkPort> --group atlas --security-protocol SASL_PLAINTEXT`

##### Let's see what kind of message is flowing in this topic:
`/usr/hdp/current/kafka-broker/bin/kafka-console-consumer.sh --zookeeper `hostname -f`:2181 --topic ATLAS_HOOK --from-beginning`

##### Console Producer :
`/usr/hdp/current/kafka-broker/bin/bin/kafka-console-producer.sh --broker-list <broker-hostname:port> --topic <topic-name>`

##### Console Consumer:
`/usr/hdp/current/kafka-broker/bin/bin/kafka-console-consumer.sh --bootstrap-server <BROKER_HOST:PORT> --topic <TOPIC-NAME>`

##### Delete
`/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --delete --topic ATLAS_ENTITIES --zookeeper `hostname -f`:2181`
`/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --delete --topic ATLAS_HOOK --zookeeper `hostname -f`:2181`

delete.topic.enable=true. == it will delete the topics which are marked for delete

##### Delete kafka topic from ZK

`/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --delete --topic ATLAS_HOOK --zookeeper `hostname -f`:2181`
```bash
rmr /brokers/topics/ATLAS_HOOK
rmr /admin/delete_topics/ATLAS_HOOK
rmr /config/topics/ATLAS_HOOK
```

##### Connect to Zookeeper
`zookeeper-client -server `hostname -f`:2181`

#####  Start Kafka manually
```bash
su kafka
source /usr/hdp/current/kafka-broker/config/kafka-env.sh
/usr/hdp/current/kafka-broker/bin/kafka start
```

##### Enable debug for console producer:
```sh
# vi /usr/hdp/current/kafka-broker/conf/tools-log4j.properties
Change the following value from WARN to DEBUG:
```

##### Kafka SSL
```
/usr/hdp/current/kafka-broker/bin/kafka-console-producer.sh --broker-list localhost:6668 --topic test --producer.config client-ssl.properties
/usr/hdp/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server localhost:6668 --topic test --new-consumer --consumer.config client-ssl.properties
```

##### kafka acl

`/usr/hdp/current/kafka-broker/bin/kafka-acls.sh --topic test-topic --add --allow-principal user:mirrormaker --operation ALL --config /usr/hdp/current/kafka-broker/config/server.properties`


# Error and its Solution

```
WARN Error while fetching metadata with correlation id 30 : {test=UNKNOWN_TOPIC_OR_PARTITION} (org.apache.kafka.clients.NetworkClient)
WARN Error while fetching metadata with correlation id 31 : {test=UNKNOWN_TOPIC_OR_PARTITION} (org.apache.kafka.clients.NetworkClient)
```
--> Check Ranger Permission
==========================================================================================================

```
WARN Error while fetching metadata with correlation id 26 : {test1=LEADER_NOT_AVAILABLE} (org.apache.kafka.clients.NetworkClient)
WARN Error while fetching metadata with correlation id 27 : {test1=LEADER_NOT_AVAILABLE} (org.apache.kafka.clients.NetworkClient)[2018
```
--> Check server.log or check advertised.host.name
==========================================================================================================
