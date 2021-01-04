# Open Distro for Elasticsearch 1.12.0 Release Notes

Open Distro for Elasticsearch 1.12.0 is now available for download.

The release consists of Apache 2 licensed Elasticsearch version 7.10.0 and Kibana version 7.10.0. Plugins in the distribution include Alerting, Index Management, Performance Analyzer (with Root Cause Analysis Engine), Security, SQL, Machine Learning with k-NN, Job Scheduler, Anomaly Detection, Kibana Notebooks, Reports, and Gantt Chart. Also, SQL JDBC/ODBC driver, SQL CLI Client, and PerfTop (a client for Performance Analyzer) are available for download now.

## Release Highlights

* You can now share reports in PDF, CSV, and PNG format with [Kibana Reports](https://github.com/opendistro-for-elasticsearch/kibana-reports). You can schedule or immediately generate reports from the Dashboard, Visualize, and Discover panels.
* We introduced a new visualization in Kibana that provides you with an ability to embed Gantt charts into dashboards to enable visualization of events, steps and tasks as horizontal bars. 
* As time-series data grows to considerable sizes over time, it can slow down your aggregations, and incur a substantial storage cost. Also, the usefulness of high granularity data reduces with time. [Rollups](https://github.com/opendistro-for-elasticsearch/index-management/tree/rollup-dev) lets you summarize the data and helps you preserve useful aggregations that can be leveraged for analytics while drastically reducing storage costs. 
* [Hamming distance](https://github.com/opendistro-for-elasticsearch/k-NN/issues/264) can now be used as a distance metric for similarity search. Hamming distance measures similarity by comparing two binary data strings and is commonly used in image retrieval, fraud detection, and recognizing duplicate webpages. 

## Release Details

Open Distro for Elasticsearch 1.12.0 includes the following breaking changes, features, enhancements, bug fixes, infrastructure, documentation, maintenance, and refactoring updates.

## BREAKING CHANGES
* We have renamed all the Kibana Plugins with camelCase naming convention. You can find the full list of names [here](https://opendistro.github.io/for-elasticsearch-docs/docs/kibana/plugins/#plugin-compatibility).

## FEATURES

### Alerting
* Allow for http method selection in custom webhook ([#101](https://github.com/opendistro-for-elasticsearch/alerting/pull/101))


### Alerting Kibana Plugin
* Allow for http method selection in custom webhook ([#90](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/90))

### Index Management
* Adds support for Rollup feature ([#319](https://github.com/opendistro-for-elasticsearch/index-management/pull/319), [#320](https://github.com/opendistro-for-elasticsearch/index-management/pull/320), [#321](https://github.com/opendistro-for-elasticsearch/index-management/pull/321), [#322](https://github.com/opendistro-for-elasticsearch/index-management/pull/322), [#323](https://github.com/opendistro-for-elasticsearch/index-management/pull/323), [#324](https://github.com/opendistro-for-elasticsearch/index-management/pull/324), [#336](https://github.com/opendistro-for-elasticsearch/index-management/pull/336), [#337](https://github.com/opendistro-for-elasticsearch/index-management/pull/337), [#338](https://github.com/opendistro-for-elasticsearch/index-management/pull/338), [#339](https://github.com/opendistro-for-elasticsearch/index-management/pull/339), [#340](https://github.com/opendistro-for-elasticsearch/index-management/pull/340), [#341](https://github.com/opendistro-for-elasticsearch/index-management/pull/341), [#342](https://github.com/opendistro-for-elasticsearch/index-management/pull/342), [#343](https://github.com/opendistro-for-elasticsearch/index-management/pull/343), [#344](https://github.com/opendistro-for-elasticsearch/index-management/pull/344), [#345](https://github.com/opendistro-for-elasticsearch/index-management/pull/345), [#346](https://github.com/opendistro-for-elasticsearch/index-management/pull/346), [#347](https://github.com/opendistro-for-elasticsearch/index-management/pull/347), [#348](https://github.com/opendistro-for-elasticsearch/index-management/pull/348))

### Index Management Kibana Plugin
* Rollup Kibana ([#128](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/128))


### Kibana Reports
* Lock Edit report source and Input Validation ([#225](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/225))
* Use puppeteer-core with custom chromium instead of puppeteer ([#222](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/222))
* Added Loading Modal to Details pages ([#221](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/221))
* Add Multiselect for Reports Table ([#218](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/218))
* Add Icon to Refresh Button on Landing Page ([#216](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/216))
* Using request tenant info from common-utils to filter ([#215](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/215))
* Adding filtering the reports based on tenants. ([#214](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/214))
* Use new API to Generate Reports from Existing Definitions ([#213](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/213))
* Disable api calls that uses Kibana default internal user ([#212](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/212))
* More polish to visual report(pdf and png) ([#211](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/211))
* Refine pdf/png report generated by puppeteer ([#209](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/209))
* Remove Persistent Permissions Error Toast ([#208](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/208))
* Adding support for filter by Roles ([#204](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/204))
* [reports-scheduler] Add support for Elasticsearch 7.10.0 ([#203](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/203))
* Not returning access details for non-admin users ([#202](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/202))
* disable notification feature from UI ([#198](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/198))
* Add Permissions Error Toasts and Input Validation Errors ([#196](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/196))
* Updated Time Range Parsing in Report Details ([#195](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/195))
* Call updateReportStatus and notification API as Kibana user ([#194](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/194))
* Remove create report logic for background job ([#193](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/193))
* Fixed Base Url Formation for Visualizations/Saved Searches ([#192](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/192))
* Adding Validation Modal for Deleting Report Definition ([#190](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/190))
* Updated logging : reduced logging size where not required to be verbose ([#189](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/189))
* Updated Toast Notifications ([#188](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/188))
* Fixed poller permission check ([#186](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/186))
* Align url format with all other Open Distro plugins ([#185](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/185))
* Add Punctuation to All Toasts ([#184](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/184))
* Added user and backend role based access control to APIs ([#183](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/183))
* Add unit testing for model converters ([#182](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/182))
* Improve query_url and base_url input validation ([#181](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/181))
* Removed deprecated APIs and cleaned up code. ([#180](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/180))
* Improve typing and remove deprecated code ([#179](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/179))
* Pagination support for list APIs ([#178](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/178))
* Changed "roles" to "access" to support multiple access patterns. ([#175](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/175))
* Added transport actions for all the APIs ([#174](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/174))
* Update Monthly Report Trigger UI ([#171](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/171))
* Cypress Edit Test ([#170](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/170))
* Cypress Tests for Details Pages ([#169](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/169))
* Using IndexManager operation directly through variables ([#168](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/168))
* Added model for all REST request/response ([#167](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/167))
* Add Cypress Test Framework & Create tests ([#166](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/166))
* Setup github action for reports-scheduler ([#164](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/164))
* Remove Modal Elements ([#162](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/162))
* Improve Main Test Coverage ([#161](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/161))
* Improve Coverage for Homepage Tables ([#160](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/160))
* Add github action CI/CD for kibana-reports plugin ([#159](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/159))
* Improve Delivery Test Coverage ([#158](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/158))
* [Testing] Update existing visual/data report helper test suite ([#157](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/157))
* Fix Warning on Report Details Test ([#156](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/156))
* Improved Test Coverage for Report Settings ([#155](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/155))
* Report definition details/Report details test coverage increase ([#154](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/154))
* Remove "refresh interval" option from time selector ([#153](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/153))
* Disable/Hide related UI to leave only CSV report ([#152](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/152))
* Removed baseUrl as it can be created from SourceType and Source.id ([#151](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/151))
* Report Trigger Jest Test Coverage ([#150](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/150))
* Added JobSchedular integration to index operation APIs ([#149](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/149))
* Preserve Pre-error Edit state on Invalid Update ([#147](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/147))
* Adding polling and job locking API ([#143](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/143))
* Update report definition UI styles ([#142](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/142))
* Add email body template & Optimize notification setting UI ([#141](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/141))
* Update editor selected tab and list preview style ([#138](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/138))
* Update Kibana nav menu order ([#137](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/137))
* Report Definition Details Display Change ([#136](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/136))
* ReportDefinition and ReportInstance index operations and REST APIs cr… ([#135](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/135))
* Change Selector for Visualization Reports ([#133](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/133))
* Add download to reportDetails and reportDefinitionDetails ([#131](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/131))
* Use session cookie for puppeteer to access url of security-enabled domain ([#129](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/129))
* Improve server side input validation ([#128](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/128))
* Update Jest Snapshots ([#127](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/127))
* Main_utils Test Suite ([#126](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/126))
* Sanitize header and footer user input ([#125](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/125))
* Added settings/configuration support to plugin ([#124](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/124))
* Converted some of the required classes to Kotlin ([#122](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/122))
* Add context menu UI on discover ([#121](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/121))
* Header & Footer Plaintext Support ([#120](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/120))
* Kotlin support to the plugin added ([#119](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/119))
* Added Toasts for all API actions ([#116](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/116))
* Input Validation for Create Report Definition ([#115](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/115))
* Update the ES query result size from default 100 to default max value 10000 ([#114](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/114))
* Remove Unused Filters ([#113](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/113))
* Removed test_data dependency ([#112](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/112))
* Removed Unnecessary Columns/Filters ([#111](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/111))
* Integrate notification to kibana-reports ([#109](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/109))
* Change Trigger Types in Edit page ([#107](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/107))
* Add Functionality to Report Definition Details Buttons ([#105](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/105))
* Make Container Width Responsive ([#104](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/104))
* UI Changes after Version Upgrade ([#102](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/102))
* CSV Integration for On-demand Reports ([#100](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/100))
* Use kibana server hostname for puppeteer to access pages ([#99](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/99))
* Add In-Context Reporting Menu ([#97](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/97))
* Create Report Definition Final UI Changes ([#82](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/82))
* Report Definition Details UI Changes ([#80](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/80))
* Moving the notification code to new repository ([#79](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/79))
* Report Details UI Final Changes ([#74](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/74))
* UI Homepage Final Review Items ([#71](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/71))
* Added REST input parser respod success in JSON ([#70](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/70))
* UI Fit & Finish Pre-check Changes ([#69](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/69))
* Initial commit to notification plugin. ([#67](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/67))
* Connect Kibana-reports plugin to reports-scheduler plugin ([#63](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/63))
* Added .vscode/ to gitignore list ([#60](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/60))
* Add Trimming and Header & Footer Functionality ([#59](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/59))
* Hooked Edit report definition APIs ([#58](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/58))
* Add Routes for Get Visualizations & Saved Search ([#57](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/57))
* Build Reports Scheduler ES plugin ([#56](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/56))
* Connect Report Definition Details Backend ([#53](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/53))
* Connect Report Details Backend ([#52](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/52))
* Connect Front & Back End for Homepage & Create report definition ([#51](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/51))
* APIs endpoints for data reports. ([#50](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/50))
* Add Edit Report Definition UI ([#48](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/48))
* CRUD APIs for report and report definition ([#47](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/47))
* Update Kibana-Reporting-Design-Proposal.md ([#44](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/44))
* Add Report Definition Details UI ([#43](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/43))
* Create Report Final UI ([#42](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/42))
* Update Landing Page UI ([#37](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/37))
* update image headers ([#35](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/35))
* Stream reports to client ([#30](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/30))
* Update UI Snapshot ([#29](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/29))
* Add Report Details UI ([#28](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/28))
* API to generate report in PDF/PNG format ([#16](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/16))
* First Typescript Migration ([#13](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/13))
* First UI Unit Test ([#10](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/10))
* Reporting UI ([#9](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/9))


### Kibana Visualizations
* Rebase gantt chart to main as a sub directory ([#1](https://github.com/opendistro-for-elasticsearch/kibana-visualizations/pull/1))


### k-NN
* Support for hamming bit distance in custom scoring ([#267](https://github.com/opendistro-for-elasticsearch/k-NN/pull/267))


### Performance Analyzer
* Publish shard state metrics ([#212](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/212))
* Add Master Throttling Collector Metrics ([#227](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/227))
* Publish fault detection metrics ([#218](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/218))
* Adding new GC info collector to the scheduled metrics collector([#225](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/225))


### SQL
* Add count() support for PPL ([#894](https://github.com/opendistro-for-elasticsearch/sql/pull/894))
* Add like, isnull, isnotnull function in PPL ([#893](https://github.com/opendistro-for-elasticsearch/sql/pull/893))
* Revert Error Messages for Run/Explain ([#889](https://github.com/opendistro-for-elasticsearch/sql/pull/889))
* Extend the PPL identifier defintion ([#888](https://github.com/opendistro-for-elasticsearch/sql/pull/888))
* Add Error Message for Explain and Run ([#872](https://github.com/opendistro-for-elasticsearch/sql/pull/872))
* Remove workbench side nav logo and fix download link ([#869](https://github.com/opendistro-for-elasticsearch/sql/pull/869))
* For ODFE 1.12 change position for sql workbench plugin (remove DEFAULT_APP_CATEGORIES) ([#857](https://github.com/opendistro-for-elasticsearch/sql/pull/857))
* For ODFE 1.12 change position for sql workbench plugin ([#855](https://github.com/opendistro-for-elasticsearch/sql/pull/855))
* Add support for HH:mm:ss ([#850](https://github.com/opendistro-for-elasticsearch/sql/pull/850))
* Support NULLS FIRST/LAST in new engine ([#843](https://github.com/opendistro-for-elasticsearch/sql/pull/843))
* Support subquery in FROM clause in new engine ([#822](https://github.com/opendistro-for-elasticsearch/sql/pull/822))
* Support CASE clause in new engine ([#818](https://github.com/opendistro-for-elasticsearch/sql/pull/818))
* Support COUNT star and literal in new engine ([#802](https://github.com/opendistro-for-elasticsearch/sql/pull/802))
* Adding example of nested() for more complex nested queries ([#801](https://github.com/opendistro-for-elasticsearch/sql/pull/801))
* Adding example of nested() for more complex nested queries ([#799](https://github.com/opendistro-for-elasticsearch/sql/pull/799))
* Support HAVING in new SQL engine ([#798](https://github.com/opendistro-for-elasticsearch/sql/pull/798))
* Add ppl request log ([#796](https://github.com/opendistro-for-elasticsearch/sql/pull/796))

### Release Engineering
* Add CodeQL for scanning vulnerabilities for Pull Request in opendistro-build repository ([#466](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/466))


## ENHANCEMENTS

### Alerting
* Run /_execute in User context ([#312](https://github.com/opendistro-for-elasticsearch/alerting/pull/312))
* Support filterBy in update/delete destination/monitor APIs ([#311](https://github.com/opendistro-for-elasticsearch/alerting/pull/311))


### Alerting Kibana Plugin
* Change the position of the plugin in the side bar ([#214](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/214))
* Remove an unused import after the side bar change ([#216](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/216))
* Add toast notifications for more backend errors ([#219](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/219))


### Anomaly Detection
* Improve profile API ([#298](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/298))
* Add checkpoint index retention for multi entity detector ([#283](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/283))
* Stashing context for Stats API to allow users to query from RestAPI ([#300](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/300))
* Add HC detector request/failure stats ([#307](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/307))


### Anomaly Detection Kibana Plugin
* Fix vulnerability caused by old version formik. Issue: #333 ([#334](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/333))
* Change side bar position for anomly detection plugin ([#335](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/335))
* Use plotly.js-dist to reduce artifact size ([#340](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/340))

### Index Management
* Adds support for Elasticsearch 7.10.0 ([#349](https://github.com/opendistro-for-elasticsearch/index-management/pull/349))

### Index Management Kibana Plugin
* Change position of index-management in kibana side bar ([#140](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/140))
* Kibana migration ([#142](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/142))
 

### Performance Analyzer
* Updating Default Port web-server to 9600 ([#233](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/233))


### Security
* Adding support for SSL dual mode ([#712](https://github.com/opendistro-for-elasticsearch/security/pull/712))
* When replacing .kibana index with multi-tenant index, create index with alias if one already does not exist ([#765](https://github.com/opendistro-for-elasticsearch/security/pull/765))
* Demo Config : Adding AD Indices to system index and creating pre-defined roles ([#776](https://github.com/opendistro-for-elasticsearch/security/pull/776))
* Add user & roles to the thread context  ([#798](https://github.com/opendistro-for-elasticsearch/security/pull/798))
* Security configuration for reporting and notification plugins ([#836](https://github.com/opendistro-for-elasticsearch/security/pull/836))
* Support user injection for transport requests ([#763](https://github.com/opendistro-for-elasticsearch/security/pull/763))
* Support ES 7.10.0 ([#840](https://github.com/opendistro-for-elasticsearch/security/pull/840))
* Support certs with separate Extended Key Usage ([#493](https://github.com/opendistro-for-elasticsearch/security/pull/493))
* Adding requested tenant to the thread context transient info for consumption ([#850](https://github.com/opendistro-for-elasticsearch/security/pull/850))


### SQL
* Sort field push down ([#848](https://github.com/opendistro-for-elasticsearch/sql/pull/848))
* Seperate the logical plan optimization rule from core to storage engine ([#836](https://github.com/opendistro-for-elasticsearch/sql/pull/836))


### Release Engineering
* All roles in one statefulset, allows to choose between dedicated/non-dedicated pods for lightweight deployments in helm charts, thanks @everythings-gonna-be-alright  ([#453](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/453))


## BUG FIXES

### Alerting
* Get user info from threadcontext ([#289](https://github.com/opendistro-for-elasticsearch/alerting/pull/289))
* Fix filter by user.backendroles and integ tests for it ([#290](https://github.com/opendistro-for-elasticsearch/alerting/pull/290))
* Check empty user object for the AD monitor ([#304](https://github.com/opendistro-for-elasticsearch/alerting/pull/304))
* Add security system property for integTest task ([#319](https://github.com/opendistro-for-elasticsearch/alerting/pull/319))
* Fix failed IT cases for AD ([#320](https://github.com/opendistro-for-elasticsearch/alerting/pull/320))


### Alerting Kibana Plugin
* Fix 2 bugs in Anomaly Detection monitor ([#215](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/215))


### Anomaly Detection
* Fix edge case where entities found for preview is empty ([#296](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/296))
* Fix null user in detector ([#301](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/301))
* Fix fatal error of missing method parseString ([#302](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/302))
* Remove clock Guice binding ([#305](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/305))
* Filter out empty value for entity features ([#306](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/306))
* Fix for upgrading mapping ([#309](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/309))
* Fix double nan error when parse to json ([#310](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/310))
* Fix issue where data hole exists for Preview API ([#312](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/312))
* Fix delete running detector bug ([#320](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/320))
* Fix detector and feature serialization ([#322](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/322))
* Moving common-utils to 1.12.0.2 ([#323](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/323))


### Anomaly Detection Kibana Plugin
* Show second for heatmap cell hover timestamp ([#327](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/327))
* Fix sunburst chart height is 0 ([#332](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/332))
* Fix two issues during recent upgrade ([#339](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/339))


### Index Management
* Correctly handles remote transport exceptions in rollover ([#325](https://github.com/opendistro-for-elasticsearch/index-management/pull/325))
* Accept request parameters in RestGetRollupAction and fix flakey tests ([#353](https://github.com/opendistro-for-elasticsearch/index-management/pull/353))


### Index Management Kibana Plugin
* Bug fix for duplicate dimension/metrics items and deletion error ([#145](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/145)) 
  

### Kibana Notebooks
* Correct URL link ([#55](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/55))


### Kibana Reports
* Use default max size to call getAll ES API ([#224](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/224))
* In-context menu download UI ([#219](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/219))
* ReportInstance is missing id field ([#207](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/207))
* Permission denied error for background job when security is disabled ([#191](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/191)) refine error handler ([#187](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/187))
* Use relative url for href attribute of report source link ([#173](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/173))
* Context menu doesn't show up when switching between tabs from sidebar ([#172](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/172))
* Fix Timezone selection and bugs ([#144](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/144))
* Create/Edit Bug Fixes ([#140](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/140))
* Improve logging and error handling; Fix edit report bug; Fix header/footer rendering ([#123](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/123))
* Fix small display issues in report details and report table ([#85](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/85))
* Configure fixed timezone for jest testing ([#163](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/163))
* Fix "open in Kibana" link issue in embedded html of email body ([#148](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/148))
* Fix email recipients render in edit report definition page ([#146](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/146))
* Report Details UI Fixes ([#145](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/145))
* Workaround to fix table refresh, disable links for pending reports ([#139](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/139))
* Landing Page Minor Issues Fix ([#132](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/132))
* Create from Context Menu Fix ([#130](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/130))
* Time Range Fixes ([#118](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/118))
* Context Menu Fixes ([#117](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/117))
* Fix enable/disable after editing schedule type ([#110](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/110))
* Small UI Fixes ([#108](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/108)) Refactor ([#103](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/103))
* Apply workaround to partially fix the plugin build issue ([#96](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/96))
* Add trigger type check for delete report definition API ([#77](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/77))
* Fix CSV Test Cases ([#62](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/62))


### Performance Analyzer
* Cache Size metric: Using the Actual Cache Values and not the Delta ([#231](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/231))


### Security
* Fix missing trim when parsing roles in proxy authenticator ([#766](https://github.com/opendistro-for-elasticsearch/security/pull/766))
* Fix empty password issue in upgrade from 6x to 7x ([#816](https://github.com/opendistro-for-elasticsearch/security/pull/816))
* Reject empty password in internal user creation ([#818](https://github.com/opendistro-for-elasticsearch/security/pull/818))
* Use reflection to get reduceOrder, termBytes and format due to java.lang.IllegalAccessError ([#866](https://github.com/opendistro-for-elasticsearch/security/pull/866))
* Fix for java.io.OptionalDataException that is caused by changes to User object after it is put on thread context. ([#869](https://github.com/opendistro-for-elasticsearch/security/pull/869))
* Catch and respond invalid_index_name_exception when an index with invalid name is mentioned ([#865](https://github.com/opendistro-for-elasticsearch/security/pull/865))


### SQL
* Fix workbench version number for ODFE 1.12.0.0 ([#903](https://github.com/opendistro-for-elasticsearch/sql/pull/903))
* Disable sorting on workbench ([#900](https://github.com/opendistro-for-elasticsearch/sql/pull/900))
* Fix select all from subquery issue ([#902](https://github.com/opendistro-for-elasticsearch/sql/pull/902))
* Fix for ExprValueFactory construct issue ([#898](https://github.com/opendistro-for-elasticsearch/sql/pull/898))
* Fix issue result table in workbench not displaying values of boolean type ([#891](https://github.com/opendistro-for-elasticsearch/sql/pull/891))
* Fix key "id" in result table issue of the workbench ([#890](https://github.com/opendistro-for-elasticsearch/sql/pull/890))
* Fix workbench bugs from plugin platform upgrade ([#886](https://github.com/opendistro-for-elasticsearch/sql/pull/886))
* Fix ExprCollectionValue serialization bug ([#859](https://github.com/opendistro-for-elasticsearch/sql/pull/859))
* Fix issue: sort order keyword is case sensitive ([#853](https://github.com/opendistro-for-elasticsearch/sql/pull/853))
* Config the default locale for gradle as en_US ([#847](https://github.com/opendistro-for-elasticsearch/sql/pull/847))
* Fix bug of nested field format issue in JDBC response ([#846](https://github.com/opendistro-for-elasticsearch/sql/pull/846))
* Fix symbol error and Fix SSLError when connect es. ([#831](https://github.com/opendistro-for-elasticsearch/sql/pull/831))
* Bug fix, using Local.Root when format the string in DateTimeFunctionIT ([#794](https://github.com/opendistro-for-elasticsearch/sql/pull/794))

### Release Engineering
* Fix description of "maxUnavailable" in helm charts, thanks @webwurst ([#489](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/489))


## INFRASTRUCTURE

### Alerting
* Add integ security tests with a limited user ([#313](https://github.com/opendistro-for-elasticsearch/alerting/pull/313))


### Anomaly Detection
* Add multi node integration testing into CI workflow ([#318](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/318))


### Index Management Kibana Plugin
* Updates to github action workflows and some bug fix after upgrading to Kibana 7.10 ([#139](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/139))
  

### Kibana Notebooks
* Update plugin id to use camelcase ([#51](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/51))


### Performance Analyzer
* Set up jacoco for code coverage ([#234](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/234))


### SQL
* Revert java version in jdbc release workflow ([#871](https://github.com/opendistro-for-elasticsearch/sql/pull/871))
* Fix for odbc build failure ([#885](https://github.com/opendistro-for-elasticsearch/sql/pull/885))
* Fix release workflow for workbench ([#868](https://github.com/opendistro-for-elasticsearch/sql/pull/868))
* Add workflow to rename and upload odbc to s3 ([#865](https://github.com/opendistro-for-elasticsearch/sql/pull/865))
* Add codecov for sql plugin ([#835](https://github.com/opendistro-for-elasticsearch/sql/pull/835))
* Update odbc workflow ([#828](https://github.com/opendistro-for-elasticsearch/sql/pull/828))
* Updated workbench snapshots to fix broken workflow ([#823](https://github.com/opendistro-for-elasticsearch/sql/pull/823))
* Updated Mac version for GitHub action build ([#804](https://github.com/opendistro-for-elasticsearch/sql/pull/804))
* Fix unstable integration tests ([#793](https://github.com/opendistro-for-elasticsearch/sql/pull/793))
* Update cypress tests and increase delay time ([#792](https://github.com/opendistro-for-elasticsearch/sql/pull/792))


## DOCUMENTATION

### Alerting Kibana Plugin
* Update release notes for 1.12.0.2 ([#226](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/226))


### Anomaly Detection Kibana Plugin
* Update release notes ([#326](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/326))
* Update release notes ([#336](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/336))


### Kibana Reports
* Add UX documentation, userflows, screens and mocks ([#34](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/34))
* Update README with dev guide ([#23](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/23))
* Update user stories ([#22](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/22))
* Update Design Proposal ([#18](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/18))
* Design Proposal Update ([#15](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/15))


### SQL
* Add identifier and datatype documentation for PPL ([#873](https://github.com/opendistro-for-elasticsearch/sql/pull/873))
* Add doc for ODFE SQL demo ([#826](https://github.com/opendistro-for-elasticsearch/sql/pull/826))
* Update out-of-date documentation ([#820](https://github.com/opendistro-for-elasticsearch/sql/pull/820))
* Add release notes for ODFE 1.12 ([#841](https://github.com/opendistro-for-elasticsearch/sql/pull/841))


## MAINTENANCE

### Alerting
* Adds support for Elasticsearch 7.10.0 ([#300](https://github.com/opendistro-for-elasticsearch/alerting/pull/300))
* Move to common-utils-1.12.0.2 version ([#314](https://github.com/opendistro-for-elasticsearch/alerting/pull/314))


### Alerting Kibana Plugin
* Add support for Kibana 7.10.0 ([#212](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/212))


### Anomaly Detection
* Support ES 7.10.0 ([#313](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/313))


### Anomaly Detection Kibana Plugin
* Migrate entire plugin to new platform ([#328](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/328))
* Upgrade to Kibana 7.10.0 ([#329](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/329))

### Index Management
* Uploads elasticsearch.log files from failed CI runs ([#336](https://github.com/opendistro-for-elasticsearch/index-management/pull/336))
* Adds support for running local cluster with security plugin enabled ([#322](https://github.com/opendistro-for-elasticsearch/index-management/pull/322))
* Updates integration tests to not wipe indices between each test to help reduce tests bleeding into each other ([#342](https://github.com/opendistro-for-elasticsearch/index-management/pull/342))
* Changes set-env command in github workflow (* Adds support for Elasticsearch 7.10.0 ([#349](https://github.com/opendistro-for-elasticsearch/index-management/pull/349)))

### Job Scheduler
* Support Elasticsearch 7.10 ([#82](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/82))


### Kibana Notebooks
* Upgrade to ODFE 1.12.0 ([#56](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/56))


### Kibana Reports
* Position change for reporting plugin in side bar ([#223](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/223))
* Position change for reporting plugin in side bar ([#217](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/217))
* Add support for Kibana 7.10.0 ([#205](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/205))
* Migrate all Kibana server side APIs to call ES-reporting APIs ([#177](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/177))
* Upgrade to ES/Kibana version v7.9.1 ([#101](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/101))
* Migrate the project to be under a fixed Kibana version 7.8.0 ([#55](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/55))
* Migrate Client-Side to New Platform ([#41](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/41))
* Migrate server side to new kibana plugin platform ([#38](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/38))
* Migrate create_report/ to Typescript ([#17](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/17))
* Migrate public/main to Typescript ([#14](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/14))


### Kibana Visualizations
* Upgrade to ODFE 1.12.0 ([#3](https://github.com/opendistro-for-elasticsearch/kibana-visualizations/pull/3))


### k-NN
* k-NN plugin support for Elasticsearch version 7.10.0 ([#271](https://github.com/opendistro-for-elasticsearch/k-NN/pull/271))
* Bump odfe version to 1.12 ([#273](https://github.com/opendistro-for-elasticsearch/k-NN/pull/273))


### Security
* Create release drafter ([#769](https://github.com/opendistro-for-elasticsearch/security/pull/769))
* Upgrade junit to 4.13.1 ([#835](https://github.com/opendistro-for-elasticsearch/security/pull/835))
* Updating static_roles.yml ([#838](https://github.com/opendistro-for-elasticsearch/security/pull/838))
* Security configuration cleanup for static and test resources ([#841](https://github.com/opendistro-for-elasticsearch/security/pull/841))
* Change version to 1.12.0.0 ([#860](https://github.com/opendistro-for-elasticsearch/security/pull/860))
* Upgrade github CD action to using Environment Files ([#862](https://github.com/opendistro-for-elasticsearch/security/pull/862))
* Refactor getUserInfoString ([#864](https://github.com/opendistro-for-elasticsearch/security/pull/864))
* Update 1.12 release notes ([#867](https://github.com/opendistro-for-elasticsearch/security/pull/867))
* Update 1.12 release notes ([#872](https://github.com/opendistro-for-elasticsearch/security/pull/872))
* Use StringJoiner instead of (Immutable)List builder ([#877](https://github.com/opendistro-for-elasticsearch/security/pull/877))


### Security Kibana Plugin
* Add support for elasticsearch 7.10.0 ([#626](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/626))


### SQL
* SQL release for Elasticsearch 7.10 ([#834](https://github.com/opendistro-for-elasticsearch/sql/pull/834))
* Migrate Query Workbench to new Platform ([#812](https://github.com/opendistro-for-elasticsearch/sql/pull/812))
* Migrate Query Workbench to 7.10 ([#840](https://github.com/opendistro-for-elasticsearch/sql/pull/840))
* Bump version number to 1.12.0.0 for [JDBC, ODBC, SQL-CLI] ([#838](https://github.com/opendistro-for-elasticsearch/sql/pull/838))


## REFACTORING

### Alerting Kibana Plugin
* Migrate Alerting Kibana plugin to the new Kibana Platform ([#209](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/209))
* Create a constant for the size of query results used for drop-down menus ([#213](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/213))
* Remove Kibana icon for the ODFE category in side bar ([#218](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/218))
* Fix issue that nothing is in 'Time field' dropdown when defining monitors by visual graph after the migration ([#222](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/222))
* Remove 'JSON.stringify()' from constructing the body of API calls in request handlers ([#223](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/223))
* Correct variable names of the response for 'getEmailAccount' and 'getEmailGroup' in the request handler  ([#224](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/224))
* Passing 'core.notifications' to 'Email' and 'EmailRecipients' components ([#225](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/225))


### Kibana Reports
* [UI] Align create report definition UI to schema & API refactor ([#83](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/83))
* [UI] Align UI to the schema & API refactor - table and detail page ([#78](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/78))
* Refactoring saved search reporting APIs maintenance ([#73](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/73))
* Refactor schema and API [backend] ([#72](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/72))

You can also track upcoming features in Open Distro for Elasticsearch by watching the code repositories or checking the [project website](https://opendistro.github.io/for-elasticsearch/features/comingsoon.html).
