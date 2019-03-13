# - [x] Solr Commands



## Delete collection by running curl from solr node

###### This is an <h6> tag
###### This is for Ranger audit collection
`curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=ranger_audits"`

###### This is for Atlas collection
```xml
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=fulltext_index"
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=edge_index"
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=vertex_index"
```

###### This is for Logsearch collection
```python
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=history"
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=hadoop_logs"
curl --negotiate -u : "http://$(hostname -f):8886/solr/admin/collections?action=DELETE&name=audit_logs"
```
