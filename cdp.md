# commands

### Zookeeper:

```
When we have custom zookeeper princiapl, we need to update service below property.

-Dzookeeper.sasl.client.username=zookeeper

As ZooKeeperSaslClient service name principal is hardcoded to "zookeeper"
https://issues.apache.org/jira/browse/ZOOKEEPER-1811

For CDP:

CM -> Atlas -> Configuration -> Atlas Server Environment Advanced Configuration Snippet (Safety Valve)

key : ATLAS_OPTS
value : -Dzookeeper.sasl.client.username=custom-principal

Save and restart atlas server.

If still does not work, after setting above value, Please enable debug on atlas and get the logs.

```
