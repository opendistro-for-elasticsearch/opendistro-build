## Open Distro for Elasticsearch 1.3.0 Release Notes

### **ALERTING**

* Update to OpenDistro Version 1.3 [(#125)](https://github.com/opendistro-for-elasticsearch/alerting/pull/125)
* Fix alerting stats API [(#129)](https://github.com/opendistro-for-elasticsearch/alerting/pull/129)
* Bump plugin version [(#131)](https://github.com/opendistro-for-elasticsearch/alerting/pull/131)

### **ALERTING KIBANA UI**

* Support Kibana 7.3.2 [(#109)](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/109)

### **PERFORMANCE ANALYZER**

* Update Performance Analyzer to support ElasticSearch version 7.3.2 [(#79)](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/79)

### **INDEX MANAGEMENT**

* Adds support for ES 7.3.2 [(#109)](https://github.com/opendistro-for-elasticsearch/index-management/pull/109)
* Adds release notes [(#111)](https://github.com/opendistro-for-elasticsearch/index-management/pull/111)
* Remove unused import [(#112)](https://github.com/opendistro-for-elasticsearch/index-management/pull/112)
* Rename rootProject.name [(#114)](https://github.com/opendistro-for-elasticsearch/index-management/pull/114)
* Cherry-pick bug fixes and bump plugin version [(#123)](https://github.com/opendistro-for-elasticsearch/index-management/pull/123)
* Adds null check in cluster changed event sweep [(#125)](https://github.com/opendistro-for-elasticsearch/index-management/pull/125), [(#126)](https://github.com/opendistro-for-elasticsearch/index-management/pull/126)

### **INDEX MANAGEMENT KIBANA UI**

* Adds support for Kibana 7.3.2 [(#63)](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/63)
* Adds release notes for first official supported version [(#64)](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/64)
* Updates README [(#65)](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/65)
* Fixes broken build artifact [(#69)](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/69)
* Bump plugin version [(#71)](https://github.com/opendistro-for-elasticsearch/index-management-kibana-plugin/pull/71)

### **SECURITY**

* 7.3 ([*](https://github.com/opendistro-for-elasticsearch/security/commit/1bef14d33689ccb57c0cb7bf1b9786c4040be3a0))
* 7.3 part 2 ([*](https://github.com/opendistro-for-elasticsearch/security/commit/c23e9e3c4db9d1f0e4fa5597e4eb3d1ce2fdf476))
* 7.3 part 3 ([*](https://github.com/opendistro-for-elasticsearch/security/commit/b77989eb7c172fa637bdabb3cf65cb80cff557d0))
* 7.3 part 4 ([*](https://github.com/opendistro-for-elasticsearch/security/commit/0a97746266b9e91a9b4a5e2578a0e107d80824f3))
* 7.3 part 5 ([*](https://github.com/opendistro-for-elasticsearch/security/commit/408372901f5a633f4b5b0afb936efd36e5de791d))
* 7.3 part 6 ([*](https://github.com/opendistro-for-elasticsearch/security/commit/762998ab4d5f105a4fe1156fb3965c63b6a11110))
* 7.3 part 7 ([*](https://github.com/opendistro-for-elasticsearch/security/commit/881a8f343238531399fe30fcb868706d64536265))
* Bumped jackson-databind from 2.9.9.2 to 2.9.10.1 ([*](https://github.com/opendistro-for-elasticsearch/security/commit/eaedbdfd2c8bd563a66297b7e4518dd7cd4fe7b4))

Committed changes include:

* Validate all config files before uploading them via securityadmin and make sure yaml parser does not tolerate duplicate keys
* Make built-in roles work with ILM, add built-in ILM action groups
* Fix built-in roles to work with xp monitoring when multi cluster monitoring is supported
* Add opendistro_security.unsupported.load_static_resources config property so that integrators can disable static resources
* Add ChaCha20 support for TLS 1.2
* Rename "roles" to "backend_roles" in user info/authinfo
* Update Bouncycastle dependency to 1.62
* Fix permissions for built-in logstash role to work with ILM
* Introduce opendistro_security_roles in internal_users.yml
* Fix index resolution for (*,-index) patterns, introduce opendistro_security.filter_securityindex_from_all_requests option
* Fixed when tenants not handled correctly when using impersonation
* Fix unit tests
* Revised logging code
* Simplify EmptyLeafReader
* Move DLS for search requests from DlsFlsFilterLeafReader to DlsFlsVavleImpl

### **SECURITY ADVANCED MODULES**

* ES 7.3 support and bug fixes ([*](https://github.com/opendistro-for-elasticsearch/security-advanced-modules/commit/4451d2c23efbdd72a998936162c00c9c5ebfb40c))
* Addtional changes for 7.3 and fix for internal user API ([*](https://github.com/opendistro-for-elasticsearch/security-advanced-modules/commit/9165c63576d55e19a3b788b6dd68a9e2ce0abab7))
* Fixes for 7.3 support ([*])
* Changes for ODFE 1.3 test [(*)](https://github.com/opendistro-for-elasticsearch/security-advanced-modules/commit/8d4f6929dd2f472a1e921e61db19d80fd9d9d276)
* Fixing typos in UTs [(*)](https://github.com/opendistro-for-elasticsearch/security-advanced-modules/commit/7f723d16b11e11839e43a73ac5d4b1ab2d90d2ef)
* Fixing UTs [(*)](https://github.com/opendistro-for-elasticsearch/security-advanced-modules/commit/7a54db00a7daf6b53b647538dee62fa1bf3eac0b)
* Bumped jackson-databind from 2.9.9.2 to 2.9.10.1 [(*)](https://github.com/opendistro-for-elasticsearch/security-advanced-modules/commit/25840f7b901fafaa4c7f9f70bb49f1ffdd0173ad)
* Updated security parent version and release notes [(*)](https://github.com/opendistro-for-elasticsearch/security-advanced-modules/commit/9fdfcdaf5a6e17064ffbe0f5e10e47d7846835e2)

### **SECURITY PARENT**

* 7.3 [(*)](https://github.com/opendistro-for-elasticsearch/security-parent/commit/90fd45a8ee321f3efdfef6aee36781122aae6341)
* 7.3 part 2 [(*)](https://github.com/opendistro-for-elasticsearch/security-parent/commit/8c184ad7b1db70179bfdbc1ca6e52baf7daff27d)
* 7.3 part 3 [(*)](https://github.com/opendistro-for-elasticsearch/security-parent/commit/899d4291d7e6a041052f57d8aede39b396a30fdb)

Committed changes include:

* Fixed leaked LDAP connection
* Use combine bitset for DLS
* Fixed FLS exists query on fields without norms and doc values
* Fixed field masking with aggregations
* Introduced MaskedTermsEnum to fix field anonymization with aggregations
* Added _seq_no and _primary_term to meta fields for FLS
* Fixed rest API validator to accept opendistro_secuirty_roles for internal users
* Exception handling for SAML IdP at startup
* Updated Jackson databind dependency to 2.9.9
* Updated Kafka client dependency to 2.0.1
* Fixed access control exception for ldap2
* Upgraded CXF to 2.3.9
* Bumped jackson-databind from 2.9.9.2 to 2.9.10.1
* Other minor fixes for detailed error logging

### **SECURITY KIBANA UI**

* Support for ES 7.3.2 [(#112)](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/112)
* Updating drop-down menu support for adding additional field (opendistro_security_roles) for internal user CRUD [(#116)](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/116)
* Fix cannot add new internal user without role issue [(#117)](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/117)

### **SQL**

* Support Cast() function [(#253)](https://github.com/opendistro-for-elasticsearch/sql/pull/253)
* Fixed operatorReplace Integration Test [(#267)](https://github.com/opendistro-for-elasticsearch/sql/pull/267)
* Fix the LOG function that delivered inaccurate result [(#265)](https://github.com/opendistro-for-elasticsearch/sql/pull/265)
* Support CASE statement in one more grammer [(#262)](https://github.com/opendistro-for-elasticsearch/sql/pull/262)
* Support string operators: ASCII, RTRIM, LTRIM, LOCATE, LENGTH, REPLACE [(#260)](https://github.com/opendistro-for-elasticsearch/sql/pull/260)

### **SQL JDBC**

* Updated for v1.3 release [(#31)](https://github.com/opendistro-for-elasticsearch/sql-jdbc/pull/31)

### **JOB SCHEDULER**

* Support ES 7.3 [(#29)](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/29)
* Converts lock service to async [(#28)](https://github.com/opendistro-for-elasticsearch/job-scheduler/pull/28)

### **PERFTOP**

* Created branch for open distro perftop 1.3 ([*](https://github.com/opendistro-for-elasticsearch/perftop/commit/a5579f79b0b5b4449e66811aa090cc89b8b388a4))
