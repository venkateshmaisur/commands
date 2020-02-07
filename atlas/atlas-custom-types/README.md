json files and rest calls to add custom atlas types and create entities


Objective:-

Atlas, by default comes with certain types for Hive, Storm, Falcon etc. However, there might be cases where you would like to capture some custom metadata in Atlas. This can be metadata related to ETL processes, enterprise-operations etc. The article explains how to create custom Atlas types and provides some insight on establishing lineage between said types.

Use Case:-

Consider a simple Use Case where Raw Textual data is analyzed via a ML process and the results are stored in HDFS. For instance, the raw source data is a dump of access logs on professors and research assistants referring research papers. The ML process would try to come up with recommendations on research papers for further reading for these end users. To capture metadata and lineage for this workflow, we would want to have three custom types in Atlas.

a.) ResearchPaperAccessDataset: To capture the metadata for the input dataset.

b.) ResearchPaperRecommendationResults: To capture the metadata for the resultant output after the ML process has completed its analysis.

c.) ResearchPaperMachineLearning: To capture the metadata for the ML process itself, which analyzes the Input dataset.

The eventual lineage we want to capture would look something like this:-

14073-screen-shot-2017-03-27-at-102550-am.png

Bonus: The last part of this article has some information to create new Traits using REST API and then to associate it with an existing atlas entity.

Files:-

The files being used in this article are present in github.

a.) atlas_type_ResearchPaperDataSet.json

b.) atlas_entity_ResearchPaperDataSet.json

c.) atlas_type_RecommendationResults.json

d.) atlas_entity_RecommendationResults.json

e.) atlas_type_process_ML.json

f.) atlas_entity_process_ML.json


Steps:-

1. Create Custom Atlas ResearchPaperAccessDataset Type:-

https://github.com/vspw/atlas-custom-types/blob/master/atlas_type_ResearchPaperDataSet.json

```sh
[root@zulu atlas]# curl -i -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin 'http://yellow.hdp.com:21000/api/atlas/types' -d @atlas_type_ResearchPaperDataSet.json
Enter host password for user 'admin':*****
{"requestId":"qtp84739718-14 - bed149b3-b360-4bf5-b46b-8f25ac7692c3","types":[{"name":"ResearchPaperAccessDataset"}]}
Notice the superType for "ResearchPaperAccessDataset" Type: ["DataSet"]
```
"DataSet" in turn has superTypes of ["Referenceable","Asset"]

"Asset" Type has attributes such as -> name, description, owner
"Referenceable" Type has attributes such as -> qualifiedName
Depending on whether these attributes are mandatory or not (based on the multiplicity required), the entity Type we create next, for "ResearchPaperAccessDataset" should have definitions for these attributes.
2. Create Entity for ResearchPaperAccessDataset Type:-
https://github.com/vspw/atlas-custom-types/blob/master/atlas_entity_ResearchPaperDataSet.json

```sh
[root@zulu atlas]# curl -i -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin 'http://yellow.hdp.com:21000/api/atlas/entities' -d @atlas_entity_ResearchPaperDataSet.json
{"requestId":"qtp84739718-15 - 827d5151-a6fb-4ccb-909f-f4ac5f8d8f26","entities":{"created":["40dc03dc-16d6-4281-826d-c4884cd1dad5"]},"definition":{"jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Reference","id":{"jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Id","id":"40dc03dc-16d6-4281-826d-c4884cd1dad5","version":0,"typeName":"ResearchPaperAccessDataset","state":"ACTIVE"},"typeName":"ResearchPaperAccessDataset","values":{"name":"GeoThermal-1224","createTime":"2017-03-25T20:07:12.000Z","description":"GeoThermal Research Input Dataset 1224","resourceSetID":1224,"researchPaperGroupName":"WV-SP-INT-HWX","qualifiedName":"ResearchPaperAccessDataset.1224-WV-SP-INT-HWX","owner":"EDM_RANDD"},"traitNames":[],"traits":{}}}
```
14074-screen-shot-2017-03-27-at-111439-am.png

14076-screen-shot-2017-03-27-at-111511-am.png

3. Create Custom ResearchPaperRecommendationResults Type:-
https://github.com/vspw/atlas-custom-types/blob/master/atlas_type_RecommendationResults.json

```sh
 [root@zulu atlas]# curl -i -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin 'http://yellow.hdp.com:21000/api/atlas/types' -d @atlas_type_RecommendationResults.json
Enter host password for user 'admin':
{"requestId":"qtp84739718-15 - 9da58639-479f-41fb-819d-b11b4464011e","types":[{"name":"ResearchPaperRecommendationResults"}]}   
```

4. Create Entity for ResearchPaperRecommendationResults Type:-
https://github.com/vspw/atlas-custom-types/blob/master/atlas_entity_RecommendationResults.json

