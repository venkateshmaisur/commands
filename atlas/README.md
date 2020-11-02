# ATLAS-API


###  Atlas API: Associate a tag with an entity  
=========================================
```bash
curl -u admin:admin -H 'Content-Type: application/json' -X POST -d '{"excludeDeletedEntities":true,"entityFilters":null,"tagFilters":null,"attributes":[],"query":"\"afw300_multi_record_file_process_87237@operation@b01_bdp_Process2\"","limit":25,"offset":0,"typeName":"SomeTestEntity","classification":null}' http://c374-node4.supportlab.cloudera.com:21000/api/atlas/v2/search/basic |  python -m json.tool | grep guid | cut -d '"' -f 4

curl -u admin:admin -H 'Content-Type: application/json' -X POST -d '{"classification":{"typeName":"atos","attributes":{}},"entityGuids":["bf02a172-8c82-4a8c-88b1-4ba1f01465b9"]}' http://c374-node4.supportlab.cloudera.com:21000/api/atlas/v2/entity/bulk/classification
```

### Get the guid:

```bash
curl -u admin:admin -H 'Content-Type: application/json' -X POST 'http://c374-node4.supportlab.cloudera.com:21000/api/atlas/v2/search/basic' -d '{"excludeDeletedEntities":true,"entityFilters":null,"tagFilters":null,"attributes":[],"query":"!atos","limit":25,"offset":0,"typeName":"SomeTestEntity","classification":null}' |  python -m json.tool | grep guid | cut -d '"' -f 4 > untags.txt  
```

###  Search entities without tags:
```bash
time curl -u admin:admin -H 'Content-Type: application/json' -X POST 'http://c374-node4.supportlab.cloudera.com:21000/api/atlas/v2/search/basic' -d '{"excludeDeletedEntities":true,"entityFilters":null,"tagFilters":null,"attributes":[],"query":"!atos","limit":10000,"offset":0,"typeName":"SomeTestEntity","classification":null}' |  python -m json.tool | grep guid | wc -l
real	0m8.095s
```

===============
### Assign tags to unassign entities
```bash
curl -u admin:admin -H 'Content-Type: application/json' -X POST 'http://c374-node4.supportlab.cloudera.com:21000/api/atlas/v2/search/basic' -d '{"excludeDeletedEntities":true,"entityFilters":null,"tagFilters":null,"attributes":[],"query":"!atos","limit":25,"offset":0,"typeName":"SomeTestEntity","classification":null}' |  python -m json.tool | grep guid | cut -d '"' -f 4 > untags.txt 

for i in `cat untags.txt`; do curl -s -u admin:admin -H 'Content-Type: application/json' -X POST -d '{"classification":{"typeName":"atos","attributes":{}},"entityGuids":["'$i'"]}' "http://c374-node4.supportlab.cloudera.com:21000/api/atlas/v2/entity/bulk/classification";done 
```

```bash
#!/bin/bash

curl -u admin:admin -H 'Content-Type: application/json' -X POST 'http://c374-node4.supportlab.cloudera.com:21000/api/atlas/v2/search/basic' -d '{"excludeDeletedEntities":true,"entityFilters":null,"tagFilters":null,"attributes":[],"query":"!atos","limit":10000,"offset":0,"typeName":"SomeTestEntity","classification":null}' |  python -m json.tool | grep guid | cut -d '"' -f 4 > untags.txt;for i in `cat untags.txt`; do curl -s -u admin:admin -H 'Content-Type: application/json' -X POST -d '{"classification":{"typeName":"atos","attributes":{}},"entityGuids":["'$i'"]}' "http://c374-node4.supportlab.cloudera.com:21000/api/atlas/v2/entity/bulk/classification";done 

crontab -e
* * * * * sleep 15; /root/atlas-tags.sh

[root@c374-node4 ~]# crontab -l
* * * * * sleep 15; /root/atlas-tags.sh

```


### Search no of tags assigned:
```bash
curl -u admin:admin -H 'Content-Type: application/json' -X POST 'http://c374-node4.supportlab.cloudera.com:21000/api/atlas/v2/search/basic' -d '{"excludeDeletedEntities":true,"limit":500,"offset":0,"typeName":null,"classification":"atos"}'| python -m json.tool |  grep atos | wc -l
```

