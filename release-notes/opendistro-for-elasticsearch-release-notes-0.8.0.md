## Open Distro for Elasticsearch 0.8.0 Release Notes

All plug-ins now support for Elasticsearch and Kibana version 6.6.2.

### **Alerting**

* Upgrade to latest Kotlin version - [PR #7](https://github.com/opendistro-for-elasticsearch/alerting/pull/7)
* Fixed task name in build instructions - [PR #12](https://github.com/opendistro-for-elasticsearch/alerting/pull/12)
* Fixed sorting on Destination Type on destinations list page.

### **SQL**

* Fix issue for query by index pattern in JDBC driver - [PR #9](https://github.com/opendistro-for-elasticsearch/sql/issues/9):
* Return friendly error message instead of NPE for illegal query and other exception cases - [PR #10](https://github.com/opendistro-for-elasticsearch/sql/issues/10):

### **Performance Analyzer**
* Better measurement granularity for Master Metrics - [PR #16](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/16)
* Bad File Descriptor Fix: Close not handled properly on sun.tools.attach.VirtualMachineImpl$SocketInputStream - [PR #20](https://github.com/opendistro-for-elasticsearch/performance-analyzer/pull/20)
