# Open Distro for Elasticsearch 1.13.0 Release Notes

Open Distro for Elasticsearch 1.13.0 is now available for download.

The release consists of Apache 2 licensed Elasticsearch version 7.10.2 and Kibana version 7.10.2. Plugins in the distribution include Alerting, Index Management, Performance Analyzer (with Root Cause Analysis Engine), Security, SQL, Machine Learning with k-NN, Job Scheduler, Anomaly Detection, Kibana Notebooks, Reports, Asynchronous-Search, and Gantt Chart. Also, SQL JDBC/ODBC driver, SQL CLI Client, and PerfTop (a client for Performance Analyzer) are available for download now.

## Release Highlights

* [Asynchronous search](https://opendistro.github.io/for-elasticsearch-docs/docs/async/) lets you run queries across large data sets, or data sets that span multiple clusters, and allows Elasticsearch clients to receive results as they become available. 

* Historical data analysis is now available in [Anomaly Detection](https://opendistro.github.io/for-elasticsearch-docs/docs/ad/). With this feature, you can analyze and apply machine learning models over long historical data windows to identify anomaly patterns, seasonality, and trends.

* You can now run Open Distro for Elasticsearch on **64-bit ARM processors**. ARM support has been one of the most requested features for Open Distro, and is another step toward making it easy to deploy and run on premises or in the cloud on the architecture of your choice.

* Starting with Open Distro 1.13, you can use [identifier names containing special characters](https://github.com/opendistro-for-elasticsearch/sql/blob/develop/docs/user/general/identifiers.rst).The SQL engine now supports complex [nested expressions](https://github.com/opendistro-for-elasticsearch/sql/blob/develop/docs/user/dql/expressions.rst), and lets you perform queries that contain the [HAVING clause without GROUP BY](https://github.com/opendistro-for-elasticsearch/sql/blob/develop/docs/user/dql/aggregations.rst#having-without-group-by) and [subqueries in FROM clauses](https://github.com/opendistro-for-elasticsearch/sql/blob/develop/docs/user/dql/complex.rst#example-2-subquery-in-from-clause). With enhanced [PartiQL (JSON) support](https://github.com/opendistro-for-elasticsearch/sql/blob/develop/docs/user/beyond/partiql.rst#example-2-selecting-deeper-levels), you can query object fields at deeper levels.


## Release Details

Open Distro for Elasticsearch 1.13.0 includes the following breaking changes, features, enhancements, bug fixes, infrastructure, documentation, maintenance, and refactoring updates.

## BREAKING CHANGES
* We have renamed Open Distro For Elasticsearch Plugins, Clients and Drivers with kebab-case naming convention. You can find the details below:

|Old Artifact Name   |New Artifact Name |
| ----------- | ----------- |
|opendistro_sql-1.12.0.0.zip    |opendistro-sql-1.13.0.0.zip    |
|opendistro-sql_1.12.0.0-1_amd64.deb    |opendistro-sql-1.13.0.0.deb    |
|opendistro-sql-1.12.0.0-1.noarch.rpm   |opendistro-sql-1.13.0.0.rpm    |
|opendistro_alerting-1.12.0.2.zip   |opendistro-alerting-1.13.0.0.zip   |
|opendistro-alerting_1.12.0.2-1_amd64.deb   |opendistro-alerting-1.13.0.0.deb   |
|opendistro-alerting-1.12.0.2-1.noarch.rpm  |opendistro-alerting-1.13.0.0.rpm   |
|opendistro-job-scheduler-1.12.0.0.zip  |No change  |
|opendistro-job-scheduler_1.12.0.0-1_amd64.deb  |opendistro-job-scheduler-1.13.0.0.deb  |
|opendistro-job-scheduler-1.12.0.0-1.noarch.rpm |opendistro-job-scheduler-1.13.0.0.rpm  |
|opendistro_security-1.12.0.0.zip   |opendistro-security-1.13.0.0.zip   |
|opendistro-security-1.12.0.0.deb   |No change  |
|opendistro-security-1.12.0.0.rpm   |No change  |
|opendistro_performance_analyzer-1.12.0.0.zip   |opendistro-performance-analyzer-1.13.0.0.zip   |
|opendistro-performance-analyzer_1.12.0.0-1_amd64.deb   |opendistro-performance-analyzer-1.13.0.0.deb   |
|opendistro-performance-analyzer-1.12.0.0-1.noarch.rpm  |opendistro-performance-analyzer-1.13.0.0.rpm   |
|opendistro_index_management-1.12.0.1.zip   |opendistro-index-management-1.13.0.0.zip   |
|opendistro-index-management_1.12.0.1-1_amd64.deb   |opendistro-index-management-1.13.0.0.deb   |
|opendistro-index-management-1.12.0.1-1.noarch.rpm  |opendistro-index-management-1.13.0.0.rpm   |
|opendistro-knn-1.12.0.0.zip    |No change  |
|opendistro-knn_1.12.0.0-1_amd64.deb    |opendistro-knn-1.13.0.0.deb    |
|opendistro-knn-1.12.0.0-1.noarch.rpm   |opendistro-knn-1.13.0.0.rpm    |
|opendistro-anomaly-detection-1.12.0.0.zip  |No change  |
|opendistro-anomaly-detection_1.12.0.0-1_amd64.deb  |opendistro-anomaly-detection-1.13.0.0.deb  |
|opendistro-anomaly-detection-1.12.0.0-1.noarch.rpm |opendistro-anomaly-detection-1.13.0.0.rpm  |
|opendistro-reports-scheduler-1.12.0.0.zip  |No change  |
|opendistro-reports-scheduler_1.12.0.0-1_amd64.deb  |opendistro-reports-scheduler-1.13.0.0.deb  |
|opendistro-reports-scheduler-1.12.0.0-1.noarch.rpm |opendistro-reports-scheduler-1.13.0.0.rpm  |
|opendistroQueryWorkbenchKibana-1.12.0.0.zip    |No change  |
|opendistroAnomalyDetectionKibana-1.12.0.0.zip  |No change  |
|opendistroSecurityKibana-1.12.0.0.zip  |No change  |
|opendistroAlertingKibana-1.12.0.2.zip  |No change  |
|opendistroIndexManagementKibana-1.12.0.0.zip   |No change  |
|opendistroReportsKibana-1.12.0.0.zip   |opendistroReportsKibana-1.13.0.0-linux-x64.zip / opendistroReportsKibana-1.13.0.0-linux-arm64.zip / opendistroReportsKibana-1.13.0.0-windows-x64.zip|
|opendistroGanttChartKibana-1.12.0.0.zip    |No change  |
|opendistroNotebooksKibana-1.12.0.0.zip |No change  |
|opendistro-knnlib-1.12.0.0-1_linux.x86_64.zip  |opendistro-knnlib-1.13.0.0-linux-x64.zip   |
|opendistro-knnlib-1.12.0.0-linux-aarch64.deb   |opendistro-knnlib-1.13.0.0-linux-arm64.deb |
|opendistro-knnlib-1.12.0.0-linux-x86_64.rpm    |opendistro-knnlib-1.13.0.0-linux-x64.rpm   |
|opendistro-sql-jdbc-1.12.0.0.jar   |No change |
|Open Distro for Elasticsearch SQL ODBC Driver 64-bit-1.12.0.0-Darwin.pkg   |opendistro-sql-odbc-1.13.0.0-macos-x64.pkg |
|Open Distro for Elasticsearch SQL ODBC Driver 64-bit-1.12.0.0-Windows.msi  |opendistro-sql-odbc-1.13.0.0-windows-x64.msi   |
|Open Distro for Elasticsearch SQL ODBC Driver 32-bit-1.12.0.0-Windows.msi  |opendistro-sql-odbc-1.13.0.0-windows-x86.msi   |
|perf-top-1.12.0.0-LINUX.zip    |opendistro-perf-top-1.13.0.0-linux-x64.zip |
|perf-top-1.12.0.0-MACOS.zip    |opendistro-perf-top-1.13.0.0-macos-x64.zip |




### Index Management
* Removes support of "index.opendistro.index_state_management.policy_id" setting ([#357](https://github.com/opendistro-for-elasticsearch/index-management/pull/357))


### SQL
* Refine PPL head command syntax ([#1022](https://github.com/opendistro-for-elasticsearch/sql/pull/1022))
* Disable access to the field keyword in the new SQL engine ([#1025](https://github.com/opendistro-for-elasticsearch/sql/pull/1025))


## FEATURES

### Anomaly Detection Kibana Plugin
* Add historical detectors ([#359](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/359))


### Index Management
* Adds a new ISM Action called RollupAction which allows user to automate one-time rollups on indices ([#371](https://github.com/opendistro-for-elasticsearch/index-management/pull/371))
* Adds support for ISM templates ([#383](https://github.com/opendistro-for-elasticsearch/index-management/pull/383))


### Kibana Reports
* Add Custom Common Time Ranges ([#239](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/239))
* Definition Details Modal & Delete Toast ([#258](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/258))
* Support creating report for saved objects with custom id ([#283](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/283))
* Add Search box to Report Source Selection ([#286](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/286))
* Support customized server config ([#313](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/313))


### k-NN
* Support k-NN similarity functions in painless scripting ([#281](https://github.com/opendistro-for-elasticsearch/k-NN/pull/281))
* Add support for L1 distance in AKNN, custom scoring and painless scripting ([#310](https://github.com/opendistro-for-elasticsearch/k-NN/pull/310))


### SQL
* Add keywords option as alias identifier in SQL parser ([#866](https://github.com/opendistro-for-elasticsearch/sql/pull/866))
* Support show and describe statement ([#907](https://github.com/opendistro-for-elasticsearch/sql/pull/907))
* Support cast function in SQL ([#926](https://github.com/opendistro-for-elasticsearch/sql/pull/926))
* Support NULLS FIRST/LAST ordering for window functions ([#929](https://github.com/opendistro-for-elasticsearch/sql/pull/929))
* Project operator pushdown ([#933](https://github.com/opendistro-for-elasticsearch/sql/pull/933))
* Add string function RIGHT ([#938](https://github.com/opendistro-for-elasticsearch/sql/pull/938))
* Add Flow control function IF(expr1, expr2, expr3) ([#990](https://github.com/opendistro-for-elasticsearch/sql/pull/990))
* Support Struct Data Query in SQL/PPL ([#1018](https://github.com/opendistro-for-elasticsearch/sql/pull/1018))


### Anomaly Detection
* Add AD task and tune detector&AD result data model ([#329](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/329))
* Add AD task cache ([#337](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/337))
* Start historical detector ([#355](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/355))
* Stop historical detector; support return AD task in get detector API ([#359](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/359))
* Update/delete historical detector;search AD tasks ([#362](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/362))
* Add user in AD task ([#370](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/370))



### Release Engineering
* Add ARM64 TAR building process for both ES and KIBANA ([#559](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/559), [#565](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/565), [#581](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/581), [#590](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/590))
* Add ARM64 support for deb/rpm (apt/yum) for ES and Kibana ([#562](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/562), [#575](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/575), [#584](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/584), [#596](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/596))


## ENHANCEMENTS

### Alerting Kibana Plugin
* Add toast notification to handle errors when updating a destination ([#232](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/232))


### Anomaly Detection Kibana Plugin
* Refactor AnomalyHistory Chart to improve performance for HC detector ([#350](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/350))
* Change default shingle size for HC detector to 4 ([#356](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/356))
* Add 'No data' state for historical detectors ([#364](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/364))
* Simplify historical detector failure states ([#368](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/368))


### Index Management
* Adds a snapshot deny list cluster setting to block ISM snapshot writes to configured repositories ([#366](https://github.com/opendistro-for-elasticsearch/index-management/pull/366))
* Adds support to Explain and Get Policy APIs for getting all policies/managed indices ([#352](https://github.com/opendistro-for-elasticsearch/index-management/pull/352))


### Index Management Kibana Plugin
* Get All and Explain All ([#149](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/149))


### Kibana Reports
* Headless chrome creation script and readme file ([#229](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/229))
* Remove logo for side bar menu ([#230](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/230))
* Using common-utils for Security plugin transient thread context key ([#234](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/234))
* Using Kotlin standard coding standard ([#235](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/235))
* Using chromium path relative to constant file ([#236](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/236))
* Add double dots to relative url in fetch() ([#242](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/242))
* Optimize selectors for DOM operation to reduce possible version compatibility issue ([#244](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/244))
* Add flag to chromium to use single process ([#268](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/268))
* Add semaphore to block on puppeteer chromium execution ([#284](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/284))
* Update timeRangeMatcher to avoid create report failure ([#292](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/292))


### Kibana Visualizations
* Use plotly-dist instead of ploty ([#5](https://github.com/opendistro-for-elasticsearch/kibana-visualizations/pull/5))


### k-NN
* Upgrade nmslib to 2.0.11 ([#302](https://github.com/opendistro-for-elasticsearch/k-NN/pull/302))
* Upgrade commons-beanutils ([#297](https://github.com/opendistro-for-elasticsearch/k-NN/pull/297))


### Security
* Using SAML subject_key and roles_key in the HTTPSamlAuthenticator ([#892](https://github.com/opendistro-for-elasticsearch/security/pull/892))
* Support for ES system index ([#946](https://github.com/opendistro-for-elasticsearch/security/pull/946))
* Updating Autheticators to throw RuntimeException on errors ([#505](https://github.com/opendistro-for-elasticsearch/security/pull/505))
* Add security configuration for Kibana Notebooks ([#903](https://github.com/opendistro-for-elasticsearch/security/pull/903))
* Short circuit privilege evaluation for bulk requests without index resolution ([#926](https://github.com/opendistro-for-elasticsearch/security/pull/926))
* Add async search response index to system index list ([#859](https://github.com/opendistro-for-elasticsearch/security/pull/859))


### SQL
* Enable new SQL query engine ([#989](https://github.com/opendistro-for-elasticsearch/sql/pull/989))
* Add metrics for SQL query requests in new engine ([#905](https://github.com/opendistro-for-elasticsearch/sql/pull/905))
* Enable failed test logging and fix flaky UT ([#910](https://github.com/opendistro-for-elasticsearch/sql/pull/910))
* Improve logging in new SQL engine ([#912](https://github.com/opendistro-for-elasticsearch/sql/pull/912))
* Enable date type input in function Count() ([#931](https://github.com/opendistro-for-elasticsearch/sql/pull/931))
* Use name and alias in JDBC format ([#932](https://github.com/opendistro-for-elasticsearch/sql/pull/932))
* Throw exception when access unknown field type ([#942](https://github.com/opendistro-for-elasticsearch/sql/pull/942))
* Fill hyphen strings to workbench table cells that have null and missing values ([#944](https://github.com/opendistro-for-elasticsearch/sql/pull/944))
* Support aggregate window functions ([#946](https://github.com/opendistro-for-elasticsearch/sql/pull/946))
* Support filter clause in aggregations ([#960](https://github.com/opendistro-for-elasticsearch/sql/pull/960))
* Enable sql function ifnull, nullif and isnull ([#962](https://github.com/opendistro-for-elasticsearch/sql/pull/962))
* Double quoted as string literal instead of identifier ([#974](https://github.com/opendistro-for-elasticsearch/sql/pull/974))
* [PPL] Support index name with date suffix ([#983](https://github.com/opendistro-for-elasticsearch/sql/pull/983))
* Support NULL literal as function argument ([#985](https://github.com/opendistro-for-elasticsearch/sql/pull/985))
* Allow Timestamp/Datetime values to use up to 6 digits of microsecond precision ([#988](https://github.com/opendistro-for-elasticsearch/sql/pull/988))
* Protect window operator by circuit breaker ([#1006](https://github.com/opendistro-for-elasticsearch/sql/pull/1006))
* Removed stack trace when catches anonymizing data error ([#1014](https://github.com/opendistro-for-elasticsearch/sql/pull/1014))
* Disable access to the field keyword in the new SQL engine ([#1025](https://github.com/opendistro-for-elasticsearch/sql/pull/1025))
* Only keep the first element of multivalue field response ([#1026](https://github.com/opendistro-for-elasticsearch/sql/pull/1026))
* Remove request id in response listener logging ([#1027](https://github.com/opendistro-for-elasticsearch/sql/pull/1027))


### Anomaly Detection
* Add unit tests for Transport Actions ([#327](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/327))
* Add role based filtering for rest of APIs ([#325](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/325))
* Add ad task stats ([#332](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/332))
* Add support for Security Test Framework ([#331](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/331))
* Filter out exceptions which should not be counted in failure stats ([#341](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/341))
* Move Preview Anomaly Detectors to Transport layer ([#321](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/321))
* Add role based filtering for Preview API ([#356](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/356))
* Change the backend role filtering to keep consistent with alerting plugin ([#383](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/383))


## BUG FIXES

### Alerting
* Move user instantiation to doExecute ([#343](https://github.com/opendistro-for-elasticsearch/alerting/pull/343))


### Alerting Kibana Plugin
* Filter out historical detectors on monitor creation page ([#229](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/229))
* Fix that Trigger page might freeze for high cardinality detectors ([#230](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/230))
* Change the query parameters 'size' and 'search' of 'getDestinations' request to be optional ([#231](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/231))


### Anomaly Detection Kibana Plugin
* Fix failure of adding feature to 1st detector in cluster ([#353](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/353))
* Fix live chart bar width ([#362](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/362))
* Remove stopped annotations for historical detector chart ([#371](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/371))
* Fix dashboard loading state and empty state logic ([#373](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/373))
* Fix typo in sample eCommerce description ([#374](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/374))


### Index Management
* Fixes bug for continuous rollups getting exceptions for Instant types ([#373](https://github.com/opendistro-for-elasticsearch/index-management/pull/373))
* Fixes handling various date formats for DateHistogram source field in continuous rollups ([#385](https://github.com/opendistro-for-elasticsearch/index-management/pull/385))
* Removes the metric requirement for ISM Rollup action ([#389](https://github.com/opendistro-for-elasticsearch/index-management/pull/389))
* Fixes transition step using incorrect step start time if state has no actions ([#381](https://github.com/opendistro-for-elasticsearch/index-management/pull/381))
* Fixes tests relying on exact seqNo match ([#397](https://github.com/opendistro-for-elasticsearch/index-management/pull/397))


### Index Management Kibana Plugin
* Bug fix: getRollups API, rollup jobs landing page ([#154](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/154))


### Kibana Notebooks
* Bump react-syntax-highlighter to fix regex dos vulnerability, fix cypress ([#74](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/74))
* Use Updated npm Trim ([#73](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/73))
* Use forked trim library to avoid regex DOS ([#72](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/72))
* Fix babel command on windows ([#70](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/70))
* Bump ini from 1.3.5 to 1.3.8 ([#65](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/65))


### Kibana Reports
* Fix chromium path for puppeteer ([#232](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/232))
* Disable GPU on chromium ([#237](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/237))
* Fix the time range display issue(timezone) on visual report ([#240](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/240))
* Bug Fixes in UI ([#241](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/241))
* defaultItemsQueryCount setting moved to general group ([#246](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/246))
* Fix UUID Generation ([#263](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/263))
* Configure Max Size for Dashboards API \& Minor UI Changes ([#266](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/266))
* Support csv report for saved search with multiple indices ([#267](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/267))
* Add error case handling for on-demand report generation ([#271](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/271))
* Fix Edit Report Definition Trigger Type Pre-fill ([#280](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/280))
* Fix the selected fields issue in csv report ([#293](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/293))
* Fix reporting download button visibility issue for dashboard and visualization ([#294](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/294))
* Context menu popout \& Report definitions toast fixes ([#295](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/295))
* Keep Reporting menu in Nav Menu when switching Index Patterns ([#299](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/299))
* Add global tenant for report definition urls ([#325](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/325))


### k-NN
* Fix find_path bug in CMakeLists ([#280](https://github.com/opendistro-for-elasticsearch/k-NN/pull/280))
* Add builder constructor that takes algo params ([#289](https://github.com/opendistro-for-elasticsearch/k-NN/pull/289))


### Security
* Replace InjectedUser with User during serialization ([#891](https://github.com/opendistro-for-elasticsearch/security/pull/891))
* ConfigUpdateRequest should include only updated CType ([#953](https://github.com/opendistro-for-elasticsearch/security/pull/953))
* Fix AuthCredentials equality ([#876](https://github.com/opendistro-for-elasticsearch/security/pull/876))
* Revert "Using SAML subject_key and roles_key in the HTTPSamlAuthenticator ([#1019](https://github.com/opendistro-for-elasticsearch/security/pull/1019))


### SQL
* Fix round fix issue when input is negative and end with .5 ([#914](https://github.com/opendistro-for-elasticsearch/sql/pull/914))
* Add fix to handle functions applied to literal ([#913](https://github.com/opendistro-for-elasticsearch/sql/pull/913))
* Fetch error message in root cause for new default formatter ([#1001](https://github.com/opendistro-for-elasticsearch/sql/pull/1001))
* Fixed interval type null/missing check failure ([#1011](https://github.com/opendistro-for-elasticsearch/sql/pull/1011))
* Fix workbench issue that csv result not written to downloaded file ([#1024](https://github.com/opendistro-for-elasticsearch/sql/pull/1024))


### Anomaly Detection
* Fix the profile API returns prematurely. ([#340](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/340))
* Fix another case of the profile API returns prematurely ([#353](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/353))
* Fix log messages and init progress for the profile API ([#374](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/374))
* Validate detector only when start detector; fix flaky test case ([#377](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/377))


### Release Engineering
* [Helm] Include Ingress annotations for HTTPS backend, thanks @Purneau ([#570](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/570))

## INFRASTRUCTURE

### Alerting
* Rename plugin for more consistent naming convention ([#339](https://github.com/opendistro-for-elasticsearch/alerting/pull/339))
* Change release workflow to use new staging bucket for artifacts ([#334](https://github.com/opendistro-for-elasticsearch/alerting/pull/339))


### Anomaly Detection Kibana Plugin
* Updating start-server-and-test version ([#355](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/355))
* Bump ini from 1.3.5 to 1.3.8 ([#345](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/345))
* Fix broken unit and integration tests ([#360](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/360))
* Add sleep time before running Cypress tests ([#363](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/363))
* Change CD workflow to use new staging bucket for artifacts ([#311](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/311))


### Index Management
* Adds support for https remote integration tests ([#379](https://github.com/opendistro-for-elasticsearch/index-management/pull/379))
* Renames plugin name to standardized name ([#390](https://github.com/opendistro-for-elasticsearch/index-management/pull/390))
* Fixes deb arch and renames deb/rpm artifacts to standardized names ([#391](https://github.com/opendistro-for-elasticsearch/index-management/pull/391))
* Fixes numNodes gradle property ([#393](https://github.com/opendistro-for-elasticsearch/index-management/pull/393))
* Changes release workflow to use new staging bucket for artifacts ([#378](https://github.com/opendistro-for-elasticsearch/index-management/pull/378))


### Index Management Kibana Plugin
* Add E2E cypress tests for rollup ([#152](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/152))
* Change release workflow to use new staging bucket for artifacts ([#151](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/151))


### Job Scheduler
* Update release-workflow.yml ([#83](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/83))
* Rename plugin artifacts for more consistent naming convention ([#85](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/85))


### Kibana Notebooks
* Change release workflow to use new staging bucket for artifacts ([#71](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/71))


### Kibana Reports
* Update workflow to build artifact for ARM64 ([#228](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/228))
* Fix release workflow artifact paths and s3 url ([#231](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/231))
* Update path and artifact names in release workflow ([#233](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/233))
* Add Download Cypress Tests ([#253](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/253))
* Add integration test for the sample on-demand report generation use-case ([#270](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/270))
* Add integration test cases for report definition rest APIs ([#272](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/272))
* Report Instance Integration Tests ([#274](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/274))
* List Multiple Report Definitions IT ([#276](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/276))
* Add frontend metrics for Kibana reports ([#277](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/277))
* Reporting backend metrics ([#282](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/282))
* Add overall frontend metrics for actions ([#287](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/287))
* Reporting backend metrics ([#288](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/288))
* Dump coverage for each IT ([#296](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/296))
* Change release workflows to use new staging bucket for artifacts ([#301](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/301))
* Re-add metric API ([#303](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/303))
* Fix Reporting CVEs ([#304](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/304))
* Rename kibana reports release artifacts in github workflow ([#305](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/305))
* Add reporting backend to Codecov ([#306](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/306))
* Rename deb and rpm packages for reports scheduler ([#307](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/307))


### Kibana Visualizations
* Fix github workflows ([#4](https://github.com/opendistro-for-elasticsearch/kibana-visualizations/pull/4))
* Add jaegar sample data for cypress ([#7](https://github.com/opendistro-for-elasticsearch/kibana-visualizations/pull/7))
* Change release workflow to use new staging bucket for artifacts ([#11](https://github.com/opendistro-for-elasticsearch/kibana-visualizations/pull/11))
* Fix cypress tests ([#12](https://github.com/opendistro-for-elasticsearch/kibana-visualizations/pull/12))


### k-NN
* Add arm64 support and correct the naming convention to the new standards ([#299](https://github.com/opendistro-for-elasticsearch/k-NN/pull/299))
* Run KNN integ tests with security plugin enabled ([#304](https://github.com/opendistro-for-elasticsearch/k-NN/pull/304))
* Update artifact naming ([#309](https://github.com/opendistro-for-elasticsearch/k-NN/pull/309))
* Change CD workflow to use new staging bucket for artifacts ([#301](https://github.com/opendistro-for-elasticsearch/k-NN/pull/301))


### Performance Analyzer
* Improve Test coverage ([#251](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/251))
* Improve Test coverage up to 48% ([#255](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/255))
* Changes for the Performance Analyzer IT to run with newer versions of ES ([#256](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/256))
* Improve test coverage up to 62% ([#257](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/257))
* Improve Test Coverage to 81% ([#258](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/258))
* Add integ tests for OS metrics(cpu, page fault) ([#252](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/252))


### SQL
* Bump ini from 1.3.5 to 1.3.7 in /workbench ([#911](https://github.com/opendistro-for-elasticsearch/sql/pull/911))
* Backport workbench fixes to 7.9.1 ([#937](https://github.com/opendistro-for-elasticsearch/sql/pull/937))
* Backport workbench fixes to 7.9 on old platform ([#940](https://github.com/opendistro-for-elasticsearch/sql/pull/940))
* Backporting latest change from develop to opendistro-1.11 ([#945](https://github.com/opendistro-for-elasticsearch/sql/pull/945))
* Bump jackson-databind version to 2.10.5.1 ([#984](https://github.com/opendistro-for-elasticsearch/sql/pull/984))
* Rename sql release artifacts ([#1007](https://github.com/opendistro-for-elasticsearch/sql/pull/1007))
* Rename odbc release artifacts ([#1010](https://github.com/opendistro-for-elasticsearch/sql/pull/1010))
* Rename sql-cli wheel to use dashes instead of underscore ([#1015](https://github.com/opendistro-for-elasticsearch/sql/pull/1015))


### Anomaly Detection
* Add IT cases for filtering out non-server exceptions for HC detector ([#348](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/348))
* Rename rpm/deb artifact name ([#371](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/371))
* Fix flaky test case ([#376](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/376))
* Change release workflow to use new staging bucket for artifacts ([#358](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/358))
* Update draft release notes config ([#379](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/379))
* Fix failed integration cases ([#385](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/385))


## DOCUMENTATION

### Alerting
* Add RFC for Document-Level Alerting ([#327](https://github.com/opendistro-for-elasticsearch/alerting/pull/327))


### Alerting Kibana Plugin
* Correct the file name of the release notes for 1.12.0.2 ([#228](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/228))


### Anomaly Detection Kibana Plugin
* Add tiny icon fix to release note ([#346](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/346))
* Update draft release notes config to use URL ([#358](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/358))
* Remove copyright year for newly added files ([#367](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/367))
* Add release notes for version 1.13.0.0 ([#375](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/375))
* Fix link to LICENSE.txt ([#376](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/376))


### Index Management
* Adds RFC for Transforms ([#359](https://github.com/opendistro-for-elasticsearch/index-management/pull/359))


### Index Management Kibana Plugin
* Compatible with Kibana 7.10.2, ODFE 1.13.0 ([#155](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/155))


### Kibana Reports
* Add docs link ([#247](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/247))
* Add codecov for kibana reports \\& Add README badges ([#248](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/248))
* Fix README badge ([#257](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/257))


### k-NN
* Add copyright header ([#307](https://github.com/opendistro-for-elasticsearch/k-NN/pull/307))


### SQL
* Keep development doc sync with latest code ([#961](https://github.com/opendistro-for-elasticsearch/sql/pull/961))
* Update ODBC documentation ([#1012](https://github.com/opendistro-for-elasticsearch/sql/pull/1012))


### Anomaly Detection
* Updating Readme to include Secure tests ([#334](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/334))
* Remove spotless header file; remove copyright year in new files for h… ([#372](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/372))
* Add release notes for version 1.13.0.0 ([#382](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/382))


## MAINTENANCE

### Alerting
* Adds support for Elasticsearch 7.10.2 ([#340](https://github.com/opendistro-for-elasticsearch/alerting/pull/340))
* Update cron-utils to version 9.1.3 ([#344](https://github.com/opendistro-for-elasticsearch/alerting/pull/344))


### Alerting Kibana Plugin
* Add Cypress E2E tests and GitHub Action Cypress workflow ([#161](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/161))
* Fix the unit tests in v1.12.0.2 ([#227](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/227))
* Add support to run Cypress test in an ODFE cluster with security enabled ([#235](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/235))
* Upgrade Formik to v2.x to reduce vulnerability ([#236](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/236))
* Add support for Kibana 7.10.2 ([#239](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/239))


### Anomaly Detection Kibana Plugin
* Upgrade to Kibana 7.10.2 ([#369](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/369))


### Asynchronous Search
* Renamed settings for consistency with other ODFE plugins ([#35](https://github.com/opendistro-for-elasticsearch/asynchronous-search/pull/35))


### Index Management
* Adds support for Elasticsearch 7.10.2 ([#398](https://github.com/opendistro-for-elasticsearch/index-management/pull/398))
* Fixes reported CVEs ([#395](https://github.com/opendistro-for-elasticsearch/index-management/pull/395))


### Job Scheduler
* Support Elasticsearch 7.10.2 ([#86](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/86))


### Kibana Notebooks
* Update notebooks to 7.10.2 ([#75](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/75))
* Add ODFE 1.13 release notes for notebooks ([#76](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/76))


### Kibana Reports
* Backport from branch opendistro-1.12.0.0 to 7.9.1 ([#245](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/245))
* Hide/remove report definition related UI ([#260](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/260))
* Reports Table Backport Changes ([#261](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/261))
* Backport commits from dev ([#269](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/269))
* Backport from dev branch ([#289](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/289))
* Change Reports Table Display ([#291](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/291))
* Backport bug fixes from dev ([#297](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/297))
* Backport Context Menu fix to 7.9.1 ([#300](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/300))
* Remove reporting plugin page from kibana nav ([#302](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/302))


### Kibana Visualizations
* Bump ini from 1.3.5 to 1.3.8 in /gantt-chart ([#6](https://github.com/opendistro-for-elasticsearch/kibana-visualizations/pull/6))


### k-NN
* Upgrade odfe version to 1.13.0 ([#312](https://github.com/opendistro-for-elasticsearch/k-NN/pull/312))


### PerfTop
* Update the Perftop Package with new naming Convention for ODFE ([#68](https://github.com/opendistro-for-elasticsearch/perftop/pull/68))


### Security
* Pull request intake form (PR template) ([#884](https://github.com/opendistro-for-elasticsearch/security/pull/884))
* Fix typos in template ([#898](https://github.com/opendistro-for-elasticsearch/security/pull/898))
* Upgrade Bouncy Castle to 1.67 ([#910](https://github.com/opendistro-for-elasticsearch/security/pull/910))
* Optimize creating new collection objects in IndexResolverReplacer ([#911](https://github.com/opendistro-for-elasticsearch/security/pull/911))
* Optimize by avoid creating wildcard matchers for every request ([#902](https://github.com/opendistro-for-elasticsearch/security/pull/902))
* Replace writeByte with writeShort in TLSUtilTests ([#927](https://github.com/opendistro-for-elasticsearch/security/pull/927))
* Integrate Github CodeQL Analysis into CI ([#905](https://github.com/opendistro-for-elasticsearch/security/pull/905))
* Rename security plugin artifacts from opendistro_security to opendistro-security ([#966](https://github.com/opendistro-for-elasticsearch/security/pull/966))
* Remove veracode profile and associated config ([#992](https://github.com/opendistro-for-elasticsearch/security/pull/992))
* Try using another port 8088 for running the webhook test ([#999](https://github.com/opendistro-for-elasticsearch/security/pull/999))
* Cleanup single shard request index check ([#993](https://github.com/opendistro-for-elasticsearch/security/pull/993))
* Add AD search task permission to ad read access ([#997](https://github.com/opendistro-for-elasticsearch/security/pull/997))
* Change CD workflow to use new staging bucket for artifacts ([#954](https://github.com/opendistro-for-elasticsearch/security/pull/954))
* Refactor Resolved ([#929](https://github.com/opendistro-for-elasticsearch/security/pull/929))
* Combine log messages of no cluster-level permission ([#1002](https://github.com/opendistro-for-elasticsearch/security/pull/1002))
* Support ES 7.10.2 ([#1005](https://github.com/opendistro-for-elasticsearch/security/pull/1005))
* Bump version to 1.13 ([#1004](https://github.com/opendistro-for-elasticsearch/security/pull/1004))
* Cleanup reflection helper and advanced modules enabled / dls fls enabled properties ([#1001](https://github.com/opendistro-for-elasticsearch/security/pull/1001))
* Sample configuration for password strength rules ([#1020](https://github.com/opendistro-for-elasticsearch/security/pull/1020))
* Updating Github actions and files to use main branch. ([#1023](https://github.com/opendistro-for-elasticsearch/security/pull/1023))
* Add the Linux Foundation's Developer Certificate of Origin in pull request template ([#1022](https://github.com/opendistro-for-elasticsearch/security/pull/1022))
* Change the build configuration for deb package and rename the folder of artifacts. ([#1027](https://github.com/opendistro-for-elasticsearch/security/pull/1027))
* Update release notes 1.13 ([#1028](https://github.com/opendistro-for-elasticsearch/security/pull/1028))
* Fix release version ([#1029](https://github.com/opendistro-for-elasticsearch/security/pull/1029))
* Revert back the renaming of jar file and update release notes 1.13 ([#1031](https://github.com/opendistro-for-elasticsearch/security/pull/1031))
* Fixed async search action names and system index ([#1033](https://github.com/opendistro-for-elasticsearch/security/pull/1033))
* Update release notes 1.13 ([#1036](https://github.com/opendistro-for-elasticsearch/security/pull/1036))


### SQL
* Fix workbench issue in backported 1.11 branch: error message cannot display ([#943](https://github.com/opendistro-for-elasticsearch/sql/pull/943))
* Fix URI Encoding in 1.12 ([#955](https://github.com/opendistro-for-elasticsearch/sql/pull/955))


### Anomaly Detection
* Upgrade to ES 7.10.2 ([#378](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/378))


## REFACTORING

### Alerting Kibana Plugin
* Replace all 'render' props to 'children' props in Formik elements ([#238](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/238))


### Index Management Kibana Plugin
* Modify getRollups API to use getRollup instead of search API   ([#150](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/150))


