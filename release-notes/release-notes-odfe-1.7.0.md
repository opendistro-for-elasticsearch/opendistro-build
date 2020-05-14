# Open Distro for Elasticsearch 1.7.0 Release Notes

Open Distro for Elasticsearch 1.7.0 is now available for [download](https://opendistro.github.io/for-elasticsearch/downloads.html).

The release consists of Apache 2 licensed Elasticsearch version 7.6.1, Kibana version 7.6.1, new plugins for anomaly detection and SQL Kibana, a SQL ODBC driver and SQL CLI client. Other plugins in the distribution include alerting, index management, performance analyzer, security, SQL and machine learning with k-NN. A SQL JDBC driver and PerfTop, a client for Performance Analyzer are also available for download.

## Release Highlights

* The [anomaly detection](https://github.com/opendistro-for-elasticsearch/anomaly-detection) plugin has moved out of the preview phase and is now generally available. It comes with a easy-to-use [Kibana](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin) user interface.
* The SQL plugin has greatly expanded its supported operations, added a new [Kibana](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin) user interface, and now has an interactive [CLI](https://github.com/opendistro-for-elasticsearch/sql-cli)with autocomplete.
* A new [SQL ODBC driver](https://github.com/opendistro-for-elasticsearch/sql-odbc) is also now available.
* A new package, the Open Distro for Elasticsearch 1.7.0 AMI, is now available for use with Amazon EC2. Search for “open distro” when you start a new instance.

## Release Details

The release includes the following features, enhancements, infrastructure and documentation updates, and bug fixes.

## Breaking Changes

### SQL

* Change [#414](https://github.com/opendistro-for-elasticsearch/sql/pull/414): Invalidate HTTP GET method.

## Features

### New!🔥 ANOMALY DETECTION

* Add state and error to profile API [(#84)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/84)
* Preview detector on the fly [(#72)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/72)
* Cancel query if given detector already have one [(#54)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/54)
* Support return AD job when get detector [(#50)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/50)
* Add AD job on top of Job Scheduler [(#44)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/44)
* Adding negative cache to throttle extra request [(#40)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/40)
* Add window delay support [(#24)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/24)
* Circuit breaker [(#10](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/10) [, #7)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/7)
* Stats collection [(#8)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/8)

### New!🔥 ANOMALY DETECTION KIBANA UI

* Add functionality to start & stop detector [PR #12](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/12)
* Add side navigation bar [PR #19](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/12)
* Add detector detail page [PR #20](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/20)
* Add functionality to get detector state [PR #16](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/16)
* Add dashboard page [PR #17](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/17)
* Add edit feature page [PR #52](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/52)
* Add detector configuration page [PR #22](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/22)
* Add anomaly results page [PR #62](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/62)
* Add detector state page [PR #65](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/65)
* Add anomaly charts [PR #50](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/50)

### SQL

* Simple Query Cursor support. ([#390](https://github.com/opendistro-for-elasticsearch/sql/pull/390))
* New SQL cluster settings endpoint ([#400)](https://github.com/opendistro-for-elasticsearch/sql/pull/400)
* Security Update: Escape comma for CSV header and all queries. ([#456](https://github.com/opendistro-for-elasticsearch/sql/pull/456))
* Security Update: Fix CSV injection issue. ([#447](https://github.com/opendistro-for-elasticsearch/sql/pull/447))
* Security Update: Anonymize sensitive data in queries exposed to RestSqlAction logs. ([#419](https://github.com/opendistro-for-elasticsearch/sql/pull/419))

### New!🔥 SQL CLI

* Feature [#12](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/12): Initial development for SQL CLI
    * prototype launch: app -> check connection -> take input -> query ES -> serve raw results(format=jdbc)
    * enrich auto-completion corpus
    * Convert to vertical output format if fields length is larger than terminal window
    * Add style to output fields name. Add logic to confirm choice from user for vertical output
    * Add single query without getting into console. Integrate "explain" api
    * Add config base logic. Add pagination for long output
    * Add nice little welcome banner.
    * Add params -f for format_output (jdbc/raw/csv), -v for vertical display
    * Initial implementation of connection to OD cluster and AES with auth
    * Create test module and write first test
    * Add fake test data. Add test utils to set up connection
    * [Test] Add pagination test and query test
    * Add Test plan and dependency list
    * [Test] Add test case for ConnectionFailExeption
    * [Feature] initial implementation of index suggestion during auto-completion
    * [Feature] display (data retrieved / total hits), and tell user to use "limit" to get more than 200 lines of data
    * Added legal and copyright files,
    * Added THIRD PARTY file
    * Added setup.py for packaging and releasing
* Feature [#24](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/24): Provide user option to toggle to use AWS sigV4 authentication (issue: [#23](https://github.com/opendistro-for-elasticsearch/sql-cli/issues/23))

### SQL JDBC Driver

* Cursor integration. ([#76](https://github.com/opendistro-for-elasticsearch/sql-jdbc/pull/76))

### New!🔥 SQL KIBANA UI

* Initialize SQL Kibana plugin ([#1](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/1))
* SQL Kibana plugin functionality implementation ([#2](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/2))
* Update plugin name and adjust dependency version ([#3](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/3))
* Added kibana plugin helper configuration ([#4](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/4))
* Adjust the service routes to call SQL plugin ([#5](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/5))
* Bumped up the version to support v7.3 compatibility ([#6](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/6))
* Updated configureation for v7.3 compatibility ([#7](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/7))
* Opendistro-1.3 compatible with ES and Kibana 7.3 ([#8](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/8))
* Changed kibana version to v7.3.2 ([#9](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/9))
* Support v7.1.1 Compatibility ([#13](v13))
* Bump pr-branch to v1.3 ([#21](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/21))
* Support v7.4 compatibility for kibana and sql-plugin ([#23](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/23))
* Improve the performance by ridding of sending redundant requests ([#24](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/24))
* Added raw format in download options ([#25](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/25))
* Update the release notes for the first official release ([#27](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/27))
* Updated test cases and snapshots ([#28](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/28))
* Initial merge from development branches to master ([#31](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/31))
* Support the result table to display results of DESCRIBE/SHOW/DELETE queries ([#37](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/37))
* Adjust the appearance of SQL Workbench UI ([#38](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/38))
* Migrated the default request format from Json to JDBC ([#41](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/41))
* Support v7.6.1 compatibility ([#42](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/42))
* Removed the overriding settings in css ([#44](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/44))
* Updated outdated dependencies ([#47](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/47))
* Updated open source code compliance ([#48](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/48))
* Opendistro Release v1.7.0 ([#56](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/56))
* Set up workflows for testing, building artifacts and releasing ([#58](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/58))
* Update copyright from year 2019 to 2020 ([#59](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/59))
* Moved release notes to dedicated folder ([#60](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/60))
* Added contributors file ([#61](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/61))
* Updated lastest yarn.lock for accurate dependency alert ([#62](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/62))
* Updated snapshot ([#63](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/63))

### New!🔥 SQL ODBC Driver

* Add support for connection string abbreviations ([#7)](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/7)
* Connection string refactoring and registry updates ([#2](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/2))
* Simple Windows Installer ([#27)](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/27)
* Add fetch_size for pagination support ([#78)](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/78)

### INDEX STATE MANAGEMENT

* Adds rollover conditions into info object [(#208)](https://github.com/opendistro-for-elasticsearch/index-management/pull/208)

### K-NN

* Support cosine similarity ([#90](https://github.com/opendistro-for-elasticsearch/k-NN/pull/90)). Note: This is an experimental feature.

## Enhancements

### ALERTING KIBANA UI

* Creates monitor with anomaly detector. - [(#123)](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/123)

### New!🔥 ANOMALY DETECTION

* Stats API: moved detector count call outside transport layer and make asynchronous [PR #108](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/108)
* Change AD result index rollover setting [PR #100](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/100)
* Add async maintenance [PR #94](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/94)
* Add async stopModel [PR #93](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/93)
* Add timestamp to async putModelCheckpoint [PR #92](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/92)
* Add async clear [PR #91](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/91)
* Use callbacks and bug fix [PR #83](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/83)
* Add async trainModel [PR #81](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/81)
* Add async getColdStartData [PR #80](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/80)
* Change the default value of lastUpdateTime [PR #77](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/77)
* Add async getThresholdingResult [PR #70](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/70)
* Add async getRcfResult [PR #69](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/69)
* Fix rcf random seed in preview [PR #68](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/68)
* Fix empty preview result due to insufficient sample [PR #65](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/65)
* Add async CheckpointDao methods. [PR #62](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/62)
* Record error and execution start/end time in AD result; handle except… [PR #59](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/59)
* Improve log message when we cannot get anomaly result [PR #58](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/58)
* Write detection code path in callbacks [PR #48](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/48)
* Send back error response when failing to stop detector [PR #45](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/45)
* Adjust preview configuration for more data [PR #39](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/39)
* Refactor using ClientUtil [PR #32](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/32)
* Return empty preview results on failure [PR #31](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/31)
* Allow non-negative window delay [PR #30](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/30)
* Return no data error message to preview [PR #29](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/29)
* Change AD setting name [PR #26](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/26)
* Add async CheckpointDao methods. [PR #17](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/17)
* Add async implementation of getFeaturesForSampledPeriods. [PR #16](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/16)
* Add async implementation of getFeaturesForPeriod. [PR #15](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/15)
* Add test evaluating anomaly results [PR #13](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/13)

### New!🔥 ANOMALY DETECTION KIBANA UI

* Add window delay [PR #4](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/4)
* Add empty dashboard page [PR #9](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/9)
* Update create/edit detector page [PR #13](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/13)
* Add search monitor API [PR #18](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/18)
* Add detector state support on dashboard [PR #28](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/28)
* Fix dark mode readability on detector list page [PR #39](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/39)
* Fix live anomaly chart time range [PR #45](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/45)
* Make breadcrumbs consistent on home pages [PR #41](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/41)
* Modify detector list tooltips [PR #47](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/47)
* Change chart style [PR #45](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/45)
* Add feature required detector state [PR #48](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/48)
* Remove old preview detector code [PR #51](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/51)
* Change live anomaly chart height [PR #45](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/45)
* Add live anomaly reducer [PR #55](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/55)
* Modify logic to delete detector [PR #54](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/54)
* Add chart and ad result .css file [PR #64](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/64)
* Make titles with counts consistent [PR #74](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/74)
* Avoid label cutoff on sunburst chart [PR #83](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/83)
* Remove tooltip icon on detector list page [PR #93](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/93)
* Modify some wording [PR #95](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/95)
* Change create detector link on dashboard [PR #100](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/100)
* Tune AD result charts [PR #102](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/102)
* Use annotation for live chart [PR #119](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/119)
* Set fixed height for anomalies live chart [PR #123](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/123)
* Use scientific notation when number less than 0.01 on live chart [PR #124](https://github.com/opendistro-for-elasticsearchanomaly-detection-kibana-plugin/pull/124)
* Use bucket aggregation for anomaly distribution [PR #126](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/126)

### INDEX STATE MANAGEMENT

* Adds isIdempotent method to each step and updates ManagedIndexRunner to use it [(#165)](https://github.com/opendistro-for-elasticsearch/index-management/pull/165)
* Adds logs, fix for index creation date -1L, nullable checks [(#170)](https://github.com/opendistro-for-elasticsearch/index-management/pull/170)
* Update schema version for IndexManagementConfig mapping if available [(#198)](https://github.com/opendistro-for-elasticsearch/index-management/pull/198)
* Switches UpdateManagedIndexMetaData to batch tasks using custom executor [(#209)](https://github.com/opendistro-for-elasticsearch/index-management/pull/209)

### K-NN

* Add stats to track the number of requests and errors for KNN query and index operations. ([#89](https://github.com/opendistro-for-elasticsearch/k-NN/pull/89))
* Switched the default value of the circuit breaker from 60% to 50%. ([#92](https://github.com/opendistro-for-elasticsearch/k-NN/pull/92))

### New!🔥SQL CLI

* Added github action workflow for CI/CD ([#31](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/31))
* Update github action test and build workflow to spin up ES instance ([#35)](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/35)

## Bug fixes

### New!🔥ANOMALY DETECTION

* Change setting name so that rpm/deb has the same name as zip [PR #109](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/109)
* Can't start AD job if detector has no feature [PR #76](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/76)
* Fix null pointer exception during preview [PR #74](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/74)
* Add threadpool prefix and change threadpool name [PR #56](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/56)
* Change setting name and fix stop AD request [PR #41](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/41)
* Revert "merge changes from alpha branch: change setting name and fix … [PR #38](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/38)
* Fix stop detector api to use correct request [PR #25](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/25)

### New!🔥ANOMALY DETECTION KIBANA UI

* Fix dashboard width [PR #29](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/29)
* Fix dashboard bugs [PR #35](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/35)
* Fix detector list bugs [PR #43](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/43)
* Fix more dashboard bugs [PR #45](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/45)
* Minor fix [PR #45](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/45)
* Return correct AD result [PR #57](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/57)
* Set max monitor size [PR #59](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/59)
* Fix more dashboard bugs [PR #61](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/61)
* Fix bugs on detector configuration page [PR #66](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/66)
* Fix bugs on create/edit detector page [PR #67](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/67)
* Fix blank anomaly results bug [PR #69](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/69)
* Fix link to detector configuration page [PR #71](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/71)
* Fix thin bar on anomaly results live chart [PR #70](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/70)
* Fix sunburst chart undefined issue [PR #73](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/73)
* Fix chart colors [PR #76](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/76)
* Don't display legend value on chartt [PR #79](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/79)
* Fix legend value bug on dashboard live chart [PR #80](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/80)
* Fix typo and change save feature button title [PR #81](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/81)
* Fix feature breakdown tabs [PR #84](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/84)
* Fix stats on dashboard live chart to not be wrapped [PR #82](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/82)
* Fix column truncation on detector list [PR #86](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/86)
* Fix issue that 0 cannot be set in detector filter [PR #68](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/68)
* Add -kibana suffix in links to prevent broken links [PR #92](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/92)
* Fix bug where latest anomalous detector can get lost [PR #98](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/98)
* Fix detector initializing message [PR #106](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/106)
* Fix preview detector error message [PR #108](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/108)
* Cover more detector state edge cases [PR #110](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/110)
* Fix 2 issues related to detector state [PR #111](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/111)
* Fix blank detector detail page [PR #112](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/112)
* Fix issue of not resetting to first page after applying filters [PR #115](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/115)
* Fix issue when live chart pulls anomaly results [PR #113](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/113)
* Fix live chart bar width problem [PR #116](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/116)
* Fix unnecessary filter when getting single anomaly result [PR #118](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/118)
* Fix live chart bar height [PR #121](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/121)
* Fix live chart time range [PR #122](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/122)
* Fix more live chart bugs [PR #125](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/125)
* Fix loading bug on live chart [PR #129](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/129)

### INDEX STATE MANAGEMENT

* Delete and close failing during snapshot in progress [(#172)](https://github.com/opendistro-for-elasticsearch/index-management/pull/172)

### K-NN

* Added validation in VectorFieldMapper to check for vector values of NaN and throwing an Exception if so. ([#100)](https://github.com/opendistro-for-elasticsearch/k-NN/pull/100)
* Fix debugging integration tests ([#78)](https://github.com/opendistro-for-elasticsearch/k-NN/pull/78)

### SECURITY

* Implemented APIs and datamodel to configure nodes_dn dynamically #[445](https://github.com/opendistro-for-elasticsearch/security/pull/445) (backported from master #[362](https://github.com/opendistro-for-elasticsearch/security/pull/362))
* Performance improvement by memorizing results of resolveIndexPatterns for Bulk requests (backported from master #[309](https://github.com/opendistro-for-elasticsearch/security/pull/309))
* Performance improvement by implementing faster version of implies type perm (#[302)](https://github.com/opendistro-for-elasticsearch/security/pull/302)
* Enabled limited OpenSSL support
* Changed file permissions for securityconfig and tools (#[387)](https://github.com/opendistro-for-elasticsearch/security/pull/387)
* Fixed bug which caused user to lose roles on account password update (#[333)](https://github.com/opendistro-for-elasticsearch/security/pull/333)
* Refactored to use Greenrobot EventBus (#[445)](https://github.com/opendistro-for-elasticsearch/security/pull/445) (backported from master #[370](https://github.com/opendistro-for-elasticsearch/security/pull/370))
* Refactored Resolved class, dropped unused fields and simplified logic (backported from master #[310](https://github.com/opendistro-for-elasticsearch/security/pull/310))
* Refactored audit logging related classes (#[445)](https://github.com/opendistro-for-elasticsearch/security/pull/445) (backported from master #[303](https://github.com/opendistro-for-elasticsearch/security/pull/303), #[445](https://github.com/opendistro-for-elasticsearch/security/pull/445), #[306](https://github.com/opendistro-for-elasticsearch/security/pull/306), #[373](https://github.com/opendistro-for-elasticsearch/security/pull/373), #[368](https://github.com/opendistro-for-elasticsearch/security/pull/368))

### SQL

* Support using aggregation function in order by clause. ([#452](https://github.com/opendistro-for-elasticsearch/sql/pull/452))
* Count(distinct field) should translate to cardinality aggregation. ([#442](https://github.com/opendistro-for-elasticsearch/sql/pull/442))
* Enforce AVG return double data type. ([#437](https://github.com/opendistro-for-elasticsearch/sql/pull/437))
* Ignore the term query rewrite if there is no index found. ([#425](https://github.com/opendistro-for-elasticsearch/sql/pull/425))
* Support subquery in from doesn't have alias. ([#418](https://github.com/opendistro-for-elasticsearch/sql/pull/418))
* Add support for strict_date_optional_time. ([#412](https://github.com/opendistro-for-elasticsearch/sql/pull/412))
* Field function name letter case preserved in select with group by. ([#381](https://github.com/opendistro-for-elasticsearch/sql/pull/381))

### New!🔥SQL CLI

* Initial development for SQL CLI ([#12)](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/12)
    * Fix the logic of passing self-constructed settings
    * [Fix] get rid of unicode warning. Fix meta info display
    * [fix] Refactor executor code
    * [Fix] Fix test cases corresponding to fraction display.
    * [Fix] fix code style using Black, update documentation and comments
* Fix typos, remove unused dependencies, add .gitignore and legal file ([#18](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/18))
* Fix test failures ([#19](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/19))
* Update usage gif, fix http/https issue when connect to AWS Elasticsearch ([#26](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/26))

### New!🔥SQL KIBANA UI

* Fixed the issue that response failed to be delivered in the console ([#10](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/10))
* Fixed the issue that aggregation result not delivered in the table ([#26](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/26))
* Fixed the issue that the table remains delivering the cached results table from the last query ([#30](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/30))
* Fixed some dependency issues ([#36](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/36))
* Fixed: fatal errors occur when import @elastic/eui modules in docker images ([#43](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/43))
* BugFix: Corrected the downloaded .csv/.txt files to proper format ([#50](https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin/pull/50))

### New!🔥SQL ODBC Driver

* [Fix AWS authentication for Tableau on Mac](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/9)
* [Mac installer fixes](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/73)
* [Fix General installer components](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/69)

## Infra Updates

### New!🔥ANOMALY DETECTION

* Add release notes for ODFE 1.7.0 [(#120](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/120) [, #119)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/119)
* Open Distro Release 1.7.0 [(#106)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/106)
* Create opendistro-elasticsearch-anomaly-detection.release-notes.md [(#103)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/103)
* Update test branch [(#101)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/101)
* Bump opendistroVersion to 1.6.1 [(#99)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/99)
* Change to mention we support only JDK 13 [(#98)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/98)
* AD opendistro 1.6 support [(#87)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/87)
* Added URL for jb_scheduler-plugin_zip instead of local file path [(#82)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/82)
* Change build instruction for JDK [(#61)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/61)
* ODFE 1.4.0 [(#43)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/43)
* Add spotless for code format [(#22)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/22)
* Update third-party [(#14)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/14)
* Build artifacts for rpm, deb, zip [(#5)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/5)
* Update test-workflow.yml [(#2)](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/2)

### New!🔥ANOMALY DETECTION KIBANA UI

* Initial commit [here](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/commit/0e5ace28588d311ee9a632c4783ca3e06ad6b187)
* Fix unit test issue [PR #14](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/14)
* Update test snapshots [PR #44](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/44)
* Add unit test workflow [PR #42](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/42)
* Change workflow to run on pushes to master [PR #72](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/72)
* Change default build artifact name [PR #89](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/89)
* Fix test workflow [PR #104](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/104)

### K-NN

* Create Github action that automatically runs integration tests against docker image whenever code is checked into master or opendistro branch. ([#73](https://github.com/opendistro-for-elasticsearch/k-NN/pull/73))

### New!🔥SQL CLI

* Feature [#28](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/28) :Added tox scripts for testing automation

## Documentation Updates

### New!🔥ANOMALY DETECTION KIBANA UI

* Create CONTRIBUTORS [here](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/commit/603b9e7a8bff522bbfc7f841d8e61143aaff7a6d)
* Update README [here](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/commit/c1da0e52eb0bcb3beee23f642686661da634f7f4)
* Update README [here](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/commit/a9271e7c254ed6541135b7ef9823aac1357343e2)
* Update README [here](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/commit/cf231c238ec505223fe06d66ec02787a3d8cec59)
* Update CONTRIBUTORS [here](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/commit/9de0d8420b1408e5891f0ff50fe41636649b00ce)
* Update README [PR #88](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/88)
* Add release notes for ODFE 1.7.0 [PR #109](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/109)
* Modify ODFE 1.7.0 release notes [PR #132](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/132)

### SQL

* More docs in reference manual and add architecture doc. ([#417](https://github.com/opendistro-for-elasticsearch/sql/pull/417))

### New!🔥SQL CLI

* Update documentation and CLI naming ([#22](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/22))
* Update copyright to 2020 ([#32)](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/32)
* Updated package naming and created folder for release notes ([#33](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/33))
* Added CONTRIBUTORS.md ([#34](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/34))
* Polish README.md and test_plan.md ([#36](https://github.com/opendistro-for-elasticsearch/sql-cli/pull/36))

### New!🔥SQL ODBC Driver

* [Pagination support design document](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/40)
* [Update README for authentication & encryption configuration options](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/33)
* [Instructions for signing installers](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/84)

## In development

1. [Performance Analyzer RCA Engine](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca)

You can also track upcoming features in Open Distro for Elasticsearch by watching the code repositories or checking the [[project website](https://opendistro.github.io/for-elasticsearch/features/comingsoon.html)](https://opendistro.github.io/for-elasticsearch/features/comingsoon.html)
