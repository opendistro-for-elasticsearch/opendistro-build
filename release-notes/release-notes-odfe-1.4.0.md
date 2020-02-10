## Open Distro for Elasticsearch 1.4.0 Release Notes 

All plugins are compatible with Elasticsearch 7.4.2 version 

## ENHANCEMENTS

### **ALERTING**

* Adds settings to disable alert history and delete old history indices   [#143](https://github.com/opendistro-for-elasticsearch/alerting/pull/143)
* Adds maven publish task for notification subproject for other plugins to utilize   [#97](https://github.com/opendistro-for-elasticsearch/alerting/pull/97)

### **KNN** 

* KNN Codec Backward Compatibility support   [#20](https://github.com/opendistro-for-elasticsearch/k-NN/issues/20)

### **SECURITY**

* Add Account API to enable users to change their own password (ported back to ODFE version 0.9 to 1.3)   [#200](https://github.com/opendistro-for-elasticsearch/security/pull/200)
* Removed support of OpenSSL for Java 12+  [#197](https://github.com/opendistro-for-elasticsearch/security/pull/197)
* Merged all security repos in one for better maintainability (security-parent and security-advanced-modules into security) (ported back to ODFE version 1.0 to 1.3)   [#189](https://github.com/opendistro-for-elasticsearch/security/pull/189), [#191](https://github.com/opendistro-for-elasticsearch/security/pull/191)

### **SECURITY UI**

* Added UI support for Account API to enable users to change their own password. (ported back to ODFE version 0.9 to 1.3)    [#126](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/126)
* UI support for adding Opendistro Security Role into internal user of the security config page  [#116](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/116) 

### **SQL**

* Support function over aggregation result  [#346](https://github.com/opendistro-for-elasticsearch/sql/pull/346), [#352](https://github.com/opendistro-for-elasticsearch/sql/pull/352), [#194](https://github.com/opendistro-for-elasticsearch/sql/issues/194), [#229](https://github.com/opendistro-for-elasticsearch/sql/issues/229), [#270](https://github.com/opendistro-for-elasticsearch/sql/issues/270), [#292](https://github.com/opendistro-for-elasticsearch/sql/issues/292)
* Support conditional functions: IF, IFNULL, ISNULL  [#273](https://github.com/opendistro-for-elasticsearch/sql/pull/273), [#224](https://github.com/opendistro-for-elasticsearch/sql/issues/224), [#235](https://github.com/opendistro-for-elasticsearch/sql/issues/235)
* Support JOIN without table alias  [#274](https://github.com/opendistro-for-elasticsearch/sql/pull/274), [#232](https://github.com/opendistro-for-elasticsearch/sql/issues/232)
* Support subquery in from with parent only has select [#278](https://github.com/opendistro-for-elasticsearch/sql/pull/278), [#230](https://github.com/opendistro-for-elasticsearch/sql/issues/230)
* Support datetime functions: MONTH, DAYOFMONTH, DATE, MONTHNAME, TIMESTAMP, MAKETIME, NOW, CURDATE  [#282](https://github.com/opendistro-for-elasticsearch/sql/pull/282), [#235](https://github.com/opendistro-for-elasticsearch/sql/issues/235)
* Support DISTINCT feature in SELECT clause  [#300](https://github.com/opendistro-for-elasticsearch/sql/pull/300), [#294](https://github.com/opendistro-for-elasticsearch/sql/issues/294)

### **LEXER AND SEMANTIC**

* Syntax and semantic exceptions handling for unsupported features  [#345](https://github.com/opendistro-for-elasticsearch/sql/pull/345),  [#320](https://github.com/opendistro-for-elasticsearch/sql/issues/320)

### **RESPONSE**

* Change the default response format to JDBC  [#334](https://github.com/opendistro-for-elasticsearch/sql/pull/334), [#159](https://github.com/opendistro-for-elasticsearch/sql/issues/159) 

## Bug Fixes 

### **ALERTING** 

* Removes unsupported HttpInput types which was breaking Alerting Kibana  [#162](https://github.com/opendistro-for-elasticsearch/alerting/pull/162)
* Fixes missing constructors for Stats when updating to 7.4.2   [#142](https://github.com/opendistro-for-elasticsearch/alerting/pull/142)
* Fixes multi node alerting stats API  [#128](https://github.com/opendistro-for-elasticsearch/alerting/pull/128)

### **INDEX MANAGEMENT**

* Fixes issue where action timeout was using start_time from previous action  [#133](https://github.com/opendistro-for-elasticsearch/index-management/pull/133)

### **KNN**

* Native memory leak in saveIndex and JVM leak  [#14](https://github.com/opendistro-for-elasticsearch/k-NN/pull/14), [#15](https://github.com/opendistro-for-elasticsearch/k-NN/pull/15) 

### **SECURITY**

* Fix for modifying user backend-roles without a need of updating password (ported back to ODFE version 0.9 to 1.3) [#225](https://github.com/opendistro-for-elasticsearch/security/pull/225)

### **SQL** 

* Fixed operatorReplace Integration Test  [#267](https://github.com/opendistro-for-elasticsearch/sql/pull/267), [#266](https://github.com/opendistro-for-elasticsearch/sql/issues/266)
* Fix issue that IP type cannot pass JDBC formatter [#275](https://github.com/opendistro-for-elasticsearch/sql/pull/275),  [#272](https://github.com/opendistro-for-elasticsearch/sql/issues/272)
* Fixed flaky test suite, that was breaking Github action build [#284](https://github.com/opendistro-for-elasticsearch/sql/pull/284)
* Corrected the selected field names displayed in the schema of JDBC formatted response [#295](https://github.com/opendistro-for-elasticsearch/sql/pull/295), [#290](https://github.com/opendistro-for-elasticsearch/sql/issues/290)
* Fixed functions work improperly with fieldvalue/constant param for current use [#296](https://github.com/opendistro-for-elasticsearch/sql/pull/296), [#279](https://github.com/opendistro-for-elasticsearch/sql/issues/279), [#291](https://github.com/opendistro-for-elasticsearch/sql/issues/291), [#224](https://github.com/opendistro-for-elasticsearch/sql/issues/224)
* Fixed issue of log10 function gets inaccurate results [#298](https://github.com/opendistro-for-elasticsearch/sql/pull/298),  [#297](https://github.com/opendistro-for-elasticsearch/sql/issues/297)
* Fix the issue of column alias not working for GROUP BY [#307](https://github.com/opendistro-for-elasticsearch/sql/pull/307),  [#299](https://github.com/opendistro-for-elasticsearch/sql/issues/299)
* Fixed the issue of substring not working correctly when fieldname is put as [#333](https://github.com/opendistro-for-elasticsearch/sql/pull/333), [#330](https://github.com/opendistro-for-elasticsearch/sql/issues/330)
*  Fix JDBC response for delete query [#337](https://github.com/opendistro-for-elasticsearch/sql/pull/337), [#131](https://github.com/opendistro-for-elasticsearch/sql/issues/131)

### **SQL-JDBC** 

* Result set metadata returns Elasticsearch type [#47](https://github.com/opendistro-for-elasticsearch/sql-jdbc/pull/47), [#43](https://github.com/opendistro-for-elasticsearch/sql-jdbc/issues/43)
* Add missing Elasticsearch type : object  [#45](https://github.com/opendistro-for-elasticsearch/sql-jdbc/pull/45), [#44](https://github.com/opendistro-for-elasticsearch/sql-jdbc/issues/44)
* Added IP type and mapped with JDBC type of varchar [#32](https://github.com/opendistro-for-elasticsearch/sql-jdbc/pull/32)

## TESTING


### **JOB SCHEDULER**

* Adds build and test github workflows to automate testing of each PR  [#30](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/30)

### **SECURITY** 

* CI using github Action (Build, unit-test, test coverage with codecov and package) (ported back to ODFE version 0.9 to 1.3) [#179](https://github.com/opendistro-for-elasticsearch/security/pull/179)

### **SQL** 

* Sql test bench bug fix, improvement and more test cases  [#343](https://github.com/opendistro-for-elasticsearch/sql/pull/343), [#335](https://github.com/opendistro-for-elasticsearch/sql/issues/335), [#339](https://github.com/opendistro-for-elasticsearch/sql/issues/339)
* Added github action to build and run tests. Gradle build will publish compiled plugin, that is ready to install into elasticsearch [#283](https://github.com/opendistro-for-elasticsearch/sql/pull/283), [#287](https://github.com/opendistro-for-elasticsearch/sql/pull/287)

## **DOCUMENTATION** 

### **KNN** 

*  Documentation on knn index creation, settings and stats [#40](https://github.com/opendistro-for-elasticsearch/k-NN/issues/40), [#37](https://github.com/opendistro-for-elasticsearch/k-NN/issues/37)

### **SQL** 

* Documentation for basic usage of plugin & improvement of contributing docs [#302](https://github.com/opendistro-for-elasticsearch/sql/pull/302), [#305](https://github.com/opendistro-for-elasticsearch/sql/pull/305), [#303](https://github.com/opendistro-for-elasticsearch/sql/pull/303), [#293](https://github.com/opendistro-for-elasticsearch/sql/issues/293), [#243](https://github.com/opendistro-for-elasticsearch/sql/issues/243)

### **SQL-JDBC** 

* Tableau documentation [#37](https://github.com/opendistro-for-elasticsearch/sql-jdbc/pull/37)
* Add documentation for connecting Tableau with OpenDistro for Elasticsearch using JDBC Driver [#35](https://github.com/opendistro-for-elasticsearch/sql-jdbc/pull/35)

## **DEPRECATION** 

* Security Parent (Deprecated): Merged security-parent to security repo [#32](https://github.com/opendistro-for-elasticsearch/security-parent/pull/32)
* Security Advanced Modules (Deprecated) : Merged security-advanced-module to security repo [#75](https://github.com/opendistro-for-elasticsearch/security-advanced-modules/pull/75)
