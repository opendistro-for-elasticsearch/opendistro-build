## Open Distro for Elasticsearch 1.6.0 Release Notes

The release consists of Apache 2 licensed Elasticsearch version 7.6.1, Kibana version 7.6.1 and plugins for alerting, index management, performance analyzer, security, SQL and machine learning with k-NN. Also included are a SQL JDBC driver and PerfTop, a client for Performance Analyzer.

The release includes the following features, enhancements, infra and config updates and bug fixes.

### **Features**

**INDEX MANAGEMENT**

* Adds isIdempotent method to each step and updates ManagedIndexRunner to use it (#[165](https://github.com/opendistro-for-elasticsearch/index-management/pull/165))

**JOB SCHEDULER**

* Add jitter in job parameters (#[42](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/42))

**SECURITY**

* [Optimization] Implement faster version of implies type perm ([#198](https://github.com/opendistro-for-elasticsearch/security/pull/198))
* Adding capability to hot reload ssl certificates ([#263](https://github.com/opendistro-for-elasticsearch/security/pull/263))
* Added SuperAdmin check to allow update/delete/add of reserved config ([#242](https://github.com/opendistro-for-elasticsearch/security/pull/242))
* Fix to use inner channel when channel is not direct or transport type ([#234](https://github.com/opendistro-for-elasticsearch/security/pull/234))
* Fix for modifying user backend-roles without giving password ([#225](https://github.com/opendistro-for-elasticsearch/security/pull/225))

**SECURITY KIBANA UI**

* Support Kibana 7.6.1 ([#154](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/154))
* Specify headers to be stored in session ([#147](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/147))


### **Enhancements**

**k-NN**

* Lazy loading efSearch parameter ([#52](https://github.com/opendistro-for-elasticsearch/k-NN/pull/52))

**SECURITY**

* Implement faster version of implies type perm (#[198](https://github.com/opendistro-for-elasticsearch/security/pull/198))
* Memoize results of resolveIndexPatterns for Bulk requests (#[309](https://github.com/opendistro-for-elasticsearch/security/pull/309))

**SQL**

* Report date data as a standardized format ([#367](https://github.com/opendistro-for-elasticsearch/sql/pull/367))
* Exception Handling: Handle Elasticsearch exceptions in JDBC formatted outputs([#362](https://github.com/opendistro-for-elasticsearch/sql/pull/362))
* Exception Handling: Modified the wording of exception messages and created the troubleshooting page([#372](https://github.com/opendistro-for-elasticsearch/sql/pull/372))


### **Infra Updates**

**ALERTING**

* Modified upload release asset action ([#191](https://github.com/opendistro-for-elasticsearch/alerting/pull/191))
* Workflow syntax (#[188](https://github.com/opendistro-for-elasticsearch/alerting/pull/188))
* Updates java version in push notification workflow (#[187](https://github.com/opendistro-for-elasticsearch/alerting/pull/187))
* Adds support for ES 7.6.1 (#[186](https://github.com/opendistro-for-elasticsearch/alerting/pull/186))
* Update test-workflow.yml (#[183](https://github.com/opendistro-for-elasticsearch/alerting/pull/183))
* Added release workflow (#[180](https://github.com/opendistro-for-elasticsearch/alerting/pull/180))
* Push Notification Jar to Maven (#[174](https://github.com/opendistro-for-elasticsearch/alerting/pull/174))

**ALERTING KIBANA UI**

* Adds support for Kibana 7.6.1 ([_#118_](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/118))
* Update dependencies are eslintrc file (#[119](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/119))
* Fixes release notes PR link (#[120](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/120))
* Adds test workflow and updates snapshot (#[121](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/121))

**INDEX MANAGEMENT**

* Updates files with missing license headers (#[152](https://github.com/opendistro-for-elasticsearch/index-management/pull/152))
* Added release workflow (#[163](https://github.com/opendistro-for-elasticsearch/index-management/pull/163))
* Support ES version 7.6.1 ([#164](https://github.com/opendistro-for-elasticsearch/index-management/pull/164))
* Due to Changes in ES test framework since 7.5; Update Jacoco (code coverage); Update gradle tasks integTest and testClusters; Update debug method and new debug option cluster.debug

**INDEX MANAGEMENT KIBANA UI**

* Adds support for Kibana 7.6.1 (#[83](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/83))
* Adds basic unit test workflow (#[84](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/84))

**k-NN**

* Elasticsearch 7.6.1 compatibility ([#72](https://github.com/opendistro-for-elasticsearch/k-NN/pull/72))
* Add Github Actions so that changes are automatically tested and artifacts are uploaded to S3 ([#73](https://github.com/opendistro-for-elasticsearch/k-NN/pull/73))
* Convert integration tests from ESIntegTestCase to ESRestTestCase, so that they can be run on a remote cluster ([#61](https://github.com/opendistro-for-elasticsearch/k-NN/pull/61))
* Add check in Gradle build for license headers ([#54](https://github.com/opendistro-for-elasticsearch/k-NN/pull/54))

**JOB SCHEDULER**

* Push job-scheduler Jar to Maven (#[44](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/44))
* Support ES version 7.6.1 (#[46](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/46))
* use JDK 13 for push jar workflow (#[49](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/49))
* Update spi to use gradle elasticsearch build plugin (#[50](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/50))
* Modified nebula version and added release workflow (#[51](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/51))

**PERFORMANCE ANALYZER**

* Add PA plugin support for ElasticSearch v7.6.1 (#[89](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/89))
* Add cd.yml and enable CD pipeline to upload artifact to S3 (#[90](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/90))

**PERFTOP**

* Add support for ODFE 1.6 (#[38](https://github.com/opendistro-for-elasticsearch/perftop/pull/38))
* Add cd.yml and enable CD pipeline to upload artifact to S3 (#[41](https://github.com/opendistro-for-elasticsearch/perftop/pull/41))

**SECURITY**

* Add url to pom.xml for maven central uploads
* Fix 7.5.2 version in build gradle and add CD workflow (#[231](https://github.com/opendistro-for-elasticsearch/security/pull/231))
* Removed OpenSSL for 7.4 (#[224](https://github.com/opendistro-for-elasticsearch/security/pull/224))
* Fix to use inner channel when channel is not direct or transport type (#[234](https://github.com/opendistro-for-elasticsearch/security/pull/234))
* Function name change
* Reverse the logic to make sense to the caller
* Changed test admincert variable name and renamed test function to reflect proper functionality
* Fix 7.5.2 version in build Gradle and add CD workflow (#[232](https://github.com/opendistro-for-elasticsearch/security/pull/232))
* Added SuperAdmin check to allow update/delete/add of reserved config (#[242](https://github.com/opendistro-for-elasticsearch/security/pull/242))
* Add unit test for disallowing anyone apart from SuperAdmin to alter the reserved resources
* Merge opendistro-1.4 changes back into master (#[248](https://github.com/opendistro-for-elasticsearch/security/pull/248))
* Bump jackson-databind from 2.9.10.1 to 2.9.10.3 (#[272](https://github.com/opendistro-for-elasticsearch/security/pull/272))
* Adding capability to hot reload ssl certificates (#[263](https://github.com/opendistro-for-elasticsearch/security/pull/263))
* Version bump 1.5.0.1 (#[282](https://github.com/opendistro-for-elasticsearch/security/pull/282))
* Support Elasticsearch 7.6.1 ([#292](https://github.com/opendistro-for-elasticsearch/security/pull/292))

**SQL**

* Elasticsearch 7.6.1 compatibility ([#376](https://github.com/opendistro-for-elasticsearch/sql/issues/376))
* Integration test with external ES cluster ([#374](https://github.com/opendistro-for-elasticsearch/sql/pull/374))
* CI/CD using GitHub Actions workflow ([#384](https://github.com/opendistro-for-elasticsearch/sql/pull/384))
* Documentation for simple query ([#366](https://github.com/opendistro-for-elasticsearch/sql/pull/366))
* Documentation for Pagination ([#379](https://github.com/opendistro-for-elasticsearch/sql/pull/379))


### **Config Updates**

**KIBANA**

* Update kibana.yml telemetry.optIn and telemetry.enabled to false. Data collection is now disabled by default.
* Update kibana.yml newsfeed.enabled to false. Newsfeed is now disabled by default.


### **Bug fixes**

**K-NN**

* Flaky failure in KNN80HnswIndexTests testFooter ([#66](https://github.com/opendistro-for-elasticsearch/k-NN/pull/66))
* Circuit Breaker fails to turn off ([#63](https://github.com/opendistro-for-elasticsearch/k-NN/pull/63))
* Gradle build failure on Mac due to library error ([#59](https://github.com/opendistro-for-elasticsearch/k-NN/pull/59))
* AccessControlException when HNSW library is loaded ([#53](https://github.com/opendistro-for-elasticsearch/k-NN/pull/53))
* Stats API failure in Transport Layer ([#47](https://github.com/opendistro-for-elasticsearch/k-NN/pull/47))


**SECURITY KIBANA UI**

* Fix Security multi-tenancy "Show Dashboard" button should redirect users to the dashboards page [#143](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/143) (ported to master via [#144](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/144))
* Fix headers whitelist to throw missing role error [#137](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/137) (ported to master via [#144](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/144))
* Fix overlay confirmation modal dialog [#136](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/136) (ported to master via [#144](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/144))


**SQL**

* Add DATETIME cast support ([#310](https://github.com/opendistro-for-elasticsearch/sql/pull/310))
* Return Correct Type Information for Fields ([#365](https://github.com/opendistro-for-elasticsearch/sql/pull/365))
* Return object type for field which has implicit object datatype when describe the table ([#377](https://github.com/opendistro-for-elasticsearch/sql/pull/377))
* FIX field function name letter case preserved in select with group by ([#381](https://github.com/opendistro-for-elasticsearch/sql/pull/381))


### **What’s in development?**

1. [_Performance Analyzer RCA Engine_](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca)
2. [_Anomaly Detection_](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin) and its [Kibana UI](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin)
3. [_SQL ODBC Driver_](https://github.com/opendistro-for-elasticsearch/sql-odbc)
