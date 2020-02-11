## Open Distro for Elasticsearch 0.9.0 Release Notes

All plug-ins now support for Elasticsearch release version 6.7.1.

### **ALERTING**

* Added support for Elasticsearch 6.7.1 - [#19](https://github.com/opendistro-for-elasticsearch/alerting/pull/19)
* Added http proxy support to outgoing notifications - [#23](https://github.com/opendistro-for-elasticsearch/alerting/pull/23)
* Allow encoding while constructing HTTP request for sending notification - [#35](https://github.com/opendistro-for-elasticsearch/alerting/pull/35)
* Added build for Debian - [#36](https://github.com/opendistro-for-elasticsearch/alerting/pull/36)
* Fixed update LastFullSweepTime if the index doesn't exist - [#17](https://github.com/opendistro-for-elasticsearch/alerting/pull/17)
* Added more alert properties to templateArgs for context variable - [#26](https://github.com/opendistro-for-elasticsearch/alerting/pull/26)

### **ALERTING KIBANA UI**

* Added support for Kibana 6.7.1 - [#32](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/32)
* Added DELETED alert state to Dashboard filter - [#37](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/37)
* Set min property on interval input - [#39](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/39)

### **SECURITY**

* Handle attributes when impersonating user - [#23](https://github.com/opendistro-for-elasticsearch/security/pull/23)

### **PERFORMANCE ANALYZER**

* Added master metrics - [#15](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/15)
* Use ES_HOME and JAVA_HOME environment variables in startup script - [#24](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/24)
* Fixed unit test - [#26](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/26)
* Added https support - [#33](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/33)

### **PERFTOP**

* Making perftop ready to be installed globally using npm - [#9](https://github.com/opendistro-for-elasticsearch/perftop/pull/9)

### **SQL**

* Added integration tests - [#21](https://github.com/opendistro-for-elasticsearch/sql/pull/21) [#22](https://github.com/opendistro-for-elasticsearch/sql/pull/22) [#24](https://github.com/opendistro-for-elasticsearch/sql/pull/24) [#28](https://github.com/opendistro-for-elasticsearch/sql/pull/28) [#31](https://github.com/opendistro-for-elasticsearch/sql/pull/31)
* Updated version and fix test, config - [#30](https://github.com/opendistro-for-elasticsearch/sql/pull/30)

### **SQL JDBC**

* Corrected name and description in published pom - [#8](https://github.com/opendistro-for-elasticsearch/sql-jdbc/pull/8)
