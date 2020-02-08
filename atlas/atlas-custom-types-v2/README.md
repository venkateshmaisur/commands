## How to create types with entities and delete them afterwards, in ATLAS REST API v2

• Creating a type
• Creating an entity
• Removing the entity
• Removing the type

wget https://raw.githubusercontent.com/bhagadepravin/commands/master/atlas/atlas-custom-types-v2/type.json

### Create type
```java
curl -u admin:Welcome@12345 -ik -H 'Content-Type: application/json' -X POST 'http://c174-node3.squadron.support.hortonworks.com:21000/api/atlas/v2/types/typedefs' -d @type.json


{"enumDefs":[],"structDefs":[],"classificationDefs":[],"entityDefs":[{"category":"ENTITY","guid":"5a51fe50-33f9-4739-86e3-add9f4d68a60","createdBy":"admin","updatedBy":"admin","createTime":1581157776362,"updateTime":1581157776362,"version":1,"name":"SomeTestEntity","description":"This is a test entity","typeVersion":"1.0","attributeDefs":[{"name":"TestEntity_1","typeName":"string","isOptional":true,"cardinality":"SINGLE","valuesMinCount":0,"valuesMaxCount":1,"isUnique":false,"isIndexable":false,"includeInNotification":false,"searchWeight":-1},{"name":"TestEntity_2","typeName":"string","isOptional":true,"cardinality":"SINGLE","valuesMinCount":0,"valuesMaxCount":1,"isUnique":false,"isIndexable":false,"includeInNotification":false,"searchWeight":-1}],"superTypes":["DataSet"],"subTypes":[],"relationshipAttributeDefs":[{"name":"schema","typeName":"array<avro_schema>","isOptional":true,"cardinality":"SET","valuesMinCount":-1,"valuesMaxCount":-1,"isUnique":false,"isIndexable":false,"includeInNotification":false,"searchWeight":-1,"relationshipTypeName":"avro_schema_associatedEntities","isLegacyAttribute":false},{"name":"inputToProcesses","typeName":"array<Process>","isOptional":true,"cardinality":"SET","valuesMinCount":-1,"valuesMaxCount":-1,"isUnique":false,"isIndexable":false,"includeInNotification":false,"searchWeight":-1,"relationshipTypeName":"dataset_process_inputs","isLegacyAttribute":false},{"name":"meanings","typeName":"array<AtlasGlossaryTerm>","isOptional":true,"cardinality":"SET","valuesMinCount":-1,"valuesMaxCount":-1,"isUnique":false,"isIndexable":false,"includeInNotification":false,"searchWeight":-1,"relationshipTypeName":"AtlasGlossarySemanticAssignment","isLegacyAttribute":false},{"name":"outputFromProcesses","typeName":"array<Process>","isOptional":true,"cardinality":"SET","valuesMinCount":-1,"valuesMaxCount":-1,"isUnique":false,"isIndexable":false,"includeInNotification":false,"searchWeight":-1,"relationshipTypeName":"process_dataset_outputs","isLegacyAttribute":false}]}],"relationshipDefs":[]}[root@c174-node3 ~]#
```

### Create Entity:

wget https://raw.githubusercontent.com/bhagadepravin/commands/master/atlas/atlas-custom-types-v2/entity.json

```json
curl -u admin:Welcome@12345 -ik -H 'Content-Type: application/json' -X POST 'http://c174-node3.squadron.support.hortonworks.com:21000/api/atlas/v2/entity' -d @entity.json

{"mutatedEntities":{"CREATE":[{"typeName":"SomeTestEntity","attributes":{"qualifiedName":"MyEntityName@c2175"},"guid":"ea493b2f-8218-4263-b790-a5f0f6b739c3"}]},"guidAssignments":{"-1":"ea493b2f-8218-4263-b790-a5f0f6b739c3"}}
````

![sometestentity](https://github.com/bhagadepravin/commands/blob/master/atlas/atlas-custom-types-v2/sometestentity.png)


![sometestentity-1](https://github.com/bhagadepravin/commands/blob/master/atlas/atlas-custom-types-v2/sometestentity-1.png)


### Search Types 

```bash
 cat search.json
{
  "excludeDeletedEntities": true,
  "includeSubClassifications": true,
  "includeSubTypes": true,
  "includeClassificationAttributes": true,
  "entityFilters": null,
  "tagFilters": null,
  "attributes": [],
  "limit": 25,
  "offset": 0,
  "typeName": "SomeTestEntity",
  "classification": null,
  "termName": null
}
```

#### Search by text for entity from types: Where entity is MyEntityName

```bash
{
  "excludeDeletedEntities": true,
  "includeSubClassifications": true,
  "includeSubTypes": true,
  "includeClassificationAttributes": true,
  "entityFilters": null,
  "tagFilters": null,
  "attributes": [],
  "query": "MyEntityName",
  "limit": 25,
  "offset": 0,
  "typeName": "SomeTestEntity",
  "classification": null,
  "termName": null
}
```

```java
curl -iks  -u admin:Welcome@12345 -ik -H 'Content-Type: application/json' -X POST 'http://c174-node3.squadron.support.hortonworks.com:21000/api/atlas/v2/search/basic' -d  @search.json


