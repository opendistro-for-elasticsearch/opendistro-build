# Open Distro for Elasticsearch 1.9.0 Release Notes

Open Distro for Elasticsearch 1.9.0 is now available for [download](https://opendistro.github.io/for-elasticsearch/downloads.html).

The release consists of Apache 2 licensed Elasticsearch version 7.8.0, and Kibana version 7.8.0. Plugins in the distribution include Alerting, Index Management, Performance Analyzer (with newly released feature: Root Cause Analysis Engine), Security, SQL, Machine Learning with k-NN, and Anomaly Detection. Also, SQL JDBC/ODBC driver, SQL CLI Client, and PerfTop (a client for Performance Analyzer) are available for download now.


## Release Highlights

* Introducing [Root Cause Analysis Engine](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca) in Performance Analyzer to facilitate conducting root cause analysis (RCA) for performance and reliability problems in Elasticsearch clusters
* Allowing batch actions such as [start, stop](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/195) and [delete](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/204) on anomaly detectors as part of the Anomaly Detection feature
* Support for [remote cluster indexes](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/244) in Anomaly Detection
* Introduce an ability to [set index priority action](https://github.com/opendistro-for-elasticsearch/index-management/pull/241) so that users are allowed to set the order of index recovery in Index State Management


## Release Details

The release of Open Distro for Elasticsearch includes the following features, enhancements, bug fixes, infrastructure, documentation, and maintenance updates.


## **Features**

### Anomaly Detection Kibana

* Add start/stop batch actions on detector list page ([#195](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/195))
* Feature: AD: Add delete batch action ([#204](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/204))
* Support remote cluster indices ([#244](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/244))

### K-NN

* ODFE 1.9 support for Elasticsearch version 7.8.0 ([#147](https://github.com/opendistro-for-elasticsearch/k-NN/pull/147))

### Performance Analyzer

* Add the Root Cause Analysis (RCA) Framework ([#12](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/12))
* Add gRPC based networking for RCA ([#13](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/13))
* Add young gen RCA and unit tests ([#41](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/41))
* Add API for RCA ([#61](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/61))
* Add HighCpuRca to collect total cpu usage ([#125](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/125))
* Add hot node RCA ([#128](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/128))
* Muting API ([#168](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/168))

### SQL ODBC

* Updating tableau connector files ([#96](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/96))
* Add 32bit support for driver ([#99](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/99))
* Pagination support ([#101](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/101))
* Add support for building with code coverage ([#107](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/107))
* Remove support for NOW in tableau connector ([#109](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/109))
* Updating SQLRowCount function support ([#112](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/112))
* Remove old driver files before installing Mac driver ([#114](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/114))
* Add CAP_SUPPRESS_GET_SERVER_TIME instead of removing support for NOW() in tableau connector ([#119](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/119))
* Use a queue which is created with a capacity while getting result pages  ([#120](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/120))


## **Enhancements**

### Anomaly Detection

* Delete deprecated getFeatureSamplesForPeriods getPreviewFeatures ([#151](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/151))
* Remove deprecated getCurrentFeatures ([#152](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/152))
* Not update threshold with zero scores ([#157](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/157))
* Threshold model outputs zero grades instead of nan grades ([#158](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/158))
* Configure rcf with new minimum samples ([#160](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/160))
* Rollover AD result index less frequently ([#168](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/168))
* Use aggregation's default value if no docs ([#167](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/167))
* Add setting for enabling/disabling circuit breaker ([#169](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/169))
* Add result indices retention period ([#174](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/174))

### Anomaly Detection Kibana

* Tune error message when creating detector ([#188](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/188))
* Use endTime of detectionInterval as plotTime on Dashboard live chart ([#190](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/190))
* Add scrolling and enhance list of affected detectors ([#201](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/201))
* Improve batch action modal loading state ([#216](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/216))
* Move textfield in delete batch action modal to bottom ([#217](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/217))
* Make all callouts optional on batch action modals ([#230](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/230))
* Remove static page of initialization and failure case, add auto-check of detector state when initializing ([#232](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/232))
* Rename 'last updated time' to 'last enabled time' on Detector list ([#233](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/233))
* Move plugin into Kibana app category ([#241](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/241))

### Index Management

* Implement set index priority action ([#241](https://github.com/opendistro-for-elasticsearch/index-management/pull/241))

### K-NN

* Remove/depricate shared library in buildSrc. ([#149](https://github.com/opendistro-for-elasticsearch/k-NN/pull/149))
* Modify artifact release Github action. ([#141](https://github.com/opendistro-for-elasticsearch/k-NN/pull/141))
* Add github action to build library artifacts. ([#132](https://github.com/opendistro-for-elasticsearch/k-NN/pull/132))
* Ability to dynamically update efSearch setting. ([#126](https://github.com/opendistro-for-elasticsearch/k-NN/pull/126))
* Fix test structure. ([#125](https://github.com/opendistro-for-elasticsearch/k-NN/pull/125))
* Build separate artifacts for library using CPack. ([#123](https://github.com/opendistro-for-elasticsearch/k-NN/pull/123))

### Security

* Added support for Elasticsearch 7.8.0 ([#516](https://github.com/opendistro-for-elasticsearch/security/pull/516))
* Allow superadmin to update/delete hidden resources ([#513](https://github.com/opendistro-for-elasticsearch/security/pull/513))
* Added metadata_content to SAML config ([#477](https://github.com/opendistro-for-elasticsearch/security/pull/477), [#495](https://github.com/opendistro-for-elasticsearch/security/pull/495))
* Implemented put if absent behavior for security config ([#402](https://github.com/opendistro-for-elasticsearch/security/pull/402))

### SQL

* Support Integration Tests for Security enabled ODFE cluster ([#473](https://github.com/opendistro-for-elasticsearch/sql/pull/473))

### SQL CLI

* Update project layout for better module import ([#45](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/45))


## **Bug fixes**

### Anomaly Detection

* Fix retrying saving anomaly results ([#154](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/154))

### Anomaly Detection Kibana

* Fix issue where live chart height is only partial of window in fullscreen mode. Issue: #186 ([#189](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/189))
* Fix UT workflow to only run bootstrap once ([#210](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/210))
* Fix paths to DetectorsList module ([#211](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/211))
* Prevent unnecessary update when doing batch delete ([#219](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/219))

### Index Management

* Fixes snapshot bugs ([#244](https://github.com/opendistro-for-elasticsearch/index-management/pull/244))

### K-NN

* Bad recall from Lucene upgrade 8.5.1 ([#155](https://github.com/opendistro-for-elasticsearch/k-NN/pull/155))
* Add recursive option to zip ([#143](https://github.com/opendistro-for-elasticsearch/k-NN/pull/143))
* CMake fails to use c++11 CMake 2.8 ([#138](https://github.com/opendistro-for-elasticsearch/k-NN/pull/138))
* Fix Jacoco coverage issue introduced in odfe 1.8.0 ([#134](https://github.com/opendistro-for-elasticsearch/k-NN/pull/134))
* Fixes parent directory in makeJniLib gradle task ([#130](https://github.com/opendistro-for-elasticsearch/k-NN/pull/130))
* Flaky test cases caused by Counter Enum ([#125](https://github.com/opendistro-for-elasticsearch/k-NN/pull/125))

### Security

* Removed the faulty index exists check and have more predictable behavior ([#517](https://github.com/opendistro-for-elasticsearch/security/pull/517))
* Avoid using Basic Authorization header as JWT token ([#501](https://github.com/opendistro-for-elasticsearch/security/pull/501))
* Granted access to all packages under com.sun.jndi ([#494](https://github.com/opendistro-for-elasticsearch/security/pull/494))
* Prevented users from mapping to hidden/reserved opendistro_security_roles ([#486](https://github.com/opendistro-for-elasticsearch/security/pull/486))
* Checked for substitute permissions before attempting to use SafeObjectOutputStream ([#478](https://github.com/opendistro-for-elasticsearch/security/pull/478))

### SQL

* Fix ANTLR grammar for negative integer and floating point number ([#489](https://github.com/opendistro-for-elasticsearch/sql/pull/489))
* Bug fix, support long type for aggregation ([#522](https://github.com/opendistro-for-elasticsearch/sql/pull/522))

### SQL ODBC

* Fix ODBC administrator GUI on windows ([#118](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/118))

### SQL Workbench

* Bug fix: custom plugin icon displaying improperly ([#73](https://github.com/opendistro-for-elasticsearch/sql-workbench/pull/73))
* Fix: column name in result table shows alias if alias exists ([#75](https://github.com/opendistro-for-elasticsearch/sql-workbench/pull/75))


## **Infrastructure Updates**

### Anomaly Detection

* Add breaking changes in release notes ([#145](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/145))
* Change rcf from local to maven ([#150](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/150))
* Run tests on docker if docker image exists ([#165](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/165))
* Add auto release drafter ([#178](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/178))

### Anomaly Detection Kibana

* Bump dependencies with security vulnerabilities ([#197](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/197))
* Initial test case using Cypress ([#196](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/196))
* Mitigate vulnerability for minimist and kind-of ([#202](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/202))
* Automate release notes generation on pushes to master ([#226](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/226))
* Add more e2e test cases for Dashboard/Detector list ([#221](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/221))
* Add Cypress tests for dashboard and detector list ([#234](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/234))
* Add CI for e2e ([#208](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/208))
* Add delete actions UT and fix snapshots ([#235](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/235))


## Documentation Updates

### SQL

* Add Github badges to README ([#486](https://github.com/opendistro-for-elasticsearch/sql/pull/486))

### SQL CLI

* Added README badges ([#48](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/48))

### SQL ODBC

* Update build instructions ([#93](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/93))
* Update README ([#116](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/116))


## Maintenance

### Alerting

* Adds support for Elasticsearch 7.8.0 ([#219](https://github.com/opendistro-for-elasticsearch/alerting/pull/219))

### Alerting Kibana

* Adds support for Kibana 7.8.0 ([#163](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/163))

### Anomaly Detection

* Bump ES version to 7.8.0 ([#172](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/172))

### Anomaly Detection Kibana

* Bump Kibana compatibility to 7.8.0 ([#239](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/239))

### Index Management

* Adds support for Elasticsearch 7.8.0 ([#246](https://github.com/opendistro-for-elasticsearch/index-management/pull/246))

### Index Management Kibana

* Adds support for Kibana 7.8.0 ([#94](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/94))

### Performance Analyzer

* Version compatible with elasticsearch 7.8.0 ([#123](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/123))

### PerfTop

* Version compatible with elasticsearch 7.8.0 ([#50](https://github.com/opendistro-for-elasticsearch/perftop/pull/50))

### Security

* Updated Maven endpoint URL for deployment ([#519](https://github.com/opendistro-for-elasticsearch/security/pull/519))
* Avoid using reflection to instantiate OpenDistroSecurityFlsDlsIndexSearcherWrapper ([#511](https://github.com/opendistro-for-elasticsearch/security/pull/511))
* Bumped Jackson-databind version ([#509](https://github.com/opendistro-for-elasticsearch/security/pull/509))
* Refactored salt from compliance config into Salt class ([#506](https://github.com/opendistro-for-elasticsearch/security/pull/506))
* Fixed typo in DefaultOpenDistroSecurityKeyStore.java ([#502](https://github.com/opendistro-for-elasticsearch/security/pull/502))
* Refactored to use indexing operation listener for every index module call ([#491](https://github.com/opendistro-for-elasticsearch/security/pull/491))
* Moved compliance ignore users from audit config to compliance config ([#484](https://github.com/opendistro-for-elasticsearch/security/pull/484))
* Removed immutable indices from compliance config ([#483](https://github.com/opendistro-for-elasticsearch/security/pull/483))
* Updated CD workflow to publish artifacts to maven central ([#481](https://github.com/opendistro-for-elasticsearch/security/pull/481))
* Refactored Base64Helper class ([#468](https://github.com/opendistro-for-elasticsearch/security/pull/468))
* Refactored WildcardMatcher ([#458](https://github.com/opendistro-for-elasticsearch/security/pull/458))

### Security Kibana

* Upgrade Kibana to 7.8.0

### SQL

* Elasticsearch 7.8.0 compatibility ([#532](https://github.com/opendistro-for-elasticsearch/sql/pull/532))

### SQL CLI

* Elasticsearch 7.8.0 and ODFE SQL Plugin 1.9.0 compatibility ([#55](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/55))

### SQL JDBC

* Elasticsearch 7.8.0 compatibility ([#87](https://github.com/opendistro-for-elasticsearch/sql-jdbc/pull/87))

### SQL Workbench

* Support v7.8.0 compatibility ([#80](https://github.com/opendistro-for-elasticsearch/sql-workbench/pull/80))

### Job Scheduler

* Adds support for Elasticsearch 7.8.0 ([#63](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/63))

You can also track upcoming features in Open Distro for Elasticsearch by watching the code repositories or checking the [project website](https://opendistro.github.io/for-elasticsearch/features/comingsoon.html).


