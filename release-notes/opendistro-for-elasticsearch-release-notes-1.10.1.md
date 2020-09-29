# Open Distro for Elasticsearch 1.10.1 Release Notes

Open Distro for Elasticsearch 1.10.1 is now available for [download](https://opendistro.github.io/for-elasticsearch/downloads.html).

The release consists of Apache 2 licensed Elasticsearch version 7.9.1, and Kibana version 7.9.1. Plugins in the distribution include Alerting, Index Management, Performance Analyzer (with Root Cause Analysis Engine), Security, SQL, Machine Learning with k-NN, and Anomaly Detection. Also, SQL JDBC/ODBC driver, SQL CLI Client, and PerfTop (a client for Performance Analyzer) are available for download now.


## Release Highlights

* Re-design and re-implmement Security Kibana Plugin based on the new Kibana API, which enables streamlined workflows, improved usability, and audit logging.
* Introducing Sample Detectors in Anomaly Detection Kibana Plugin:
  * Users can now load 3 different sample detectors (and corresponding indices) into their cluster to get familiar with detectors and detector configurations
  * Users can detect sample anomalies using logs related to (1) HTTP response codes, (2) eCommerce orders, and (3) CPU and memory of a host
* Introducing Email Destination support in Alerting/Alerting Kibana Plugin:
  * Provide a pre-built destination type for email in Alerting to easily send notifications without using a webhook
  * Support SMTP SSL/TLS and authentication
  * Store `email_accounts` in `opendistro-alerting-config` index like other Alerting configurations. This allows configuration of multiple sender emails for use in Destinations
  * A single configured `email_account` can be used in multiple Destinations and is referred to by its `id` in Destination configuration. Therefore, changing the `email_account` would reflect the changes in all Destinations that reference it.


## Release Details

The release of Open Distro for Elasticsearch includes the following features, enhancements, bug fixes, infrastructure, documentation, maintenance, and refactoring updates. 


## BREAKING CHANGES

### Security Kibana Plugin

* Renamed `backend_role` to `External entity` on UI and move the role mapping function to role page. Now you can map roles to backend_role or users on role edit page.
* Combined `security_authentication` and `security_preferences` cookie into one, because Kibana new plugin platform only support one session cookie.



## FEATURES

### Alerting

* Adds support for Email Destination ([#244](https://github.com/opendistro-for-elasticsearch/alerting/pull/244))

### Alerting Kibana Plugin

* Adds support for Email Destination for Kibana ([#176](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/176))

### Anomaly Detection

* AD CLI ([#196](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/196))
* Get detector ([#207](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/207))

### Anomaly Detection Kibana Plugin

* Add sample detectors and indices ([#272](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/272))
* Adds window size as advanced setting in model configuration. ([#287](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/287))

### Index Management

* Implemented allocation action which can be used in index state management ([#106](https://github.com/opendistro-for-elasticsearch/index-management/pull/106))
* Adds `_refresh_search_analyzers` API to allow updating synonym list for dynamically updatable synonym analyzers ([#290](https://github.com/opendistro-for-elasticsearch/index-management/pull/290))

### Knn

* Add Warmup API to load indices graphs into memory ([#162](https://github.com/opendistro-for-elasticsearch/k-NN/pull/162))

### Performance Analyzer

* cache max size metric collector ([#145](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/145))
* Add initial support for dynamic config overriding ([#148](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/148))
* Node collector split ([#162](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/162))
* Add required mutual auth to gRPC Server/Client ([#254](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/254))
* Add NodeConfigCollector to collect node configs(threadpool capacity etc.) from ES ([#252](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/252))
* cache max size metrics ([#297](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/297))
* Implement cool off handling for the Publisher ([#272](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/272))
* FieldData and Shard Request Cache RCA ([#265](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/265))
* Add a cluster level collector for node config settings ([#298](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/298))
* Add cache decider and modify cache action ([#303](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/303))
* Implement Action Flip Flop Detection in the Publisher ([#287](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/287))
* Add listeners for publisher actions ([#295](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/295))
* Reader changes for dynamic enable/disable of RCA graph components ([#325](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/325))
* Populate default workload type and cache priority for the decider to base default actions ([#340](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/340))
* Polarize actions based on impact vectors ([#332](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/332))
* Add support for action configs ([#402](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/402))
* JVM decider ([#326](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/326))

### Perftop

* Add github badges ([#47](https://github.com/opendistro-for-elasticsearch/perftop/pull/47))

### Security Kibana Plugin

* Introduction and Tutorial page to help users get up and running quickly.
* Added audit logging configuration function into Kibana security plugin
* Created account drop down menu to replace the logout button. Moved `account info` and `switching tenant` function to the account drop down menu.

### SQL 

* support Elasticsearch geo_point and ip data type ([#719](https://github.com/opendistro-for-elasticsearch/sql/pull/719))
* add serialization support for expression ([#712](https://github.com/opendistro-for-elasticsearch/sql/pull/712))
* Optimize filter expression script ([#707](https://github.com/opendistro-for-elasticsearch/sql/pull/707))
* Support WHERE clause in new SQL parser ([#682](https://github.com/opendistro-for-elasticsearch/sql/pull/682))
* Add Cypress testing for SQL Workbench ([#562](https://github.com/opendistro-for-elasticsearch/sql/pull/562))
* Lucene query pushdown optimization ([#671](https://github.com/opendistro-for-elasticsearch/sql/pull/671))
* ODBC: Add PBIDS support ([#676](https://github.com/opendistro-for-elasticsearch/sql/pull/676))
* Add query size limit ([#679](https://github.com/opendistro-for-elasticsearch/sql/pull/679))
* Expression pushdown optimization ([#663](https://github.com/opendistro-for-elasticsearch/sql/pull/663))
* changes required for using to Power BI Service with Open Distro For Elasticsearch ([#669](https://github.com/opendistro-for-elasticsearch/sql/pull/669))
* Support NULL and MISSING value in response ([#667](https://github.com/opendistro-for-elasticsearch/sql/pull/667))
* ODBC: Use literals instead of parameters in Power BI data connector ([#652](https://github.com/opendistro-for-elasticsearch/sql/pull/652))
* Support select fields and alias in new query engine ([#636](https://github.com/opendistro-for-elasticsearch/sql/pull/636))
* Add comparison operator for SQL ([#635](https://github.com/opendistro-for-elasticsearch/sql/pull/635))



## ENHANCEMENTS

### Alerting

* Add action to 'DELETE /_alerting/destinations/{id}' ([#233](https://github.com/opendistro-for-elasticsearch/alerting/pull/233))
* Add action to '/_alerting/monitor/{id}', '/_alerting/monitor/_search' ([#234](https://github.com/opendistro-for-elasticsearch/alerting/pull/234))
* Add action to 'CREATE /_alerting/destinations/' ([#235](https://github.com/opendistro-for-elasticsearch/alerting/pull/235))
* Add action to /_acknowledge/alerts api ([#236](https://github.com/opendistro-for-elasticsearch/alerting/pull/236))
* Add actions to create, execute, get monitors api ([#240](https://github.com/opendistro-for-elasticsearch/alerting/pull/240))
* Fix- IllegalStateException warn messages, Location header in destination response, Handle null in GetMonitorRequest ([#252](https://github.com/opendistro-for-elasticsearch/alerting/pull/252))

### Anomaly Detection

* change to exhausive search for training data ([#184](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/184))
* Adds initialization progress to profile API ([#164](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/164))
* Queries data from the index when insufficient data in buffer to form a full shingle ([#176](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/176))
* Adding multinode integration test support ([#201](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/201))
* Change Profile List Format ([#206](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/206))
* Improve ux ([#209](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/209))
* Allows window size to be set per detector. ([#203](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/203))
* not return estimated minutes remaining until cold start is finished ([#210](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/210))
* minor edits to the short and long text strings ([#211](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/211))
* Change to use callbacks in cold start ([#208](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/208))
* fix job index mapping ([#212](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/212))

### Anomaly Detection Kibana Plugin

* Add missing feature alert if recent feature data is missing ([#248](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/248))
* Add progress bar for initialization ([#253](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/253))
* Improve error handling when retrieving all detectors ([#267](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/267))
* support field search for detector simple filter ([#278](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/278))
* Handle index not found error ([#273](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/273))
* Add action item and message for init failue case due to invalid search query.  ([#285](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/285))

### Index Management

* Changes implementation of ChangePolicy REST API to use MultiGet inste… ([#253](https://github.com/opendistro-for-elasticsearch/index-management/pull/253))

### Knn

* Upgrade nmslib to v2.0.6 ([#160](https://github.com/opendistro-for-elasticsearch/k-NN/pull/160))

### Performance Analyzer

* IT improvements ([#143](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/143))
* Add an IT which verifies that the RCA REST endpoint can be queried ([#157](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/157))
* Use absolute path for configFilePath ([#389](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/389))

### Release Engineering

* Implement Version Cuts for consistent distribution release builds ([#357](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/357))
* HELM allows customizing docker registry, thanks @tareqhs ([#358](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/358))

### Security

* Remove cluster monitor check from audit transport check ([#653](https://github.com/opendistro-for-elasticsearch/security/pull/653))
* Enable or disable check for all audit REST and transport categories ([#645](https://github.com/opendistro-for-elasticsearch/security/pull/645))
* Add ability for plugins to inject roles ([#560](https://github.com/opendistro-for-elasticsearch/security/pull/560))

### SQL

* Parse backtick strings (\`\`) as identifiers instead of string literals ([#678](https://github.com/opendistro-for-elasticsearch/sql/pull/678))
* add error details for all server communication errors ([#645](https://github.com/opendistro-for-elasticsearch/sql/pull/645))



## BUG FIXES

### Anomaly Detection Kibana Plugin

* upgrade elastic chart; fix zoom in bug ([#260](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/260))
* fix wrong field name when preview ([#277](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/277))
* parse types in fielddata ([#284](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/284))
* Add intermediate callout message during cold start ([#283](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/283))
* Make elastic/charts imports more generic ([#297](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/297))
* Fix initialization callouts to properly show when first loading anomaly results page ([#300](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/300))
* Fix bug where undefined is shown on UI for estimatedMins in case of ingestion data missing ([#301](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/301))
* Fix 2 issues on Dashboard ([#305](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/305))

### Index Management

* Fixes snapshot issues, adds history mapping update workflow, adds tests ([#255](https://github.com/opendistro-for-elasticsearch/index-management/pull/255))
* Fixes force merge failing on long executions, changes some action mes… ([#267](https://github.com/opendistro-for-elasticsearch/index-management/pull/267))

### Index Management Kibana Plugin

* Fixes missing actions on table, unused query parameter ?, and some ae… ([#103](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/103))
* add brace dep for binary kibana not starting problem ([#96](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/96))

### Knn

* Update guava version to 29.0 ([#182](https://github.com/opendistro-for-elasticsearch/k-NN/pull/182))
* Add default index settings when parsing index ([#205](https://github.com/opendistro-for-elasticsearch/k-NN/pull/205))
* NPE in force merge when non knn doc gets updated to knn doc across segments ([#212](https://github.com/opendistro-for-elasticsearch/k-NN/pull/212))
* Fix casting issue with cache expiration ([#215](https://github.com/opendistro-for-elasticsearch/k-NN/pull/215))

### Performance Analyzer

* Use the correct ctor for NodeDetailsCollector ([#166](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/166))
* Fix invalid cluster state ([#177](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/177))
* Fix performance-analyzer-agent configFilePath ([#268](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/268))
* Rest mutual auth fix ([#279](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/279))
* Persistance concurrency bug ([#323](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/323))
* Fix rca.conf structure error ([#338](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/338))
* Fixing the summary serialization issue for cache RCAs ([#348](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/348))
* Fix bug in NodeConfigFlowUnit to add resource summary into protobuf ([#349](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/349))
* Fix bug in publisher to support cool off period on a per node basis ([#351](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/351))

### Perftop

* Bump acorn from 6.0.6 to 6.4.1 ([#39](https://github.com/opendistro-for-elasticsearch/perftop/pull/39))
* Fix vulnerabilities ([#54](https://github.com/opendistro-for-elasticsearch/perftop/pull/54))

### Release Engineering

* KNNLib will now use wildcard to resolve hardcoded version issues ([#359](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/359))
* Docker allows elasticsearch user to access logs under supervisord folder ([#271](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/271), [#146](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/146), [#320](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/320))
* Disable optimizations for KNNLib compilation in docker image creation ([#384](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/384))
* HELM Kibana ingress path fix, thanks @Hokwang ([#340](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/340))
*  Helm master nodes allows extraVolumeMounts when securityconfig disabled, thanks @aplhk ([#366](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/366))

### Security

* Remove exception details from responses ([#667](https://github.com/opendistro-for-elasticsearch/security/pull/667))
* Adding onelogin loadXML util helper to prevent XXE attacks ([#659](https://github.com/opendistro-for-elasticsearch/security/pull/659))
* Add non-null to store even non-default values in serialization ([#652](https://github.com/opendistro-for-elasticsearch/security/pull/652))
* Refactor opendistro_security_action_trace logger ([#609](https://github.com/opendistro-for-elasticsearch/security/pull/609))
* Fail on invalid rest and transport categories ([#638](https://github.com/opendistro-for-elasticsearch/security/pull/638))
* Correct a typo in the Readme file. ([#607](https://github.com/opendistro-for-elasticsearch/security/pull/607))
* Fix AccessControlException during HTTPSamlAuthenticator initialization. ([#626](https://github.com/opendistro-for-elasticsearch/security/pull/626))
* Remove unnecessary check of remote address for null ([#616](https://github.com/opendistro-for-elasticsearch/security/pull/616))
* Prevent hidden roles from being added via rolesmapping and internalusers API ([#614](https://github.com/opendistro-for-elasticsearch/security/pull/614))

### SQL

* Fixed sql workbench loading issue ([#723](https://github.com/opendistro-for-elasticsearch/sql/pull/723))
* ODBC: Fix Windows 64-bit workflows ([#703](https://github.com/opendistro-for-elasticsearch/sql/pull/703))
* Fix for query folding issue while applying filter in PBID ([#666](https://github.com/opendistro-for-elasticsearch/sql/pull/666))
* Fix for query folding issue with direct query mode in Power BI data connector ([#640](https://github.com/opendistro-for-elasticsearch/sql/pull/640))



## INFRASTRUCTURE

### Alerting

* Support integration testing against remote security enabled clustering ([#213](https://github.com/opendistro-for-elasticsearch/alerting/pull/213))
* Add coverage upload in build workflow and add badges in README ([#223](https://github.com/opendistro-for-elasticsearch/alerting/pull/223))
* Add Codecov configuration to set a coverage threshold to pass the check on a commit ([#231](https://github.com/opendistro-for-elasticsearch/alerting/pull/231))

### Anomaly Detection

* Use goimports instead of gofmt ([#214](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/214))
* Install go get outside cli directory ([#216](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/216))

### Anomaly Detection Kibana Plugin

* Fix e2e test caused by new EuiComboBox added on CreateDetector page ([#252](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/252))
* Update lodash dependency ([#259](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/259))
* Add support for running CI with security ([#263](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/263))
* Upgrade Cypress and elliptic dependencies ([#266](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/266))
* Remove elastic charts dependency ([#269](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/269))
* Add UT for Detector List page ([#279](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/279))
* Fix UT and remove lower EUI version dependency ([#293](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/293))
* Fix broken cypress test related to new empty dashboard buttons ([#298](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/298))

### Index Management

* Adds codecov yml file to reduce flakiness in coverage check ([#251](https://github.com/opendistro-for-elasticsearch/index-management/pull/251))
* Adds support for multi-node run/testing and updates tests ([#254](https://github.com/opendistro-for-elasticsearch/index-management/pull/254))
* Adds multi node test workflow ([#256](https://github.com/opendistro-for-elasticsearch/index-management/pull/256))
* release notes automation ([#258](https://github.com/opendistro-for-elasticsearch/index-management/pull/258))
* Fixes download and doc links in gradle package ([#287](https://github.com/opendistro-for-elasticsearch/index-management/pull/287))

### Index Management Kibana Plugin

* Adds cypress e2e tests and github action cypress workflow ([#80](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/80))

### Job Scheduler

* Fix download and doc links in package description ([#70](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/70))

### Knn

* Reset state for uTs so tests run independently ([#159](https://github.com/opendistro-for-elasticsearch/k-NN/pull/159))
* Pass -march=x86-64 to build JNI library ([#164](https://github.com/opendistro-for-elasticsearch/k-NN/pull/164))
* Fix versioning for lib artifacts ([#166](https://github.com/opendistro-for-elasticsearch/k-NN/pull/166))
* Add release notes automation ([#168](https://github.com/opendistro-for-elasticsearch/k-NN/pull/168))
* Add Github action to build library artifacts ([#170](https://github.com/opendistro-for-elasticsearch/k-NN/pull/170))
* Flaky rest test case fix ([#183](https://github.com/opendistro-for-elasticsearch/k-NN/pull/183))
* Add code coverage widget and badges ([#191](https://github.com/opendistro-for-elasticsearch/k-NN/pull/191))
* Add Codecov configuration to set a coverage threshold to pass the check on a commit ([#192](https://github.com/opendistro-for-elasticsearch/k-NN/pull/192))
* Add AWS CLI in order to ship library artifacts from container ([#194](https://github.com/opendistro-for-elasticsearch/k-NN/pull/194))
* Remove sudo from "./aws install" in library build action ([#202](https://github.com/opendistro-for-elasticsearch/k-NN/pull/202))
* Fix download link in package description ([#214](https://github.com/opendistro-for-elasticsearch/k-NN/pull/214))

### Performance Analyzer

* Integration test framework to test RCAs and decision Makers ([#301](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/301)

### Security Kibana Plugin

* Plugin built using Kibana new plugin platform.

### SQL

* Changed rpm and deb artifact name ([#705](https://github.com/opendistro-for-elasticsearch/sql/pull/705))
* Adjust release drafter to follow ODFE standards ([#700](https://github.com/opendistro-for-elasticsearch/sql/pull/700))
* ODBC: improve Windows build process ([#661](https://github.com/opendistro-for-elasticsearch/sql/pull/661))
* Skip doctest in github release actions ([#648](https://github.com/opendistro-for-elasticsearch/sql/pull/648))
* Support security plugin ([#760](https://github.com/opendistro-for-elasticsearch/sql/pull/760))
* Bump to ODFE 1.10.1.1 for integration test fixes ([#759](https://github.com/opendistro-for-elasticsearch/sql/pull/759))
* Bug Fix, Clean all the indices, included hidden indices ([#758](https://github.com/opendistro-for-elasticsearch/sql/pull/758))


## DOCUMENTATION

### Alerting

* Adds workflow to generate draft release notes and reformat old release notes ([#241](https://github.com/opendistro-for-elasticsearch/alerting/pull/241))

### Anomaly Detection

* Automate release notes to unified standard ([#191](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/191))
* Add badges to AD ([#199](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/199))
* Test code coverage ([#202](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/202))
* Include release notes for 1.10.0.0 ([#219](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/219))
* Update README.md ([#222](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/222))

### Anomaly Detection Kibana Plugin

* Automate release notes to unified standard ([#255](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/255))
* Add a few badges ([#262](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/262))
* Updating the release notes to have 4th digit ([#291](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/291))
* Update 1.10.0.0 release notes ([#296](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/296))
* Add release note for PR 301 ([#302](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/302))

### Index Management

* Adds rollup-rfc to docs ([#248](https://github.com/opendistro-for-elasticsearch/index-management/pull/248))

### Job Scheduler

* Add workflow to generate draft release notes and reformat old release notes ([#68](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/68))

### Knn

* Performance tuning/Recommendations ([#177](https://github.com/opendistro-for-elasticsearch/k-NN/pull/177))
* Fix cluster setting example in README.md ([#186](https://github.com/opendistro-for-elasticsearch/k-NN/pull/186))
* Add scoring documentation ([#193](https://github.com/opendistro-for-elasticsearch/k-NN/pull/193))
* Add 1.10.0.0 release notes ([#201](https://github.com/opendistro-for-elasticsearch/k-NN/pull/201))

### Performance Analyzer

* Add release notes for 1.10 release ([#182](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/182))
* Update INSTALL.md to include accurate security info ([#261](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/261))
* Update release notes for 1.10.1 release ([#200](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/200))

### Perftop

* Add release notes for 1.10 release ([#57](https://github.com/opendistro-for-elasticsearch/perftop/pull/57))
* Update release notes for 1.10.1 release ([#60](https://github.com/opendistro-for-elasticsearch/perftop/pull/60))

### Release Engineering

* Add descriptions for several scripts with usage documentations ([#334](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/334))
* Update opendistro-build github repo issues link ([#382](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/382))
* HELM Readme Update, thanks @dmpe  ([#380](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/380) [#385](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/385))

### SQL

* update user documentation for testing odbc driver connection on windows([#722](https://github.com/opendistro-for-elasticsearch/sql/pull/722))
* Added workaround for identifiers with special characters in troubleshooting page([#718](https://github.com/opendistro-for-elasticsearch/sql/pull/718))
* Update release notes for OD 1.10 release([#699](https://github.com/opendistro-for-elasticsearch/sql/pull/699))



## MAINTENANCE

### Alerting

* Upgrade the vulnerable dependencies versions of Kotlin and 'commons-codec' ([#230](https://github.com/opendistro-for-elasticsearch/alerting/pull/230))
* Adds support for Elasticsearch 7.9.0 ([#238](https://github.com/opendistro-for-elasticsearch/alerting/pull/238))
* Adds support for Elasticsearch 7.9.1 ([#251](https://github.com/opendistro-for-elasticsearch/alerting/pull/251))

### Alerting Kibana Plugin

* Adds support for Kibana 7.9 ([#171](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/171))
* Adds support for Kibana 7.9.1 ([#181](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/181))

### Anomaly Detection

* Upgrade from 1.9.0 to 1.10.0 ([#215](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/215))
* Upgrade from 1.10.0 to 1.10.1 ([#224](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/224))

### Anomaly Detection Kibana Plugin

* Adding support for Kibana 7.9.0 ([#286](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/286))
* Updating plugin to use Kibana 7.9.1 ([#306](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/306))

### Index Management

* Adds support for Elasticsearch 7.9 ([#283](https://github.com/opendistro-for-elasticsearch/index-management/pull/283))
* Adds support for Elasticsearch 7.9.1 ([#288](https://github.com/opendistro-for-elasticsearch/index-management/pull/288))
* Refactors internal architecture/files to prepare for support of transforms/rollups ([#285](https://github.com/opendistro-for-elasticsearch/index-management/pull/285))

### Index Management Kibana Plugin

* Adds support for Kibana 7.9 ([#118](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/118))
* Adds support for Kibana 7.9.1 ([#120](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/120))

### Job Scheduler

* Update JobSchedulerPlugin to conform with changes to ExtensiblePlugin interface in Elasticsearch 7.9.0 ([#67](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/67))
* Add supports to Elasticsearch 7.9.1 ([#71](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/71))

### Knn

* ODFE 1.10 support for k-NN plugin ([#199](https://github.com/opendistro-for-elasticsearch/k-NN/pull/199))
* Upgrade Elasticsearch to 7.9.1 and ODFE to 1.10.1 ([#217](https://github.com/opendistro-for-elasticsearch/k-NN/pull/217))

### Performance Analyzer

* Build against elasticsearch 7.9 and resolve dependency conflicts ([#179](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/179))
* Update jackson and bouncycastle artifacts ([#307](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/307))
* Add integ test for queue rejection cluster RCA ([#370](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/370))
* Add IT for cache tuning ([#382](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/382))
* Match dependencies with writer ([#393](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/393))
* Build against elasticsearch 7.9.1 ([#197](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/197))

### Perftop

* Build against elasticsearch 7.9 ([#56](https://github.com/opendistro-for-elasticsearch/perftop/pull/56))
* Build against elasticsearch 7.9.1 ([#59](https://github.com/opendistro-for-elasticsearch/perftop/pull/59))

### Release Engineering

* Kibana has new cookie settings for security kibana plugin 2.0 framework (#397 (https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/397))

### Security

* Support ES 7.9.1 ([#706](https://github.com/opendistro-for-elasticsearch/security/pull/706))
* Support ES 7.9.0 ([#661](https://github.com/opendistro-for-elasticsearch/security/pull/661))
* Close AuditLog while closing OpenDistroSecurityPlugin and unregister shutdown hook when closing AuditLogImpl. ([#663](https://github.com/opendistro-for-elasticsearch/security/pull/663))
* Fix unit tests failures in HTTPSamlAuthenticatorTest ([#664](https://github.com/opendistro-for-elasticsearch/security/pull/664))
* Add copyright headers for audit classes ([#644](https://github.com/opendistro-for-elasticsearch/security/pull/644))
* Clean up rest and transport header filtering ([#637](https://github.com/opendistro-for-elasticsearch/security/pull/637))
* Upgrade jackson-databind to 2.11.2 ([#618](https://github.com/opendistro-for-elasticsearch/security/pull/618))

### Security Kibana

* Adds support for Kibana 7.9 ([#401](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/401))
* Adds support for Kibana 7.9.1 ([#452](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/452))

### SQL

* Bumped ES and Kibana versions to v7.9.0 ([#697](https://github.com/opendistro-for-elasticsearch/sql/pull/697))
* Bump ES and Kibana to 7.9.1 and release ODFE 1.10.1.0 ([#732](https://github.com/opendistro-for-elasticsearch/sql/pull/732))



## REFACTORING

### Knn

* Update default variable settings name ([#209](https://github.com/opendistro-for-elasticsearch/k-NN/pull/209))

### Performance Analyzer

* Make RCA framework NOT use ClusterDetailsEventProcessor ([#274](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/274))
* Refactor ModifyQueueCapacityAction to follow builder pattern ([#365](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/365))
* Refactor ModifyCacheCapacityAction to follow builder pattern ([#385](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/385))
* Refactoring the persistence layer to be able to persist any Java Object ([#407](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca/pull/407))



You can also track upcoming features in Open Distro for Elasticsearch by watching the code repositories or checking the [project website](https://opendistro.github.io/for-elasticsearch/features/comingsoon.html).