{
  "queryType": "BASIC",
  "searchParameters": {
    "typeName": "SomeTestEntity",
    "excludeDeletedEntities": true,
    "includeClassificationAttributes": true,
    "includeSubTypes": true,
    "includeSubClassifications": true,
    "limit": 25,
    "offset": 0,
    "attributes": []
  },
  "entities": [
    {
      "typeName": "SomeTestEntity",
      "attributes": {
        "owner": "admin",
        "qualifiedName": "MyEntityName@c2175",
        "name": "MyEntityName",
        "description": "This is a description"
      },
      "guid": "ea493b2f-8218-4263-b790-a5f0f6b739c3",
      "status": "ACTIVE",
      "displayText": "MyEntityName",
      "classificationNames": [],
      "classifications": [],
      "meaningNames": [],
      "meanings": []
    }
  ]
}
```


###### Search by GUID

```
curl -u admin:Welcome@12345  -ik -H 'Content-Type: application/json' -X GET 'http://c174-node3.squadron.support.hortonworks.com:21000/api/atlas/v2/entity/guid/ea493b2f-8218-4263-b790-a5f0f6b739c3'

{"referredEntities":{},"entity":{"typeName":"SomeTestEntity","attributes":{"owner":"admin","replicatedTo":null,"TestEntity_1":"attr1","replicatedFrom":null,"qualifiedName":"MyEntityName@c2175","name":"MyEntityName","description":"This is a description","TestEntity_2":"attr2"},"guid":"ea493b2f-8218-4263-b790-a5f0f6b739c3","status":"ACTIVE","createdBy":"admin","updatedBy":"admin","createTime":1581158664906,"updateTime":1581158664906,"version":0,"relationshipAttributes":{"schema":[],"inputToProcesses":[],"meanings":[],"outputFromProcesses":[]}}}[root@c174-node3 ~]#
```

### Removing the entity

```java
curl -u admin:Welcome@12345  -ik -H 'Content-Type: application/json' -X DELETE 'http://c174-node3.squadron.support.hortonworks.com:21000/api/atlas/v2/entity/guid/ea493b2f-8218-4263-b790-a5f0f6b739c3'

{"mutatedEntities":{"DELETE":[{"typeName":"SomeTestEntity","attributes":{"owner":"admin","qualifiedName":"MyEntityName@c2175","name":"MyEntityName","description":"This is a description"},"guid":"ea493b2f-8218-4263-b790-a5f0f6b739c3","status":"ACTIVE","displayText":"MyEntityName","classificationNames":[],"meaningNames":[],"meanings":[]}]}}
```

![deleteentity-1](https://github.com/bhagadepravin/commands/blob/master/atlas/atlas-custom-types-v2/delete%20entity.png)


### Remove type:
```java
curl -u admin:Welcome@12345 -ik -H 'Content-Type: application/json' -X GET 'http://c174-node3.squadron.support.hortonworks.com:21000/api/atlas/v2/types/typedefs' 

curl -u admin:Welcome@12345 -ik -H 'Content-Type: application/json' -X DELETE 'http://c174-node3.squadron.support.hortonworks.com:21000/api/atlas/v2/types/typedefs' -d @type.json
```
!!!!IMPORTANT!!!!

If at this step, you encounter an error; `ATLAS-409-00-002`

This is because the entity was SOFT deleted, make sure atlas is set for hard deletions before you create any type, by ensuring the application properties in ambari have the following;

```
• atlas.DeleteHandler.impl=org.apache.atlas.repository.graph.HardDeleteHandler
• atlas.DeleteHandlerV1.impl=org.apache.atlas.repository.store.graph.v1.HardDeleteHandlerV1
```

The GUID is randomly generated by the previous step, so you’ll have to adjust accordingly.

Please also note that deleting Atlas is not something which is recommended as Atlas is used for the governance purpose. 

So, by default soft delete is enabled so that actual data is never deleted if any user by mistake deletes's something from Atlas. Plus the only way to delete is to completely clear the Atlas storage ( Hbase tables).
