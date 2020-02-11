## Open Distro for Elasticsearch 1.1.0 Release Notes

### **ALERTING KIBANA UI**

* Fix update monitor from monitor list ([#64](https://github.com/opendistro-for-elasticsearch/alerting-kibana-plugin/pull/64))

### **PERFORMANCE ANALYZER**

* Fix MasterMetricsError and Mac unit tests ([#60](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/60))
* [Reorder](https://github.com/opendistro-for-elasticsearch/performance-analyzer/commit/0925de9fb71d098a117d3c078f732c8b17b9f4a3) imports, refactor unit tests
* [Fix](https://github.com/opendistro-for-elasticsearch/performance-analyzer/commit/1353f1a9bb69fcbd6be7f15ee17bd6d0a1b7acdc) running unit tests on Mac by modifying the metrics location
* [Fix](https://github.com/opendistro-for-elasticsearch/performance-analyzer/commit/8d424267a25e41788a73c4db926b443f05c4eee1) NullPointerException when PA starts collecting metrics

### **PERFTOP**

* [Fix](https://github.com/opendistro-for-elasticsearch/perftop/commit/67a2c432bd3e6460af8e505ff820589f7f2c56b4) vulnerabilities
* [Fix](https://github.com/opendistro-for-elasticsearch/perftop/commit/f3ff5323c0c0f0b56ce2b1a293f756c2e594a106) lodash ([#26](https://github.com/opendistro-for-elasticsearch/perftop/pull/26))

### **SECURITY**

* Add logging information for configuration error ([#79](https://github.com/opendistro-for-elasticsearch/security/pull/79))
* Revert #79 "add log information for configuration error" ([#80](https://github.com/opendistro-for-elasticsearch/security/pull/80))
* Add Predefined roles for alerting ([#88](https://github.com/opendistro-for-elasticsearch/security/pull/88) [#90](https://github.com/opendistro-for-elasticsearch/security/pull/90))
* Revert #88 “add predefined roles for alerting ([#91](https://github.com/opendistro-for-elasticsearch/security/pull/91))
* Add roles in security plugin which will be consumed by the Alerting plugin ([#93](https://github.com/opendistro-for-elasticsearch/security/pull/93))
* Add kibana_read_only and security_rest_api_access roles in roles.yml for 1.x version to keep it backward compatible with 0.x versions. ([#96](https://github.com/opendistro-for-elasticsearch/security/pull/96))

### **SECURITY KIBANA UI**

* Update action group schema to add allowed_actions and remove permissions. ([#50](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/50))
* Fix backend role button ([#)](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/commit/e75a83a1aacbe812af74a5c72018c80f4d98d2c7)
* Fix for multi-tenant migration issue: tenantinfo with InternalUser ([#52](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/52))
* Fix ace_aditor css scope to only apply kibana security plugin ([#60](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/60))
* Fixing typos in PR #52 ([#59](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/59))

### **SQL, SQL JBDC, ALERTING**

* No changes.
