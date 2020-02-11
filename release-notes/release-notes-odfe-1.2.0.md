## Open Distro for Elasticsearch 1.2.0 Release Notes

### **ALERTING**

* Cleanup ElasticThreadContextElement (#[95](https://github.com/opendistro-for-elasticsearch/alerting/pull/95))
* Don't allow interval to be set with 0 or negative values (#[92](https://github.com/opendistro-for-elasticsearch/alerting/pull/92))
* Update execute API to keep thread context. Use the ElasticThreadContextElement when executing a monitor to preserve the context variables needed (#[90](https://github.com/opendistro-for-elasticsearch/alerting/pull/90))

### **ALERTING KIBANA UI**

* Bump fstream from 1.0.11 to 1.0.12 (#[82](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/82))

### **PERFORMANCE ANALYZER**

* Add RCA RFC (#72)
* Reorder imports, refactor unit tests
* Fix unit tests on Mac. Fix Null Pointer Exception during MasterServiceEventMetrics collection
* Fix NullPointerException when Performance Analyzer starts collecting metrics before master node is fully up

### **SECURITY**

* Make permissions for protected index equal to that of the security index. Protected Index Kibana Fix 1.1 (#[132](https://github.com/opendistro-for-elasticsearch/security/pull/132))
* Add ability to block indices and index patterns to certain roles, adding another level of protection for these indices. Ability to protect indices even further. (#[126](https://github.com/opendistro-for-elasticsearch/security/pull/126))
* Initialize opendistro index if injected user enabled. (#[125](https://github.com/opendistro-for-elasticsearch/security/pull/125))
* Fix security configuration
* Bump com.fasterxml.jackson.core to version 2.9.9.2

### **SECURITY ADVANCED MODULES**

* Add supporting changes for protected index. Changes to support PrivilegesEvaluator in OpenDistroSecurityFlsDlsIndexSearcherWrapper. (#[37](https://github.com/opendistro-for-elasticsearch/security-advanced-modules/pull/37))
* Fix API endpoint naming
* Fix security configuration
* Bump com.fasterxml.jackson.core to version 2.9.9.2

### **SECURITY KIBANA UI**

* Fixed incorrect argument order when calling build.sh
* Fix password validation error
* Add ability to configure logout_url for 1.2 (#[82](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/82))
* Fix API endpoint naming

### **SQL**

* Support vanilla LEFT JOIN on nested docs (#[167](https://github.com/opendistro-for-elasticsearch/sql/pull/167))
* Add parent for SQLExpr in AST if missing (#[180](https://github.com/opendistro-for-elasticsearch/sql/pull/180))
* Ignore easily broken test on join limit hint (#[181](https://github.com/opendistro-for-elasticsearch/sql/pull/181))
* Support using attributes aliases in nested query where condition (#[178](https://github.com/opendistro-for-elasticsearch/sql/pull/178))
* Added 2 new functions LOWER and UPPER that receive field name and locale (#[177](https://github.com/opendistro-for-elasticsearch/sql/pull/177))
* Changed identifier generation strategy to id per function name instead of global id (#[128](https://github.com/opendistro-for-elasticsearch/sql/pull/128))
* Added ability to have aliases for ORDER BY and GROUP BY expressions (#[171](https://github.com/opendistro-for-elasticsearch/sql/pull/171))
* Removed timeouts from flaky tests, replacing them with mocked clock to check invariants (#[172](https://github.com/opendistro-for-elasticsearch/sql/pull/172))
* Fix for inlines corresponding to fields and expressions in parser and AggregationQueryAction (#[162](https://github.com/opendistro-for-elasticsearch/sql/pull/162))
* Inline ORDER BY expressions (#[168](https://github.com/opendistro-for-elasticsearch/sql/pull/168))
* Enhance ORDER BY to support cases (#[158](https://github.com/opendistro-for-elasticsearch/sql/pull/158))
* Return all fields when * and fieldName are selected (#[165](https://github.com/opendistro-for-elasticsearch/sql/pull/165))
* Adding left-out import statement from resolving conflict during merge (#[164](https://github.com/opendistro-for-elasticsearch/sql/pull/164))
* Supports queries with WHERE clauses that have True/False in the condition (#[157](https://github.com/opendistro-for-elasticsearch/sql/pull/157))
* Enabled checkstyle and fixed the issues for the code to build (#[163](https://github.com/opendistro-for-elasticsearch/sql/pull/163))
* More records in aggregation query output for script functions (#[160](https://github.com/opendistro-for-elasticsearch/sql/pull/160), #[156](https://github.com/opendistro-for-elasticsearch/sql/pull/156))
* Added support for PERCENTILES in JDBC driver; Fix for #26 (#[146](https://github.com/opendistro-for-elasticsearch/sql/pull/146))
* Fix single condition results for text+keyword field for nested query (#[135](https://github.com/opendistro-for-elasticsearch/sql/pull/135))
* Added .vscode and build/ to .gitignore (#[139](https://github.com/opendistro-for-elasticsearch/sql/pull/139))
* Support IN predicate subquery (#[126](https://github.com/opendistro-for-elasticsearch/sql/pull/126))
* Fix bug, terminate integTestCluster even when integration test failed (#[133](https://github.com/opendistro-for-elasticsearch/sql/pull/133))
* Fixed unit test failure that was identified on a Jenkins: date format needs to be in UTC for proper comparison (#[130](https://github.com/opendistro-for-elasticsearch/sql/pull/130))

### **SQL JDBC**

* Support customer AWS credential providers (#[22](https://github.com/opendistro-for-elasticsearch/sql-jdbc/pull/22))

### **JOB SCHEDULER, PERFTOP, SECURITY PARENT**

* No changes.
