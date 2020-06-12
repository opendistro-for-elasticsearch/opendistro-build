# Open Distro for Elasticsearch 1.8.0 Release Notes

Open Distro for Elasticsearch 1.8.0 is now available for [download](https://opendistro.github.io/for-elasticsearch/downloads.html).

The release consists of Apache 2 licensed Elasticsearch version 7.7.0, and Kibana version 7.7.0. Plugins in the distribution include alerting, index management, performance analyzer, security, SQL, and machine learning with k-NN and anomaly detection. SQL JDBC/ODBC driver, SQL CLI Client, and PerfTop, a client for Performance Analyzer are also available for download.


## Release Highlights

* The [snapshot](https://github.com/opendistro-for-elasticsearch/index-management/pull/135) feature is now available in the Index Management plugin. This feature allows users to recover from failure and migrate indices from one cluster to another. 
* Anomaly Detection plugin releases the new [count aggregation](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/169) feature to detect anomalies. 
* New feature [Cosine Similarity](https://github.com/opendistro-for-elasticsearch/k-NN/pull/90) is available for use in k-NN plugin.
* Support for connecting [PerfTop CLI](https://opendistro.github.io/for-elasticsearch/downloads.html#PerfTop), a client for Performance Analyzer to clusters with basic authentication.

## Release Details

The release includes the following features, enhancements, infrastructure and documentation updates, and bug fixes.

## Breaking Changes

* Artifact Name of Anomaly Detection Plugin for **_*DEB*_** and **_*RPM*_** distribution is updated from **opendistro-anomaly-detector** to **opendistro-anomaly-detection**. In order to reduce the impact of this change, we recommend removing the old **opendistro-anomaly-detector** plugin first with your package manager, before installing the upgraded **opendistro-anomaly-detection** ([Support Docs](https://opendistro.github.io/for-elasticsearch-docs/docs/upgrade/1-8-0/)).

## **Features**

### Alerting

* Adds support for Elasticsearch 7.7.0 ([#205](https://github.com/opendistro-for-elasticsearch/alerting/pull/205))

### Anomaly Detection

* Add settings to disable/enable AD dynamically ([#105](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/105)) ([#127](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/127))

### Anomaly Detection Kibana

* Support count aggregation ([#169](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/169))

### Index Management

* Snapshot implementation ([#135](https://github.com/opendistro-for-elasticsearch/index-management/pull/135))

### Index Management Kibana

* Adds support for Kibana 7.7.0 ([#90](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/90))

### K-NN

* Support cosine similarity ([#90](https://github.com/opendistro-for-elasticsearch/k-NN/pull/90))

### Perftop

* Support connecting to clusters with basic-auth ([#35](https://github.com/opendistro-for-elasticsearch/perftop/pull/35)) (contribution from [@keety](https://github.com/keety))

### SQL ODBC

*  Add Tableau connector source files ([#81](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/82))

### SQL Workbench

* Update release notes and contributors for v1.8 ([#68](https://github.com/opendistro-for-elasticsearch/sql-workbench/pull/68))
* Update README.md ([#71](https://github.com/opendistro-for-elasticsearch/sql-workbench/pull/71))
* Rename plugin name to sql-workbench ([#72](https://github.com/opendistro-for-elasticsearch/sql-workbench/pull/72))

## **Enhancements**

### Anomaly Detection

* Add shingle size, total model size, and model's hash ring to profile API ([#128](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/128))
* Prevent creating detector with duplicate name. ([#134](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/134))

### Anomaly Detection Kibana

* Make callout message more readable when error creating new detector ([#130](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/130))
* Add loading state for live chart on detector details page ([#131](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/131))
* Add intermediate loading state when changing filters on detector list page ([#134](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/134))
* Tune code style for AD result utils ([#152](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/152))
* Test find max anomaly method's performance ([#158](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/158))
* Handle unexpected failure and unknown detector state edge cases ([#165](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/165))
* Improve error handling on detector detail pages ([#173](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/173))
* Add proper message in case of long initialization ([#159](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/159))
* Improve wording for different detector state messages ([#184](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/184))

### K-NN

* Block k-NN index writes if the Circuit breaker triggers. ([#108](https://github.com/opendistro-for-elasticsearch/k-NN/pull/108))

### Security

* Implemented migration and validation APIs for version upgrade ([#454](https://github.com/opendistro-for-elasticsearch/security/pull/454))

### SQL

* Add the field type conflict check in semantic check ([#470](https://github.com/opendistro-for-elasticsearch/sql/pull/470))

## **Bug fixes**

### Alerting Kibana

* Fixes wrong time interval unit for monitor on top of anomaly detector. ([#145](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/145))

### Anomaly Detection

* Fix that AD job cannot be terminated due to missing training data ([#126](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/126))
* Fix incorrect detector count in stats APIs ([#129](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/129))
* Fix dynamic setting of max detector/feature limit ([#130](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/130))

### Anomaly Detection Kibana

* Fix blank page if opening configuration page directly with URL ([#154](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/154))
* Fix detector detail loading state ([#155](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/155))
* Change to default plugin icon ([#175](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/175))
* Fix detector list infinite loading state on cluster initialization ([#177](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/177))
* Fix custom icon scaling issue ([#178](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/178))
* Fix anomaly results table pagination ([#180](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/180))

### Security Kibana

* Fix custom icon scaling issue ([#205](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/205))

### SQL

* Correct the column when SELECT function as field ([#462](https://github.com/opendistro-for-elasticsearch/sql/pull/462))

## **Infra Updates**

### Anomaly Detection

* Add CI/CD workflows ([#133](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/133))
* Use spotless to manage license headers and imports ([#136](https://github.com/opendistro-for-elasticsearch/anomaly-detection/pull/136))

### Anomaly Detection Kibana

* Remove unused language_tools import ([#171](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/171))
* Add CD GitHub action ([#183](https://github.com/opendistro-for-elasticsearch/anomaly-detection-kibana-plugin/pull/183))

### SQL JDBC Driver

* Adds workflow to upload jar to maven ([#81](https://github.com/opendistro-for-elasticsearch/sql-jdbc/pull/81))

## Documentation Updates

### SQL ODBC

* Add supported OS versions ([#88](https://github.com/opendistro-for-elasticsearch/sql-odbc/pull/88))

## Maintenance

### Security

* Jackson-databind version bump ([#406](https://github.com/opendistro-for-elasticsearch/security/pull/406))

## **In development**

1. [Performance Analyzer RCA Engine](https://github.com/opendistro-for-elasticsearch/performance-analyzer-rca)

You can also track upcoming features in Open Distro for Elasticsearch by watching the code repositories or checking the [project website](https://opendistro.github.io/for-elasticsearch/features/comingsoon.html).