```sh
[root@zulu atlas]# curl -i -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin 'http://yellow.hdp.com:21000/api/atlas/entities' -d @atlas_entity_RecommendationResults.json
Enter host password for user 'admin':
{"requestId":"qtp84739718-16 - b7ebe7d8-e671-4e94-a6c7-506947c7d5e5","entities":{"created":["43b6da13-31ee-4bbe-980e-84ed4b759f11"]},"definition":{"jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Reference","id":{"jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Id","id":"43b6da13-31ee-4bbe-980e-84ed4b759f11","version":0,"typeName":"ResearchPaperRecommendationResults","state":"ACTIVE"},"typeName":"ResearchPaperRecommendationResults","values":{"name":"RecommendationsGeoThermal-4995149","createTime":"2017-03-25T21:00:12.000Z","description":"GeoThermal Recommendations Mar 2017","qualifiedName":"ResearchPaperRecommendationResults.4995149-GeoThermal","researchArea":"GeoThermal","hdfsDestination":"hdfs:\/\/xena.hdp.com:8020\/edm\/data\/prod\/recommendations","owner":"EDM_RANDD","recommendationsResultsetID":4995149},"traitNames":[],"traits":{}}}
```
14077-screen-shot-2017-03-27-at-111531-am.png

14078-screen-shot-2017-03-27-at-111549-am.png

5. Create a Special Process Type (ResearchPaperMachineLearning) which would complete the lineage information:-

https://github.com/vspw/atlas-custom-types/blob/master/atlas_type_process_ML.json

Notice the superTypes for "ResearchPaperMachineLearning" - ["Process"],

The "Process" type in turn constitutes superTypes "Referenceable" and "Asset".

And besides the attributes inherited from the above superTypes, "Process" has the following attributes:-

- inputs

- outputs

Our custom type (ResearchPaperMachineLearning) has attributes such as : operationType, userName, startTime and endTime.

Hence we need to collectively define all these types in the entity we create after we are done with creating this type.

```sh
[root@zulu atlas]# curl -i -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin 'http://yellow.hdp.com:21000/api/atlas/types' -d @atlas_type_process_ML.json
Enter host password for user 'admin':
{"requestId":"qtp84739718-135 - 4f4cf931-0922-4d5c-b876-061f1bc1e7af","types":[{"name":"ResearchPaperMachineLearning"}]}

```
6. Create an entity for the Process Type:-
https://github.com/vspw/atlas-custom-types/blob/master/atlas_entity_process_ML.json

```sh
[root@zulu atlas]# curl -i -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin 'http://yellow.hdp.com:21000/api/atlas/entities' -d @atlas_entity_process_ML.json
Enter host password for user 'admin':****
{"requestId":"qtp84739718-18 - abbc3513-fa09-4a63-a8e5-af4b7b5f2d9a","entities":{"created":["4bd5263e-761b-4c0c-b629-c3d9fc87626f"]},"definition":{"jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Reference","id":{"jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Id","id":"4bd5263e-761b-4c0c-b629-c3d9fc87626f","version":0,"typeName":"ResearchPaperMachineLearning","state":"ACTIVE"},"typeName":"ResearchPaperMachineLearning","values":{"name":"ML_Iteration567019","startTime":"2017-03-26T20:20:13.675Z","description":"ML_Iteration567019 For GeoThermal DataSets","operationType":"DecisionTreeAndRegression","outputs":[{"jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Id","id":"43b6da13-31ee-4bbe-980e-84ed4b759f11","version":0,"typeName":"DataSet","state":"ACTIVE"}],"endTime":"2017-03-26T20:27:23.675Z","inputs":[{"jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Id","id":"40dc03dc-16d6-4281-826d-c4884cd1dad5","version":0,"typeName":"DataSet","state":"ACTIVE"}],"qualifiedName":"ResearchPaperMachineLearning.ML_Iteration567019","owner":"EDM_RANDD","clusterName":"turing","queryGraph":null,"userName":"hdpdev-edm-appuser-recom"},"traitNames":[],"traits":{}}}
```

So after creating all the necessary Types and Entities we should be able to see the respective types created in Atlas UI and query entities and create new entities as usual.

In this case we had a java application that used to create and deliver the entity json files for the above workflow after each iteration of the ML process completed successfully (Since the attributes values in the entities json file should be altered dynamically based on the iteration and results)

14080-screen-shot-2017-03-27-at-111600-am.png

14091-screen-shot-2017-03-27-at-111613-am.png

14092-screen-shot-2017-03-27-at-111541-am.png

You should also be able to see the types created thus far in the search objects.

14096-atlas2-customtypes.png

Creating a Trait and Associating tagging an Atlas Entity:-

Note that we can create new Trait/Tag types in Atlas similar to how we have created our custom types.

https://github.com/vspw/atlas-custom-types/blob/master/atlas_trait_type.json

```sh
[root@zulu atlas]# curl -i -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin 'http://yellow.hdp.com:21000/api/atlas/types' -d @atlas_trait_type.json
Associating a trait to an existing Entity:-

curl  -i -X POST  -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin 'http://yellow.hdp.com:21000/api/atlas/entities/b58571af-1ef1-40e4-a89b-0a2ade4eeab3/traits' -d @associate_trait.json
associate_trait.json

{
  "jsonClass":"org.apache.atlas.typesystem.json.InstanceSerialization$_Struct",
  "typeName":"PublicData",
  "values":{
    "name":"addTrait"
  }
}
```

atlas2-customtypes.pngscreen-shot-2017-03-27-at-111455-am.png
