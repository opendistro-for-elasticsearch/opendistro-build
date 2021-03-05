# Open Distro for Elasticsearch 1.13.1 Release Notes

## Release Highlights
Open Distro for Elasticsearch 1.13.0 was shipped without the Performance Analyzer active in TAR and Docker formats. Additionally, the security plugin included in 1.13.0 threw errors on _cat/health calls and introduced a performance regression when compared to 1.12.0. Version 1.13.1 was released on March 4th, 2021 to re-enable Performance Analyzer as well as resolve the error and the performance regression in the security plugin.

## Release Details
Open Distro for Elasticsearch 1.13.1 includes the following bug fixes and maintenance updates.

## BUG FIXES

### Security
* Fix for "java.lang.IllegalArgumentException: The array of keys must not be null" for "_cat/health" requests ([#1048](https://github.com/opendistro-for-elasticsearch/security/pull/1048))
* Revert "Fix AuthCredentials equality (#876)" to improve performance ([#1061](https://github.com/opendistro-for-elasticsearch/security/pull/1061))

### Release Engineering
* Bug fix for Performance Analyzer plugin in TAR and Docker ([#649](https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/649))


## MAINTENANCE

### Security
* Bump version to 1.13.1.0 ([#1054](https://github.com/opendistro-for-elasticsearch/security/pull/1054))
* Update release notes 1.13.1 ([#1063](https://github.com/opendistro-for-elasticsearch/security/pull/1063))

### Alerting
* Bump version to 1.13.1.0 ([#358](https://github.com/opendistro-for-elasticsearch/alerting/pull/358))

### Index Management
* Bump version to 1.13.1.0 ([#411](https://github.com/opendistro-for-elasticsearch/index-management/pull/411))


