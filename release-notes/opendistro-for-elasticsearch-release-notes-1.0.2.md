## Open Distro for Elasticsearch 1.0.2 Release Notes

### **SECURITY**

* [Security Kibana UI](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin)
    * Update action group schema to add allowed_actions and remove permissions. ([#50](https://github.com/opendistro-for-elasticsearch/security-kibana-plugin/pull/50))

* [Security](https://github.com/opendistro-for-elasticsearch/security/)
    * Introduce roles in security plugin which will be consumed by the Alerting plugin ([#93](https://github.com/opendistro-for-elasticsearch/security/pull/93))

    * Add kibana_read_only and security_rest_api_access roles in roles.yml for 1.x version to keep it backward compatible with 0.x versions. ([#96](https://github.com/opendistro-for-elasticsearch/security/pull/96))

* [Security Advanced Modules](https://github.com/opendistro-for-elasticsearch/security-advanced-modules)
    * No changes

* [Security SSL](https://github.com/opendistro-for-elasticsearch/security-ssl)
    * No changes

* [Security Parent](https://github.com/opendistro-for-elasticsearch/security-parent)
    * No changes
