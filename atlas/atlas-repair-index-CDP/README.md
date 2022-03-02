# Atlas Repair Index

https://atlas.apache.org/#/AtlasRepairIndex

Introduction
  This feature takes care while in some cases it is possible that during entity creation, the entity is stored in the data store, but the corresponding indexes are not created in Solr.
  Since Atlas relies heavily on Solr in the operation of its Basic Search, this will result in entity not being returned by a search.

Steps to execute repair index in Atlas :
  If the user needs to restore all the indexes, this can be accomplished by executing the repair-index.py with no command-line parameters.
  To perform selective restore for an Atlas entity, specify the GUID of that entity:

### STEPS:

1. Login into Atlas node:

```bash
NAME=atlas; KEYTAB=$(find /run/cloudera-scm-agent/process -name ${NAME}.keytab -path "*${NAME}-*" | sort | tail -n 1); PRINCIPAL=$(klist -kt "$KEYTAB" | awk '{ print $4 }' | grep "^${NAME}" | head -n 1); kinit -kt "${KEYTAB}" "${PRINCIPAL}"
```

##### If SSL is enabled on Cluster, Make sure Solr cert or RootCA certificate is added to JAVA_HOME cacerts
```
export JAVA_HOME=/usr/java/jdk1.8.0_232-cloudera
echo -n | openssl s_client -connect solr-hostname:port | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/solr.pem
/usr/java/jdk1.8.0_232-cloudera/bin/keytool -import -file /tmp/solr.pem -keystore $JAVA_HOME/jre/lib/security/cacerts -alias solrcert -storepass changeit
```
```bash
cd /opt/cloudera/parcels/CDH/lib/atlas/tools/atlas-index-repair
```
#### In Kerbeors env, create a atlas_jaas.conf with below format

 Add `"-Djava.security.auth.login.config=/<atlas server directory>/conf/atlas_jaas.conf"` to `DEFAULT_JVM_OPTS` in `repair_index.py`.

```bash
ls -1dtr /var/run/cloudera-scm-agent/process/*ATLAS_SERVER | tail -1
/var/run/cloudera-scm-agent/process/104-atlas-ATLAS_SERVER


From "-Djava.security.auth.login.config=/<atlas server directory>/conf/atlas_jaas.conf"
To   "-Djava.security.auth.login.config=/var/run/cloudera-scm-agent/process/104-atlas-ATLAS_SERVER/conf/atlas_jaas.conf"
```

`vi /opt/cloudera/parcels/CDH/lib/atlas/tools/atlas-index-repair/repair_index.py`

#### For kerberos authentication.

```

NAME=atlas; KEYTAB=$(find /run/cloudera-scm-agent/process -name ${NAME}.keytab -path "*${NAME}-*" | sort | tail -n 1); PRINCIPAL=$(klist -kt "$KEYTAB" | awk '{ print $4 }' | grep "^${NAME}" | head -n 1); kinit -kt "${KEYTAB}" "${PRINCIPAL}"

cd /opt/cloudera/parcels/CDH/lib/atlas/tools/atlas-index-repair
python repair_index.py
```

```python
eg : python repair_index.py [-g <guid>]
```
`python repair_index.py -u admin -p admin123 -g 6c2ff955-0faf-4121-9458-8c03d20a5a2c`

```bash
# python repair_index.py -u admin -p admin123 -g 6c2ff955-0faf-4121-9458-8c03d20a5a2c
['147-atlas-ATLAS_SERVER']
['147-atlas-ATLAS_SERVER', '83-atlas-ATLAS_SERVER']
/var/run/cloudera-scm-agent/process/83-atlas-ATLAS_SERVER/conf
Logging: /opt/cloudera/parcels/CDH/lib/atlas/logs/atlas-index-janus-repair.log
OpenJDK 64-Bit Server VM warning: ignoring option MaxPermSize=512m; support was removed in 8.0
Initializing graph: Graph Initialized!
processing referencedGuids => [242c5588-b74c-4c02-b9f6-64164548e650, f0f71331-f6f9-46be-9108-5cd5b1a439d6, 3e1a9555-b766-4696-b398-ec7802852f99, 20162da5-5477-46c2-9b40-6bd82b550105, 6c2ff955-0faf-4121-9458-8c03d20a5a2c, 22d1da54-0fcb-4e1f-b498-d20c0792700d, 9399b96d-84ce-4654-a8d1-321e7434d8ef, e2f7ce29-18f8-4593-94d2-ee00a2c00f55, c4417e19-9145-49ec-b3b9-d02bf6ed836d, a3c9e9e5-43ee-42b5-bef2-cda3e93d6c92, 45e0d1c8-a762-4871-98cf-014a25267131, 5fdea1bd-bf4f-4843-9d74-a7274fdd4baf, c906e3fe-a7fa-4072-9d99-e2cd8c38abb0, edc88547-2ef2-43d3-9c8d-a8a80ef0307e, f98319c9-8bea-4309-a6f6-46b5fe187abb, e97f74e4-8c11-4c4b-b947-576b5a7a0d4e, 350fbb94-29e6-4117-87cd-0ac705838172, dc4725b4-3e7d-4973-a7b4-a6905764426a, 0e405071-3b0f-44ad-8a12-df8388d24999, e2309b47-5672-450d-bd72-2bff6e45f87f, e05ea3d1-c00d-47fd-b8a9-0727e44bef32, 9f163c1f-0fc7-4850-8b01-856bc202fbc1, 16a00c25-95be-445e-ac15-9cac549b39ca, bbda030e-d4df-453d-aff8-5a8c49fdabdc, 149f4595-7cfc-4df2-a0c6-d9505364e4b8, a87f1934-7b5f-45b7-9028-bce0bfa26dff, a043e941-5ba5-4e1e-a301-8ccf3a7d2b03, c3a7fc7a-7b27-4191-aa28-c80e5a819c84, a65edafe-5feb-4989-baab-9bc3ead7772c, 1583c775-47c9-483e-ac77-a53e6a0c1ee1, 96971889-d85b-4758-ae7c-56478b148754, b849bb27-1a53-4866-a2cc-e52fc01c6d57]
Restoring: vertex_index
: Time taken: 4305 ms: Done!
Restoring: edge_index
: Time taken: 6 ms: Done!
Restoring: fulltext_index
: Time taken: 51 ms: Done!
Repair Index: Done!
```

#### Troubleshooting
```
if there is 401 error for solr 

DEFAULT_JVM_OPTS="-Dlog4j.configuration=atlas-log4j.xml -Djava.net.preferIPv4Stack=true -server -Djava.security.auth.login.config=/var/run/cloudera-scm-agent/process/104-atlas-ATLAS_SERVER/conf/atlas_jaas.conf -Djavax.security.auth.useSubjectCredsOnly=false"
```

