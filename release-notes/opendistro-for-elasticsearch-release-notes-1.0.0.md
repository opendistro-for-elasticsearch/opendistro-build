## Open Distro for Elasticsearch 1.0.0 Release Notes

## **Breaking Changes**

* Open Distro for Elasticsearch 1.0.0 uses Elasticsearch 7.0.1, which has numerous breaking changes from 6.x.x.
* Please follow the support docs during the upgrade. ([Support Docs](https://opendistro.github.io/for-elasticsearch-docs/docs/upgrade/1-0-0/))

### **ALERTING**

* Added support for Elasticsearch 7.0.1 - PR [41](https://github.com/opendistro-for-elasticsearch/alerting/pull/41)
* Added index mapping schema versioning - PR [61](https://github.com/opendistro-for-elasticsearch/alerting/pull/61)
* Added maximum limit for throttle - PR [67](https://github.com/opendistro-for-elasticsearch/alerting/pull/67)
* Configure action throttle max value in ES setting - PR [69](https://github.com/opendistro-for-elasticsearch/alerting/pull/69)
* Fixed throttle action - PR [59](https://github.com/opendistro-for-elasticsearch/alerting/pull/59)
* Resolved PR 58 return error response - PR [72](https://github.com/opendistro-for-elasticsearch/alerting/pull/72)

### **ALERTING KIBANA UI**

* Added support for Elasticsearch, Kibana 7.0.1 - PRs [43](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/43), [44](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/44)
* Change text for visual monitor graph; Fixes PR 33 - PR [47](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/47)
* Add throttle on action level - PR [45](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/45)
* Add where clause filters support on visual monitor - PR [42](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/42)
* No documents for aggregations count as false - PR [38](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/38)
* Updated pre-commit hook config - PR [46](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/46)
* Correct documentation URL - PR [50](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/50)
* Update placeholder text for whereFilter - PR [54](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/54)
* Enhance action throttle UI - PR [56](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/56)
* Add throttle constraint text - PR [58](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/58)
* Update package.json - PR [59](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/59)
* Fix update monitor from monitor list - PR [64](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/64)

### **PERFORMANCE ANALYZER**

* No checks on teardown - PR [50](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/50)
* Change trimDatabases signature to make it callable from tests - PR [49](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/49)
* Making the metricsdb files to keep around configurable - PR [48](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/48)
* Added tests for the trimDatabases method
* Add access logs to performance analyzer webservice

### **PERFTOP**

* Support https requests without certificate authentication - PR [19](https://github.com/opendistro-for-elasticsearch/perftop/pull/19)
* Version upgrade and remove package vulnerabilities - PR [20](https://github.com/opendistro-for-elasticsearch/perftop/pull/20)
* Update OpenDistro version in Gradle

### **SECURITY**

* Correcting config parameter name in example config - PR [44](https://github.com/opendistro-for-elasticsearch/security/pull/44)
* Added support For Elasticsearch 7.0.1 - PR [55](https://github.com/opendistro-for-elasticsearch/security/pull/55)
* Set algorithm for JWK (RSA) in security-advanced-modules - PR [11](https://github.com/opendistro-for-elasticsearch/security-advanced-modules/pull/11)
* Updated [source build documentation](https://github.com/opendistro-for-elasticsearch/security-parent/blob/master/README.md) in security parent for security artifacts

### **SECURITY KIBANA UI**

* Added support for Elasticsearch and Kibana 7.0.1 PR [24](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/24)
    * Added migration feature to securityadmin.sh to help you move from the old file format to the new format
    * Streamlined the YAML configuration file syntax
    * Updated static default roles so that permission changes to these roles are automatically applied when you upgrade Open Distro for Elasticsearch
    * Added new LDAP/Active Directory module
    * Renamed scope.multiTenancy to scope.multiTenancyEnabled

### **SQL**

* Updated release notes for version 1.0.0 - PR [79](https://github.com/opendistro-for-elasticsearch/sql/pull/79)
* Converting HashJoinBasicTest to ESIntegTestCase - PR [74](https://github.com/opendistro-for-elasticsearch/sql/pull/74)
* Integration migration - PR [77](https://github.com/opendistro-for-elasticsearch/sql/pull/77)
* Migrated DateFunctionsTest, DeleteTest - PR [70](https://github.com/opendistro-for-elasticsearch/sql/pull/70)
* Added support for number field - PR [68](https://github.com/opendistro-for-elasticsearch/sql/pull/68)
* Migrated JSONRequestIT, MathFunctionsIT, MethodQueryIT to esintgtest package - PR [66](https://github.com/opendistro-for-elasticsearch/sql/pull/66)
* Migrated SqlParserTests, TermQueryExplainTest, and UtilsTest - PR [67](https://github.com/opendistro-for-elasticsearch/sql/pull/67)
* Added support for enabling/disabling SQL feature - PR [65](https://github.com/opendistro-for-elasticsearch/sql/pull/65)
* Migrated the last batch of join tests - PR [61](https://github.com/opendistro-for-elasticsearch/sql/pull/61)
* Move SQLFunctionsIT to esintegtest package - PR [57](https://github.com/opendistro-for-elasticsearch/sql/pull/57)
* Added test coverage report - PR [56](https://github.com/opendistro-for-elasticsearch/sql/pull/56)
* Use elasticsearch-oss for integration tests - PR [55](https://github.com/opendistro-for-elasticsearch/sql/pull/55)
* Fixed Unicode character handling in tests
* Fixed order of fields in csv output - PR [44](https://github.com/opendistro-for-elasticsearch/sql/pull/44)
* Added support for mvn build and integration-test for Elasticsearch 7.0.1 - PR [51](https://github.com/opendistro-for-elasticsearch/sql/pull/51)
* Fixing failing integration tests for mvn build - PR [49](https://github.com/opendistro-for-elasticsearch/sql/pull/49)
* Handle requests with different output formats more consistently - PR [45](https://github.com/opendistro-for-elasticsearch/sql/pull/45)
* Fixed percentile query result in csv output - PR [37](https://github.com/opendistro-for-elasticsearch/sql/pull/37)
* Added support for Elasticsearch 7.0.1 - PR [47](https://github.com/opendistro-for-elasticsearch/sql/pull/47), PR [48](https://github.com/opendistro-for-elasticsearch/sql/pull/48)

### **SQL JDBC**

* Updated contribution guidelines to request tests for all the code changes - PR [16](https://github.com/opendistro-for-elasticsearch/sql-jdbc/issues/16)
* Bump version number to 1.0.0 - PR [13](https://github.com/opendistro-for-elasticsearch/sql-jdbc/issues/13)
* Fix for timestamp with time zone datatype in PR [6](https://github.com/opendistro-for-elasticsearch/sql-jdbc/issues/6) - PR [10](https://github.com/opendistro-for-elasticsearch/sql-jdbc/issues/10)

### **JOB SCHEDULER**

* Added support for ES 7.0, use primary_term and seq_no for job doc versioning - PR [5](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/5)
* Added support scheduledJob with locks - PR [8](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/8)
* Updated release-notes and debian package build - PR [9](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/9)
* Refactored JobSweeper to do sweep on certain clusterChangedEvent - PR [10](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/10)
* Changed log level when sweeper already have latest job version - PR [11](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/11)
* Override equals and hashCode for LockModel - PR [12](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/12)
* Adds equals, hashCode, toString overrides to IntervalSchedule and CronSchedule PR [13](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/13)
* Use ROOT locale for strings - PR [14](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/14)
