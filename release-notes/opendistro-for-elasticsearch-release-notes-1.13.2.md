# Open Distro for Elasticsearch 1.13.2 Release Notes

## Release Highlights

## Release Details
Open Distro for Elasticsearch 1.13.2 includes the following features, bug fixes and maintenance updates.

## FEATURES

### Release Engineering
* Add ARM64 support for AMI ([#732](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/732))
* Enable Elasticsearch running as non-root without any extra capabilities or privileges. Thanks @timricese ([#703](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/703))
* Replace global.registry with global.imageRegistry. Thanks @yardenshoham ([#685](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/685))


## BUG FIXES

### Index Management
* Correcting rollup rewriting logic in field caps filter for cross cluster search and introducing a setting to prevent the rewrite if not desired. ([#422](https://github.com/opendistro-for-elasticsearch/index-management/pull/422))

### Release Engineering
* Make sure replicas matches in values.yaml and README. Thanks @yardenshoham ([#686](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/686))
* Indentation bug fix in values.yaml : Security Configuration. Thanks @mdiver ([#688](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/688))


## MAINTENANCE

### Index Management
* Bump version to 1.13.2.0 ([#427](https://github.com/opendistro-for-elasticsearch/index-management/pull/427))

### SQL
* Merge from Opendistro 1.13.2.0 into dev ([#1086](https://github.com/opendistro-for-elasticsearch/sql/pull/1086))

### Kibana Reports
* Merge from Opendistro 1.13.2.0 to dev ([#356](https://github.com/opendistro-for-elasticsearch/kibana-reports/pull/356))

### Kibana Notebooks
* Version bump to 1.13.2.0 ([#90](https://github.com/opendistro-for-elasticsearch/kibana-notebooks/pull/90))

### Trace Analytics
* Merge from Opendistro 1.13.2.0 alpha into main ([#30](https://github.com/opendistro-for-elasticsearch/trace-analytics/pull/30))


