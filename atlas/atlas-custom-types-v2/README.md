## How to create types with entities and delete them afterwards, in ATLAS REST API v2

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

