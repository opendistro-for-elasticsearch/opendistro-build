# Open Distro for Elasticsearch 1.11.0 Release Notes
Open Distro for Elasticsearch 1.11.0 is now available for download.

The release consists of Apache 2 licensed Elasticsearch version 7.9.1, and Kibana version 7.9.1. Plugins in the distribution include Alerting, Index Management, Performance Analyzer (with Root Cause Analysis Engine), Security, SQL, Machine Learning with k-NN, Anomaly Detection, and Kibana Notebooks. Also, SQL JDBC/ODBC driver, SQL CLI Client, and PerfTop (a client for Performance Analyzer) are available for download now.

## Release Highlights
* [Piped Processing Language (PPL)](https://opendistro.github.io/for-elasticsearch-docs/docs/ppl/) lets you explore, discover, and find data stored in Elasticsearch using a set of commands delimited by pipes ("\|"). PPL extends Elasticsearch to support a standard set of commands and functions.
* [High cardinality support in Anomaly Detection](https://github.com/opendistro-for-elasticsearch/anomaly-detection/issues/147) provides granular insights from high-volume log streams by identifying and isolating anomalies to unique entities like hostnames or IP addresses.
* With fine grained access control support for [Anomaly Detection](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/538) and [Alerting](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/532), you can now delegate permissions to non-administrative users to access and configure these plug-ins.
* With [window functions](https://github.com/opendistro-for-elasticsearch/sql/pull/753) in SQL, you can define a frame or window of rows with a given length around the current row, and performs a calculation across the set of data in the window.
* [Custom scoring in k-NN](https://github.com/opendistro-for-elasticsearch/k-NN/pull/196) enables complex pre-filtering of your documents and dynamic application of k-NN on the filtered documents to improve the similarity search results.
* [Kibana Notebooks](https://opendistro.github.io/for-elasticsearch-docs/docs/kibana/notebooks/) provides you with an ability to interactively and collaboratively develop rich reports backed by live data. Common use cases for notebooks include creating postmortem reports, designing run books, building live infrastructure reports, or even documentation.

## Release Details

Open Distro for Elasticsearch 1.11.0 includes the following features, enhancements, bug fixes, infrastructure, documentation, maintenance, and refactoring updates.

## FEATURES

### Anomaly Detection Kibana Plugin
* Add UX support for HC detector ([#314](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/314))


### Job Scheduler
* Add a method to support renewing a lock in LockService class ([#74](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/74))


### Kibana Notebooks
* Rewrite notebooks UI ([#40](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/40))
* Add default parser & common config, move helper & paragraphs components ([#35](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/35))
* Add default backend, InputType param to add-paragraph API ([#34](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/34))
* Add paragraph components and UI helpers ([#28](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/28))
* Add UI components for App, main, notebooks and note_buttons ([#27](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/27))
* Add new route for visualizations ([#25](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/25))
* Add API Routes and Zeppelin Backend Adaptor ([#24](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/24))
* Add .DS_Store in gitignore, added header in app.tsx ([#23](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/23))
* Initial Commit - new platform, gitignore, license header ([#18](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/18))
* Build sample plugin RPM ([#3](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/3))


### k-NN
* Pre filter support through custom scoring ([#196](https://github.com/opendistro-for-elasticsearch/k-NN/pull/196))


### Performance Analyzer
* Batch Metrics API ([#159](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/159))


### Perftop
* Feature temperature rca ([#52](https://github.com/opendistro-for-elasticsearch/perftop/pull/52))


### Release Engineering
* Adding whitesource scans to ODFE repos for security vulnerabilities and licenses ([#437](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/437))


### SQL
* Add support of basic data types byte, short, binary and add data type testing ([#780](https://github.com/opendistro-for-elasticsearch/sql/pull/780))
* Support ranking window functions ([#753](https://github.com/opendistro-for-elasticsearch/sql/pull/753))
* Add LogicalPlan optimization ([#763](https://github.com/opendistro-for-elasticsearch/sql/pull/763))
* Support DATE_FORMAT function ([#764](https://github.com/opendistro-for-elasticsearch/sql/pull/764))
* Support date and time function: week ([#757](https://github.com/opendistro-for-elasticsearch/sql/pull/757))
* Support aggregations min, max ([#541](https://github.com/opendistro-for-elasticsearch/sql/pull/541))
* Support date and time functions ([#746](https://github.com/opendistro-for-elasticsearch/sql/pull/746))


## ENHANCEMENTS

### Alerting
*  Add logged-on User details to the Monitor and Destination ([#255](https://github.com/opendistro-for-elasticsearch/alerting/pull/255))
*  Inject roles for alerting background jobs ([#259](https://github.com/opendistro-for-elasticsearch/alerting/pull/259))
*  Terminate security for email transport handlers ([#262](https://github.com/opendistro-for-elasticsearch/alerting/pull/262))
*  Add AllowList for Destinations ([#263](https://github.com/opendistro-for-elasticsearch/alerting/pull/263))
*  Add User to Alerts, add filter by back end roles ([#264](https://github.com/opendistro-for-elasticsearch/alerting/pull/264))
*  Change AlertError message and remove deny-list destinations check during monitor creation ([#270](https://github.com/opendistro-for-elasticsearch/alerting/pull/270))
*  Use common-utils from maven, use withContext instead runBlocking ([#273](https://github.com/opendistro-for-elasticsearch/alerting/pull/273))
*  Allow empty notification responses ([#272](https://github.com/opendistro-for-elasticsearch/alerting/pull/272))
*  Add user role filter for monitor on top of ad result ([#275](https://github.com/opendistro-for-elasticsearch/alerting/pull/275))


### Alerting Kibana Plugin
* Add toast message when error occurs in running a monitor or creating/updating a trigger ([#201](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/201))
* Get alerts, destinations, and monitors using Rest APIs ([#190](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/190))
* Show alerts error messages in dashboard ([#182](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/182))
* Show name of the user who last updated the monitor in Monitor Dashboard and Detail page ([#187](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/187))
* Add a toast message and auto scroll to the 1st error field when failed to create/update a monitor or destination ([#168](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/168))
* Add AllowList for Destinations ([#192](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/192))


### Anomaly Detection
* Remove deprecated code ([#228](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/228))
* CLI: Download Detector Configuration as File ([#229](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/229))
* CLI: Update Display Strings ([#231](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/231))
* CLI: Fix build errors ([#235](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/235))
* Add RestActions support for AD Search Rest API's ([#234](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/234))
* Add RestActions support for Detector Stats API ([#237](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/237))
* Add anomaly feature attribution to model output ([#232](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/232))
* CLI: Update Detector Configurations ([#233](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/233))
* Add RestActions support Delete Detector API ([#238](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/238))
* Add RestActions support for Get Detector API ([#242](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/242))
* Add RestActions support Create/Update Detector API ([#243](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/243))
* Modify RestAction for Execute API ([#246](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/246))
* Add RestActions support for Start/Stop Detector API ([#244](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/244))
* Verify multi-entity detectors ([#240](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/240))
* Selectively store anomaly results when index pressure is high ([#241](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/241))
* Add User support for Detector and DetectorJob ([#251](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/251))
* Add support filtering the data by one categorical variable ([#270](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/270))
* Add User support for background job and API Transport Actions ([#272](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/272))
* Suppport HC detector in profile api ([#274](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/274))
* Auto flush checkpoint queue if too many are waiting ([#279](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/279))
* Rename all Actions to distinguish between internal and external facing ([#284](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/284))
* Add new Search Detector Info API ([#286](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/286))
* Update Search Detector API to reject all other queries other than BoolQuery ([#288](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/288))
* Add detector to Create/Update detector response ([#289](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/289))
* Set user as nested type to support exists query ([#291](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/291))


### Anomaly Detection Kibana Plugin
* Add category field to edit model configuration page ([#310](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/310))
* Switch direct index query to api call ([#312](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/312))
* Add the order for the plugin placement in revised kibana side menu ([#315](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/315))
* Clear model configuration if detector index is changed ([#319](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/319))
* Show user friendly message when permission error arises ([#320](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/320))
* Wording change for preview page in case of no anomalies ([#321](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/321))
* Query anomaly only for HC detector ([#322](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/322))
* Add match and count APIs ([#324](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/324))


### Index Management
* Actionify remove policy API ([#293](https://github.com/opendistro-for-elasticsearch/index-management/pull/293))
* Actionify add policy API ([#298](https://github.com/opendistro-for-elasticsearch/index-management/pull/298))
* Actionify retry API ([#302](https://github.com/opendistro-for-elasticsearch/index-management/pull/302))
* Actionify change policy API ([#303](https://github.com/opendistro-for-elasticsearch/index-management/pull/303))
* Actionify explain API ([#304](https://github.com/opendistro-for-elasticsearch/index-management/pull/304))
* Actionify index policy action ([#305](https://github.com/opendistro-for-elasticsearch/index-management/pull/305))
* Actionify get policy API ([#307](https://github.com/opendistro-for-elasticsearch/index-management/pull/307))
* Actionify delete policy API ([#308](https://github.com/opendistro-for-elasticsearch/index-management/pull/308))


### Job Scheduler
* Make schedule interface writeable ([#72](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/72))


### Kibana Notebooks
* Update dependency package version ([#44](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/44))
* Update prismjs dependency, increase cypress delay ([#47](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/47))


### k-NN
* Add existsQuery method implementation to KNNVectorFieldType ([#228](https://github.com/opendistro-for-elasticsearch/k-NN/pull/228))
* Change "space" parameter to "space_type" for custom scoring ([#232](https://github.com/opendistro-for-elasticsearch/k-NN/pull/232))
* Change space -> space_type ([#234](https://github.com/opendistro-for-elasticsearch/k-NN/pull/234))
* Add stats for custom scoring feature ([#233](https://github.com/opendistro-for-elasticsearch/k-NN/pull/233))


### Performance Analyzer
* Update threadpool metric collector to use reflection to read queue capacity([#210](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/210))
* Add the support to proxy the call over to the _agent for actions API([#215](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/215))


### Release Engineering
* Add startupProbe in Helm charts, thanks @madeleine666 ([#415](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/415))
* Add Kibana pods annotations in Helm charts, thanks @rexbut ([#404](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/404))
* Add Kibana extra volumes in Helm charts, thanks @rexbut ([#419](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/419))
* Add Kibana extra containers field in Helm charts, thanks @rexbut ([#420](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/420))
* Add Elasticsearch Master extra containers field in Helm charts, thanks @rexbut ([#438](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/438))


### Security
* Restrict configured indices access to adminDn only. [#690](https://github.com/opendistro-for-elasticsearch/security/pull/690)


### Security Kibana Plugin
* Add AD permissions to the permission list ([#538](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/538))
* Add Alerting permissions to the permission list ([#532](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/532))


### SQL
* Support describe index alias ([#775](https://github.com/opendistro-for-elasticsearch/sql/pull/775))
* Restyle workbench SQL/PPL UI ([#781](https://github.com/opendistro-for-elasticsearch/sql/pull/781))
* UI separate SQL and PPL pages ([#761](https://github.com/opendistro-for-elasticsearch/sql/pull/761))


## BUG FIXES

### Alerting
* Fix socket timeout exception, moved authuser to transport handler, moved User to commons ([#266](https://github.com/opendistro-for-elasticsearch/alerting/pull/266))
* Misc fixes for 1.11 release ([#274](https://github.com/opendistro-for-elasticsearch/alerting/pull/274))
* Fix parsing User info when User is null ([#279](https://github.com/opendistro-for-elasticsearch/alerting/pull/279))


### Alerting Kibana Plugin
* Fix email sender name validation and add tests related to email destination ([#189](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/189))


### Anomaly Detection
* Fix nested field issue ([#277](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/277))
* Upgrade mapping ([#278](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/278))
* Fix issue where max number of multi-entity detector doesn't work for UpdateDetector ([#285](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/285))
* Fix for stats API ([#287](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/287))
* Fix for get detector API ([#290](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/290))


### k-NN
* KNN score fix for non knn documents ([#231](https://github.com/opendistro-for-elasticsearch/k-NN/pull/231))
* Fix script statistics flaky test case ([#235](https://github.com/opendistro-for-elasticsearch/k-NN/pull/235))
* Refactor KNNVectorFieldMapper ([#240](https://github.com/opendistro-for-elasticsearch/k-NN/pull/240))
* Fix PostingsFormat in KNN Codec ([#236](https://github.com/opendistro-for-elasticsearch/k-NN/pull/236))


### Performance Analyzer
* Remove addition of new tests ([#202](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/202))


### Security
* Fix IllegalStateException that is raised when AuditLogImpl.close() is called from ES Bootstrap shutdown hook. [#764](https://github.com/opendistro-for-elasticsearch/security/pull/764)
* Initialize opendistro_role to null in ConfigV6.Kibana and ConfigV7.Kibana so the default value is not persisted in the open distro security config index. [#740](https://github.com/opendistro-for-elasticsearch/security/pull/740)
* Removing newline whitespace from metadata content [#734](https://github.com/opendistro-for-elasticsearch/security/pull/734)


### Security Kibana Plugin
* Fix button overflow on narrow window ([#539](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/539))
* Fix basepath related redirection problems in SAML auth workflow  ([#535](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/535))
* Allow users to add arbitrary permission on UI ([#533](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/533))


### SQL
* Fix bug, support multiple aggregation ([#771](https://github.com/opendistro-for-elasticsearch/sql/pull/771))
* Fix cast statement in aggregate function return 0 ([#773](https://github.com/opendistro-for-elasticsearch/sql/pull/773))
* Bug fix, using Local.Root when format the string ([#767](https://github.com/opendistro-for-elasticsearch/sql/pull/767))
* Bug fix, order by doesn't work when group by field has alias ([#766](https://github.com/opendistro-for-elasticsearch/sql/pull/766))
* Bug fix, using matcher to compare the Json result ([#762](https://github.com/opendistro-for-elasticsearch/sql/pull/762))


## INFRASTRUCTURE

### Alerting
* Add tests related to email destination ([#258](https://github.com/opendistro-for-elasticsearch/alerting/pull/258))
* Minor change to a unit test ([#261](https://github.com/opendistro-for-elasticsearch/alerting/pull/261))
* Fix integ tests when security is not installed ([#278](https://github.com/opendistro-for-elasticsearch/alerting/pull/278)) 


### Anomaly Detection
* Ignore flaky test ([#255](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/255))
* Add common-utils dependency from Maven ([#280](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/280))
* Fix build issue of common util ([#281](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/281))
* Exclude IndexAnomalyDetectorResponse from Jacoco to unblock build ([#292](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/292))


### Kibana Notebooks
* Revert S3 release bucket ([#41](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/41))
* Add unit tests, config for babel/jest and package json ([#36](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/36))


### Performance Analyzer
* Add integration test for the /override API ([#195](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/195))


### SQL
* Enforce 100% branch coverage for sql and es module ([#774](https://github.com/opendistro-for-elasticsearch/sql/pull/774))


## DOCUMENTATION

### Alerting
* Better link for documentation ([#265](https://github.com/opendistro-for-elasticsearch/alerting/pull/265))


### Anomaly Detection
* CLI: Update Display Strings ([#231](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/231))
* Add release notes for 1.11.0.0 ([#276](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/276))


### Anomaly Detection Kibana Plugin
* Add release notes for 1.11.0.0 ([#318](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/318))


### Kibana Notebooks
* Merge latest documents to migrated-7.9.0 branch ([#38](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/38))
* Documentation update - "Usage, API, Example notebooks, README gif" ([#37](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/37))
* Update workflow documentation, fixed link to POC ([#33](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/33))
* Update docs and adding Zeppelin Patch PoC ([#30](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/30))
* Add new RFC, supporting docs and images ([#29](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/29))
* README typo fix -> RFC document ([#22](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/22))
* Update Kibana-Notebooks-Design-Proposal.md ([#21](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/21))
* Modify design doc [new Architecture, Requirements and Design Details] ([#20](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/20))
* Add RFC doc and linking in README  ([#16](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/16))


### Performance Analyzer
* Fix download and doc link in the package description ([#198](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/198))


## MAINTENANCE

### Alerting
* Add support for Elasticsearch 7.9.1 ([#251](https://github.com/opendistro-for-elasticsearch/alerting/pull/251))


### Anomaly Detection
* Upgrade rcf libaries ([#239](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/239))
* Bump AD plugin version to 1.11.0.0 ([#275](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/275))


### Anomaly Detection Kibana Plugin
* Bump AD Kibana plugin version to 1.11.0.0 ([#317](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/317))
* Fix failed e2e tests ([#323](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/323))
* Fix broken UT when doing duplicate name validation ([#325](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/325))


### Index Management Kibana Plugin
* Changes for kibana side menu ([#131](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/131))


### Job Scheduler
* Bump Job Scheduler version to 1.11.0.0 ([#79](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/79))


### Performance Analyzer
* Enable RCA framework by default ([#209](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/209))


### Security
* Enable alerting in demo config for plugins security and default alerting roles [#768](https://github.com/opendistro-for-elasticsearch/security/pull/768)
* Generate SHA-512 checksum for opendistro_security .zip only (exclude securityadmin-standalone) [#753](https://github.com/opendistro-for-elasticsearch/security/pull/753)
* Consolidate writeable resource validation check [#752](https://github.com/opendistro-for-elasticsearch/security/pull/752)
* Exclude jakarta.activation-api library from CXF transient dependencies to avoid conflict with jakarata.activation. [#751](https://github.com/opendistro-for-elasticsearch/security/pull/751)
* Upgrade Apache CXF to 3.4.0 [#717](https://github.com/opendistro-for-elasticsearch/security/pull/717)


## REFACTORING

### Alerting
* Rename actions ([#256](https://github.com/opendistro-for-elasticsearch/alerting/pull/256))


### Alerting Kibana Plugin
* Add the order for the plugin placement in kibana side menu ([#195](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/195))


### SQL
* sql-workbench Kibana plugin [renamed to 'query-workbench'](https://opendistro.github.io/for-elasticsearch-docs/docs/upgrade/1-11.0/) ([#736](https://github.com/opendistro-for-elasticsearch/sql/pull/736))

You can also track upcoming features in Open Distro for Elasticsearch by watching the code repositories or checking the [project roadmap](https://github.com/orgs/opendistro-for-elasticsearch/projects/3).
