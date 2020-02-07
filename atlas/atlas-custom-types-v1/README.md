# Creating Custom Types and Entities in Atlas

#### Files:-

The files being used in this article are present in github.

a.) atlas_type_ResearchPaperDataSet.json

b.) atlas_entity_ResearchPaperDataSet.json

c.) atlas_type_RecommendationResults.json

d.) atlas_entity_RecommendationResults.json

e.) atlas_type_process_ML.json

f.) atlas_entity_process_ML.json


Steps:-

## 1. Create Custom Atlas ResearchPaperAccessDataset Type:-

https://github.com/bhagadepravin/commands/blob/master/atlas/atlas-custom-types/atlas_type_ResearchPaperDataSet.json

```sh
curl -i -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:Welcome@12345 'http://c174-node3.squadron.support.hortonworks.com:21000/api/atlas/types' -d @atlas_type_ResearchPaperDataSet.json
```

## 2. Create Entity for ResearchPaperAccessDataset Type:-
https://github.com/bhagadepravin/commands/blob/master/atlas/atlas-custom-types/atlas_entity_ResearchPaperDataSet.json

```sh
[root@c174-node3 ~]# curl -i -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:Welcome@12345 'http://c174-node3.squadron.support.hortonworks.com:21000/api/atlas/entities' -d @atlas_entity_ResearchPaperDataSet.json

{"entities":{"created":["ae553652-685f-4b8b-b34a-1423c5d7975c"]},"requestId":"pool-2-thread-9 - 172f342d-3b43-4f41-ac91-6923b28e7947","definition":{"typeName":"ResearchPaperAccessDataset","values":{"owner":"EDM_RANDD","replicatedTo":null,"replicatedFrom":null,"createTime":"2017-03-25T20:07:12.000Z","qualifiedName":"ResearchPaperAccessDataset.1224-WV-SP-INT-HWX","researchPaperGroupName":"WV-SP-INT-HWX","name":"GeoThermal-1224","description":"GeoThermal Research Input Dataset 1224","resourceSetID":1224},"id":{"id":"ae553652-685f-4b8b-b34a-1423c5d7975c","typeName":"ResearchPaperAccessDataset","version":0,"state":"ACTIVE","jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Id"},"traits":{},"traitNames":[],"systemAttributes":{"createdBy":"admin","modifiedBy":"admin","createdTime":"2020-02-07T13:48:10.424Z","modifiedTime":"2020-02-07T13:48:10.424Z"},"jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Reference"},"guidAssignments":{"guidAssignments":{"-21823357824402199":"ae553652-685f-4b8b-b34a-1423c5d7975c"}}}
```
![ResearchPaperAccessDataset](https://github.com/bhagadepravin/commands/blob/master/atlas/atlas-custom-types/jpeg/ResearchPaperAccessDataset.png)


## 3. Create Custom ResearchPaperRecommendationResults Type:-
https://github.com/vspw/atlas-custom-types/blob/master/atlas_type_RecommendationResults.json

```sh
curl -i -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:Welcome@12345 'http://c174-node3.squadron.support.hortonworks.com:21000/api/atlas/types' -d @atlas_type_RecommendationResults.json

```

## 4. Create Entity for ResearchPaperRecommendationResults Type:-
https://github.com/bhagadepravin/commands/blob/master/atlas/atlas-custom-types/atlas_type_RecommendationResults.json

```sh
[root@c174-node3 atlas-custom-types]# curl -i -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:Welcome@12345 'http://c174-node3.squadron.support.hortonworks.com:21000/api/atlas/entities' -d @atlas_entity_RecommendationResults.json

{"entities":{"created":["7b802fb0-67f0-47ce-a25b-c8a9ed8edc6b"]},"requestId":"pool-2-thread-3 - 5b9a2d11-7f3a-4cf1-8ae5-f695c566f388","definition":{"typeName":"ResearchPaperRecommendationResults","values":{"owner":"EDM_RANDD","hdfsDestination":"hdfs://xena.hdp.com:8020/edm/data/prod/recommendations","replicatedTo":null,"replicatedFrom":null,"createTime":"2017-03-25T21:00:12.000Z","qualifiedName":"ResearchPaperRecommendationResults.4995149-GeoThermal","recommendationsResultsetID":4995149,"name":"RecommendationsGeoThermal-4995149","description":"GeoThermal Recommendations Mar 2017","researchArea":"GeoThermal"},"id":{"id":"7b802fb0-67f0-47ce-a25b-c8a9ed8edc6b","typeName":"ResearchPaperRecommendationResults","version":0,"state":"ACTIVE","jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Id"},"traits":{},"traitNames":[],"systemAttributes":{"createdBy":"admin","modifiedBy":"admin","createdTime":"2020-02-07T12:22:04.273Z","modifiedTime":"2020-02-07T12:22:04.273Z"},"jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Reference"},"guidAssignments":{"guidAssignments":{"-21823357824402198":"7b802fb0-67f0-47ce-a25b-c8a9ed8edc6b"}}}[root@c174-node3 atlas-custom-types]
```
![RecommendationResults](https://github.com/bhagadepravin/commands/blob/master/atlas/atlas-custom-types/jpeg/RecommendationResults.png)


## 5. Create a Special Process Type (ResearchPaperMachineLearning) which would complete the lineage information:-

https://raw.githubusercontent.com/bhagadepravin/commands/master/atlas/atlas-custom-types/atlas_type_process_ML.json

```sh
[root@c174-node3 ~]# curl -i -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:Welcome@12345 'http://c174-node3.squadron.support.hortonworks.com:21000/api/atlas/types' -d @atlas_type_process_ML.json

{"types":[{"name":"ResearchPaperMachineLearning"}],"requestId":"pool-2-thread-4 - d2a6b032-48dc-4507-9efe-a57bed9c1b57"}
```
## 6. Create an entity for the Process Type:-
https://raw.githubusercontent.com/bhagadepravin/commands/master/atlas/atlas-custom-types/atlas_entity_process_ML.json

Get GUID

```
######## ResearchPaperAccessDataset
http://c174-node3.squadron.support.hortonworks.com:21000/index.html#!/detailPage/ae553652-685f-4b8b-b34a-1423c5d7975c


######## ResearchPaperRecommendationResults
http://c174-node3.squadron.support.hortonworks.com:21000/index.html#!/detailPage/7b802fb0-67f0-47ce-a25b-c8a9ed8edc6b
```

```sh
curl -i -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:Welcome@12345 'http://c174-node3.squadron.support.hortonworks.com:21000/api/atlas/entities' -d @atlas_entity_process_ML.json

{"entities":{"created":["9ba24b15-66b5-4cec-8298-e9581337f560"],"updated":["7b802fb0-67f0-47ce-a25b-c8a9ed8edc6b","ae553652-685f-4b8b-b34a-1423c5d7975c"]},"requestId":"pool-2-thread-2 - a2316a38-f202-42b1-bf69-2e0093988ffc","definition":{"typeName":"ResearchPaperMachineLearning","values":{"owner":"EDM_RANDD","outputs":[{"id":"7b802fb0-67f0-47ce-a25b-c8a9ed8edc6b","typeName":"ResearchPaperRecommendationResults","version":0,"state":"ACTIVE","jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Id"}],"queryGraph":null,"replicatedTo":null,"replicatedFrom":null,"qualifiedName":"ResearchPaperMachineLearning.ML_Iteration567019","inputs":[{"id":"ae553652-685f-4b8b-b34a-1423c5d7975c","typeName":"ResearchPaperAccessDataset","version":0,"state":"ACTIVE","jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Id"}],"description":"ML_Iteration567019 For GeoThermal DataSets","userName":"hdpdev-edm-appuser-recom","clusterName":"turing","name":"ML_Iteration567019","startTime":"2017-03-26T20:20:13.675Z","operationType":"DecisionTreeAndRegression","endTime":"2017-03-26T20:27:23.675Z"},"id":{"id":"9ba24b15-66b5-4cec-8298-e9581337f560","typeName":"ResearchPaperMachineLearning","version":0,"state":"ACTIVE","jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Id"},"traits":{},"traitNames":[],"systemAttributes":{"createdBy":"admin","modifiedBy":"admin","createdTime":"2020-02-07T14:05:30.658Z","modifiedTime":"2020-02-07T14:05:30.658Z"},"jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Reference"},"guidAssignments":{"guidAssignments":{"-21823357824402196":"9ba24b15-66b5-4cec-8298-e9581337f560"}}}[root@c174-node3 ~]#
```

![process_ML](https://github.com/bhagadepravin/commands/blob/master/atlas/atlas-custom-types/jpeg/process_ML.png)

![process_ML-lineage](https://github.com/bhagadepravin/commands/blob/master/atlas/atlas-custom-types/jpeg/process_ML-lineage.png)

You should also be able to see the types created thus far in the search objects.

![entities](https://github.com/bhagadepravin/commands/blob/master/atlas/atlas-custom-types/jpeg/entities.png)
