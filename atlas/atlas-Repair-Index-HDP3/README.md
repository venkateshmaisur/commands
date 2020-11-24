# Atlas Repair Index

https://atlas.apache.org/#/AtlasRepairIndex


### Need for this Tool
In rare, cases it is possible that during entity creation, the entity is stored in the data store, but the corresponding indexes are not created in Solr. Since Atlas relies heavily on Solr in the operation of its Basic Search, this will result in entity not being returned by a search. Note that Advanced Search is not affected by this.

### Steps to Execute Tool
Complete Restore
If the user needs to restore all the indexes, this can be accomplished by executing the tool with no command-line parameters:

### Solr backup
```
Use following syntax to run Solr backup API using curl command:
# http://<Infra Solr Host>:<Port>/solr/admin/collections?action=BACKUP&name=myBackupName&collection=myCollectionName&location=/path/to/my/shared/drive

kinit -kt /etc/security/keytabs/ambari-infra-solr.service.keytab $(klist -kt /etc/security/keytabs/ambari-infra-solr.service.keytab |sed -n "4p"|cut -d ' ' -f7)


Example:
curl -ivk --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=BACKUP&name=vertex_index_bkp&collection=vertex_index&location=/tmp"
curl -ivk --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=BACKUP&name=edge_index_bkp&collection=edge_index&location=/tmp"
curl -ivk --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=BACKUP&name=fulltext_index_bkp&collection=fulltext_index&location=/tmp"
```
```
cd /usr/hdp/current/atlas-server/tools/
# Download index-repair-tool.zip
unzip index-repair-tool.zip

kinit -kt /etc/security/keytabs/atlas.service.keytab $(klist -kt /etc/security/keytabs/atlas.service.keytab |sed -n "4p"|cut -d ' ' -f7)
python repair_index.py

[root@c274-node4 index-repair-tool]# python repair_index.py
Logging: /var/log/atlas/atlas-index-janus-repair.log
Initializing graph: Graph Initialized!
Restoring: vertex_index
: Time taken: 14924 ms: Done!
Restoring: edge_index
: Time taken: 2418 ms: Done!
Restoring: fulltext_index
: Time taken: 5153 ms: Done!
Repair Index: Done!
```
