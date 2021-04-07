<!---
Copyright 2019 Viasat, Inc.

Licensed under the Apache License, Version 2.0 (the "License").
You may not use this file except in compliance with the License.
A copy of the License is located at

    http://www.apache.org/licenses/LICENSE-2.0

or in the "license" file accompanying this file. This file is distributed
on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
express or implied. See the License for the specific language governing
permissions and limitations under the License.
-->

# Opendistro Elasticsearch
This chart installs [Opendistro Kibana](https://opendistro.github.io/for-elasticsearch-docs/docs/kibana/) + [Opendistro Elasticsearch](https://opendistro.github.io/for-elasticsearch-docs/docs/elasticsearch/) with configurable TLS, RBAC, and more.
Due to the uniqueness of different users environments, this chart aims to cater to a number of different use cases and setups.

## TL;DR
```
❯ helm package .
❯ helm install opendistro-es-1.13.2.tgz --name opendistro-es
```

## Installing the Chart
To install the chart with the release name `my-release`:

`❯ helm install --name my-release opendistro-es-1.13.2.tgz`

The command deploys OpenDistro Kibana and Elasticsearch with its associated components (data statefulsets, masters, clients) on the Kubernetes cluster in the default configuration.

## Uninstalling the Chart
To delete/uninstall the chart with the release name `my-release`:
```
❯ helm delete --name opendistro-es
```

### Notes About Default Installation
By default, on startup, opendistro will update the [default](https://github.com/opendistro-for-elasticsearch/opendistro-build/blob/master/elasticsearch/docker/build/elasticsearch/elasticsearch.yml) `elasticsearch.yml` via the [install_demo_configuration.sh](https://github.com/opendistro-for-elasticsearch/security/blob/dfc41db0d0123cd0965d40ee47d61266e560f7e6/tools/install_demo_configuration.sh) to mirror the below and generate some [default certs](https://github.com/opendistro-for-elasticsearch/security/blob/dfc41db0d0123cd0965d40ee47d61266e560f7e6/tools/install_demo_configuration.sh#L201):
```
cluster.name: "docker-cluster"
network.host: 0.0.0.0

# minimum_master_nodes need to be explicitly set when bound on a public IP
# set to 1 to allow single node clusters
# Details: https://github.com/elastic/elasticsearch/pull/17288
discovery.zen.minimum_master_nodes: 1

######## Start OpenDistro for Elasticsearch Security Demo Configuration ########
# WARNING: revise all the lines below before you go into production
opendistro_security.ssl.transport.pemcert_filepath: esnode.pem
opendistro_security.ssl.transport.pemkey_filepath: esnode-key.pem
opendistro_security.ssl.transport.pemtrustedcas_filepath: root-ca.pem
opendistro_security.ssl.transport.enforce_hostname_verification: false
opendistro_security.ssl.http.enabled: true
opendistro_security.ssl.http.pemcert_filepath: esnode.pem
opendistro_security.ssl.http.pemkey_filepath: esnode-key.pem
opendistro_security.ssl.http.pemtrustedcas_filepath: root-ca.pem
opendistro_security.allow_unsafe_democertificates: true
opendistro_security.allow_default_init_securityindex: true
opendistro_security.authcz.admin_dn:
  - CN=kirk,OU=client,O=client,L=test, C=de

opendistro_security.audit.type: internal_elasticsearch
opendistro_security.enable_snapshot_restore_privilege: true
opendistro_security.check_snapshot_restore_write_privileges: true
opendistro_security.restapi.roles_enabled: ["all_access", "security_rest_api_access"]
cluster.routing.allocation.disk.threshold_enabled: false
node.max_local_storage_nodes: 3
######## End OpenDistro for Elasticsearch Security Demo Configuration ########
```

This will only be done if `opendistro_security` is [not found](https://github.com/opendistro-for-elasticsearch/security/blob/dfc41db0d0123cd0965d40ee47d61266e560f7e6/tools/install_demo_configuration.sh#L194) in the `elasticsearch.yml` file. With this in mind, it's important to note that as a user, providing a complete configuration to both `kibana.config` and `elasticsearch.config` is required when working with custom certs, secrets, etc.

### Notes About Using Custom Certs
***All*** keys must be in the PKCS#5 v1.5 format to  work with the jdk. See [this](https://aws.amazon.com/blogs/opensource/add-ssl-certificates-open-distro-for-elasticsearch/) amazon article for more information about creating and using custom certs with opendistro elasticsearch.

## Certs, Secrets, and Configuration
Prior to installation there are a number of secrets that can be defined that will get mounted into the
different elasticsearch/kibana components.

### Kibana

#### Kibana.yml Config
All values defined under `kibana.config` will be converted to yaml and mounted into the config directory.

#### Example Secure Kibana Config With Custom Certs
The below config requires the following secrets to be defined:

* `elasticsearch-account` - Elasticsearch account with a username, password, and cookie secret field to be expanded into`${ELASTICSEARCH_USERNAME}`, `${ELASTICSEARCH_PASSWORD}`, and `${COOKIE_PASS}` in `kibana.yml`
* `kibana-certs` - Kibana certs matching the form under [ssl](#ssl)
* `elasticsearch-rest-certs` - Elasticsearch rest certs matching the form under [ssl](#ssl)

With the above secrets, and the below config, deployment with custom signed certs is possible:
```
kibana:

  elasticsearchAccount:
    secret: elasticsearch-account

  ssl:
    kibana:
      enabled: true
      existingCertSecret: kibana-certs
    elasticsearch:
      enabled: true
      existingCertSecret: elasticsearch-rest-certs

  config:
    # Default Kibana configuration from kibana-docker.
    server.name: kibana
    server.host: "0"

    elasticsearch.hosts: https://elasticsearch.example.com:443
    elasticsearch.requestTimeout: 360000

    logging.verbose: true

    # Kibana TLS Config
    server.ssl.enabled: true
    server.ssl.key: /usr/share/kibana/certs/kibana-key.pem
    server.ssl.certificate: /usr/share/kibana/certs/kibana-crt.pem

    opendistro_security.cookie.secure: true
    opendistro_security.cookie.password: ${COOKIE_PASS}

    elasticsearch.username: ${ELASTICSEARCH_USERNAME}
    elasticsearch.password: ${ELASTICSEARCH_PASSWORD}

    opendistro_security.allow_client_certificates: true
    elasticsearch.ssl.certificate: /usr/share/kibana/certs/elk-rest-crt.pem
    elasticsearch.ssl.key: /usr/share/kibana/certs/elk-rest-key.pem
    elasticsearch.ssl.certificateAuthorities: ["/usr/share/kibana/certs/elk-rest-root-ca.pem"]

    # Multitenancy with global/private tenants disabled,
    # set to both to true if you want them to be available.
    opendistro_security.multitenancy.enabled: true
    opendistro_security.multitenancy.tenants.enable_private: false
    opendistro_security.multitenancy.tenants.enable_global: false
    opendistro_security.readonly_mode.roles: ["kibana_read_only"]
    elasticsearch.requestHeadersWhitelist: ["securitytenant","Authorization"]
    opendistro_security.allow_client_certificates: true
```

#### Elasticsearch Specific Secrets
Elasticsearch specific values passed in through the environment including `ELASTICSEARCH_USERNAME`, `ELASTICSEARCH_PASSWORD`,
`COOKIE_PASS`, and optionally a keypass phrase under `KEY_PASSPHRASE`.
```
elasticsearchAccount:
  secret: ""
  keyPassphrase:
    enabled: false
```

#### SSL
Optionally you can define ssl secrets for kibana as well as secrets for interactions between kibana and elasticsearch's rest clients:
```
ssl:
  kibana:
    enabled: true
    existingCertSecret: kibana-certs
  elasticsearch:
    enabled: true
    existingCertSecret: elasticsearch-rest-certs
```
The chart expects the `kibana.existingCertSecret` to have the following values:
```
---
apiVersion: v1
kind: Secret
metadata:
  name: kibana-certs
  namespace: desired_namespace
  labels:
    app: elasticsearch
data:
  kibana-crt.pem: base64value
  kibana-key.pem: base64value
  kibana-root-ca.pem: base64value
```
Similarly for the elasticsearch rest certs:
```
---
apiVersion: v1
kind: Secret
metadata:
  name: elasticsearch-rest-certs
  namespace: desired_namespace
  labels:
    app: elasticsearch
data:
  elk-rest-crt.pem: base64value
  elk-rest-key.pem: base64value
  elk-rest-root-ca.pem: base64value
```

### Elasticsearch

#### SSL
For Elasticsearch you can optionally define ssl secrets for elasticsearch transport, rest, and admin certs:

***NOTE:*** The manifests require the keys for the certs (e.g. `elk-transport-crt.pem`) to match up in order
to properly mount them to their corresponding `subPath`.
```
ssl:
  transport:
    existingCertSecret: elasticsearch-transport-certs
  rest:
    enabled: true
    existingCertSecret: elasticsearch-rest-certs
  admin:
    enabled: true
    existingCertSecret: elasticsearch-admin-certs

```
The transport certs are expected to be formatted in the following way:
```
---
apiVersion: v1
kind: Secret
metadata:
  name: elasticsearch-transport-certs
  namespace: desired_namespace
  labels:
    app: elasticsearch
data:
  elk-transport-crt.pem:
  elk-transport-key.pem:
  elk-transport-root-ca.pem:
```
The admin certs are expected to be formatted in the following way:
```
---
apiVersion: v1
kind: Secret
metadata:
  name: elasticsearch-admin-certs
  namespace: desired_namespace
  labels:
    app: elasticsearch
data:
  admin-crt.pem:
  admin-key.pem:
  admin-root-ca.pem:
```

#### Security Configuration
In an effort to avoid having to `exec` into the pod to configure the various security options see
[here](https://github.com/opendistro-for-elasticsearch/security/tree/master/securityconfig),
you can define secrets that map to each config given that each secret contains the matching file name:
```
securityConfig:
  enabled: true
  path: "/usr/share/elasticsearch/plugins/opendistro_security/securityconfig"
  actionGroupsSecret:
  configSecret:
  internalUsersSecret:
  rolesSecret:
  rolesMappingSecret:
```
Example:
```
❯ cat config.yml
_meta:
  type: "config"
  config_version: 2
config:
  dynamic:
    filtered_alias_mode: "warn"
    disable_rest_auth: false
    disable_intertransport_auth: false
    respect_request_indices_options: false
    license: null
    kibana:
      multitenancy_enabled: true
.......
❯ kubectl create secret generic -n logging security-config --from-file=config.yml
```
By coupling the above secrets with `opendistro_security.allow_default_init_securityindex: true` in your
`elasticsearch.config:` at startup all of the secrets will be mounted in and read.

or You can specify  all the security configurations in the values.yaml file  as
```
securityConfig:
  enabled: true
  path: "/usr/share/elasticsearch/plugins/opendistro_security/securityconfig"
  securityConfigSecret:
  data: {}
    # config.yml: |-
    # internal_users.yml: |-
    # roles.yml: |-
    # rolesMapping.yml: |-
    # tenants.yml: |-
```
Example:
```
config.yml: |-
  _meta:
    type: "config"
    config_version: 2
  config:
    dynamic:
      filtered_alias_mode: "warn"
      disable_rest_auth: false
      disable_intertransport_auth: false
      respect_request_indices_options: false
      license: null
      kibana:
        multitenancy_enabled: true
.......

```

Alternatively you can set `securityConfig.enabled` to `false` and `exec` into the container and make changes as you see fit using the instructions
[here](https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/elasticsearch.yml.example)

#### elasticsearch.yml Config
All values defined under `elasticsearch.config` will be converted to yaml and mounted into the config directory.
See example [here](https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/elasticsearch.yml.example)

#### Example Secure Elasticsearch Config With Custom Certs
The below config enables TLS with custom certs, sets up the admin certs, and configures
the [securityconfigs](https://github.com/opendistro-for-elasticsearch/security/tree/master/securityconfig) with custom entries.

The following secrets are required:
* `elasticsearch-rest-certs` - Elasticsearch rest certs matching the form under [ssl](#ssl)
* `elasticsearch-transport-certs` - Elasticsearch transport certs matching the form under [ssl](#ssl)
* `elasticsearch-admin-certs` - Elasticsearch admin certs matching the form under [ssl](#ssl)
* `configSecret` - [config.yml](https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/config.yml)
* `rolesSecret` - [roles.yml](https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/roles.yml)
* `rolesMappingSecret` - [roles_mapping.yml](https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/roles_mapping.yml)
* `internalUsersSecret` - [internal_users.yml](https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/internal_users.yml)
* `tenantsSecret` - [tenants.yml](https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/tenants.yml)
```
elasticsearch:

  ssl:
    transport:
      existingCertSecret: elasticsearch-transport-certs
    rest:
      enabled: true
      existingCertSecret: elasticsearch-rest-certs
    admin:
      enabled: true
      existingCertSecret: elasticsearch-admin-certs

  securityConfig:
    enabled: true
    path: "/usr/share/elasticsearch/plugins/opendistro_security/securityconfig"
    configSecret: "security-config"
    rolesSecret: "roles-config"
    rolesMappingSecret: "roles-mapping-config"
    internalUsersSecret: "internal-users-config"
    actionGroupsSecret: "action-groups-config"
    tenantsSecret: "tenants-config"


  config:
    # Majority of options described here: https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/elasticsearch.yml.example
    opendistro_security.audit.ignore_users: ["kibanaserver"]
    opendistro_security.allow_unsafe_democertificates: false
    # Set to false if running securityadmin.sh manually following deployment
    opendistro_security.allow_default_init_securityindex: true
    # See: https://opendistro.github.io/for-elasticsearch-docs/docs/security-audit-logs/
    opendistro_security.audit.type: internal_elasticsearch
    # See: https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/elasticsearch.yml.example#L27
    opendistro_security.roles_mapping_resolution: BOTH
    opendistro_security.restapi.roles_enabled: ["all_access", "security_rest_api_access"]

    node:
      max_local_storage_nodes: 1
      attr.box_type: hot

    # See: https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/elasticsearch.yml.example#L17
    opendistro_security.nodes_dn:
      - 'CN=nodes.example.com'

    processors: ${PROCESSORS:1}

    thread_pool.write.queue_size: 800

    http:
      compression: true

    # TLS Configuration Transport Layer
    opendistro_security.ssl.transport.pemcert_filepath: elk-transport-crt.pem
    opendistro_security.ssl.transport.pemkey_filepath: elk-transport-key.pem
    opendistro_security.ssl.transport.pemtrustedcas_filepath: elk-transport-root-ca.pem

    # TLS Configuration REST Layer
    opendistro_security.ssl.http.enabled: true
    opendistro_security.ssl.http.pemcert_filepath: elk-rest-crt.pem
    opendistro_security.ssl.http.pemkey_filepath: elk-rest-key.pem
    opendistro_security.ssl.http.pemtrustedcas_filepath: elk-rest-root-ca.pem
    opendistro_security.ssl.transport.truststore_filepath: opendistro-es.truststore

    # See: https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/elasticsearch.yml.example#L23
    opendistro_security.authcz.admin_dn:
      - CN=admin-prod
```

#### Hot/Warm Architectures
This chart supports traditional hot/warm/cold architectures. In order to enable this, there are a few sections that need to be added.

Through the Helm `requirements.yaml`, an alias needs to be created. The below shows a typical hot/warm architecture, with the hot nodes residing in the original deployment and the warm nodes in the second aliased deployments.

*Note that the repository should be the official repository when made available. It is currently set to a local copy of the chart*

`requirements.yaml`:
```
  # Master / Ingest / Hot Nodes
  - name: opendistro-es
    version: ^0.0.1
    repository: file://../opendistro-es/
  # Warm Nodes
  - name: opendistro-es
    version: ^0.0.1
    repository: file://../opendistro-es/
    alias: opendistro-es-data-warm
```

After the `requirements.yaml` is configured, another instance of the chart can be defined in the `values.yaml` to provide the details of the warm environment. The benefit to using the alias attribute, is you can define as many different other environments as you want with some additional configuration options.

There are some key attributes here that should be considered.
 - `elasticsearch.discoveryOverride`  Override for the service name deployed by the original chart alias. (Default: `*namespace*-*alias*-discovery`)
 - `kibana.enabled: false`  Disables and prevent another instance of Kibana
 - `elasticsearch.master.enabled: false`  Disables and prevent another instance of ES Master
 - `elasticsearch.client.enabled: false`  Disables and prevent another instance of ES Ingest/Client

*Note that the config is a snippet showing how you would enable index routing. Please find the [full configuration example here](#elasticsearchyml-config)*

`values.yaml`
```
opendistro-es-data-warm:
  kibana:
    enabled: false
  elasticsearch:
    discoveryOverride: "elasticsearch-opendistro-es-discovery"
    master:
      enabled: false
    client:
      enabled: false
    data:
      enabled: true
    config:
      node:
        max_local_storage_nodes: 1
        attr.box_type: warm
```

With this configured, an additional set of data nodes should be deployed and connected to your cluster.

It is then down to the business use-case to decide how data is routed to either hot/warm nodes using their aggregate of choice E.G. Logstash, Fluentd, Fluentbit etc.

For supporting automated migration of the data, use the [Elasticsearch Curator](https://github.com/helm/charts/tree/master/stable/elasticsearch-curator)

#### logging.yml Config
All values defined under `elasticsearch.loggingConfig` will be converted to yaml and mounted into the config directory.

#### log4j2.properties Config
All values defined under `elasticsearch.log4jConfig` will be mounted into the config directory.

### Configuration
The following table lists the configurable parameters of the opendistro elasticsearch chart and their default values.

| Parameter                                                 | Description                                                                                                                                              | Default                                                                 |
|-----------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| `global.clusterName`                                      | Name of elasticsearch cluster                                                                                                                            | `"elasticsearch"`                                                       |
| `global.psp.create`                                       | Create and use `podsecuritypolicy`  resources                                                                                                            | `"true"`                                                                |
| `global.rbac.enabled`                                     | Create and use `rbac` resources                                                                                                                          | `"true"`                                                                |
| `global.imagePullSecrets`                                 | Global Docker registry secret names as an array                                                                                                          | `[]` (does not add image pull secrets to deployed pods)                 |
| `global.imageRegistry`                                         | Global Docker registry endpoint to allow customizing an alternative registry other than docker.io                                                        | `"docker.io"`                                                           |
| `kibana.enabled`                                          | Enable the installation of kibana                                                                                                                        | `true`                                                                  |
| `kibana.image`                                            | Kibana container image                                                                                                                                   | `amazon/opendistro-for-elasticsearch-kibana`                            |
| `kibana.imageTag`                                         | Kibana container image  tag                                                                                                                              | `1.2.0`                                                                 |
| `kibana.replicas`                                         | Number of Kibana instances to deploy                                                                                                                     | `1`                                                                     |
| `kibana.port`                                             | Internal Port for service                                                                                                                                | `5601`                                                                  |
| `kibana.externalPort`                                     | External Port for service                                                                                                                                | `443`                                                                   |
| `kibana.resources`                                        | Kibana pod resource requests & limits                                                                                                                    | `{}`                                                                    |
| `kibana.elasticsearchAccount.secret`                      | The name of the secret with the Kibana server user as configured in your kibana.yml                                                                      | `""`                                                                    |
| `kibana.elasticsearchAccount.keyPassphrase.enabled`       | Enable mounting in keypassphrase for the `elasticsearchAccount`                                                                                          | `false`                                                                 |
| `kibana.ssl.kibana.enabled`                               | Enabled SSL for kibana                                                                                                                                   | `false`                                                                 |
| `kibana.ssl.kibana.existingCertSecret`                    | Name of secret that contains the Kibana certs                                                                                                            | `""`                                                                    |
| `kibana.ssl.kibana.existingCertSecretCertSubPath`         | Subpath of Kibana cert secret                                                                                                                            | `"kibana-crt.pem"`                                                      |
| `kibana.ssl.kibana.existingCertSecretKeySubPath`          | Subpath of Kibana key secret                                                                                                                             | `"kibana-key.pem"`                                                      |
| `kibana.ssl.kibana.existingCertSecretRootCASubPath`       | Subpath of Kibana root ca secret                                                                                                                         | `"kibana-root-ca.pem"`                                                  |
| `kibana.ssl.elasticsearch.enabled`                        | Enable SSL for interactions between Kibana and Elasticsearch REST clients                                                                                | `false`                                                                 |
| `kibana.ssl.elasticsearch.existingCertSecret`             | Name of secret that contains the Elasticsearch REST certs                                                                                                | `""`                                                                    |
| `kibana.ssl.elasticsearch.existingCertSecretCertSubPath`  | Subpath of Elasticsearch cert secret                                                                                                                     | `"elk-rest-crt.pem"`                                                    |
| `kibana.ssl.elasticsearch.existingCertSecretKeySubPath`   | Subpath of Elasticsearch key secret                                                                                                                      | `"elk-rest-key.pem"`                                                    |
| `kibana.ssl.elasticsearch.existingCertSecretRootCASubPath`| Subpath of Elasticsearch root ca secret                                                                                                                  | `"elk-rest-root-ca.pem"`                                                |
| `kibana.configDirectory`                                  | Location of where to mount in kibana specific configuration                                                                                              | `"/usr/share/kibana/config"`                                            |
| `kibana.certsDirectory`                                   | Location of where to mount in kibana certs configuration                                                                                                 | `"/usr/share/kibana/certs"`                                             |
| `kibana.ingress.enabled`                                  | Enable Kibana Ingress                                                                                                                                    | `false`                                                                 |
| `kibana.ingress.annotations`                              | Kibana Ingress annotations                                                                                                                               | `{}`                                                                    |
| `kibana.ingress.hosts`                                    | Kibana Ingress Hostnames                                                                                                                                 | `[]`                                                                    |
| `kibana.ingress.tls`                                      | Kibana Ingress TLS configuration                                                                                                                         | `[]`                                                                    |
| `kibana.ingress.labels`                                   | Kibana Ingress labels                                                                                                                                    | `{}`                                                                    |
| `kibana.ingress.path`                                     | Kibana Ingress paths                                                                                                                                     | `[]`                                                                    |
| `kibana.config`                                           | Kibana Configuration (`kibana.yml`)                                                                                                                      | `{}`                                                                    |
| `kibana.nodeSelector`                                     | Define which Nodes the Pods are scheduled on.                                                                                                            | `{}`                                                                    |
| `kibana.podAnnotations`                                   | Kibana pods annotations                                                                                                                                  | `{}`                                                                    |
| `kibana.tolerations`                                      | If specified, the pod's tolerations.                                                                                                                     | `[]`                                                                    |
| `kibana.serviceAccount.create`                            | Create a default serviceaccount for Kibana to use                                                                                                        | `true`                                                                  |
| `kibana.serviceAccount.name`                              | Name for Kibana serviceaccount                                                                                                                           | `""`                                                                    |
| `kibana.extraEnvs`                                        | Extra environments variables to be passed to kibana                                                                                                      | `[]`                                                                    |
| `kibana.extraVolumes`                                     | Array of extra volumes to be added                                                                                                                       | `[]`                                                                    |
| `kibana.extraVolumeMounts`                                | Array of extra volume mounts to be added                                                                                                                 | `[]`                                                                    |
| `kibana.extraInitContainers`                              | Array of extra init containers                                                                                                                           | `[]`                                                                    |
| `kibana.extraContainers`                                  | Array of extra containers                                                                                                                                | `[]`                                                                    |
| `kibana.readinessProbe`                                   | Configuration for the [readinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)                    | `[]`                                                                    |
| `kibana.livenessProbe`                                    | Configuration for the [livenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)                     | `[]`                                                                    |
| `kibana.startupProbe`                                    | Configuration for the [startupProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)                     | `[]`                                                                    |
| `elasticsearch.discoveryOverride`                         | For hot/warm architectures. Allows second aliased deployment to find cluster.                                                                            | `""`                                                                    |
| `elasticsearch.fixmount.enabled`                          | Enable initContainer to fix mount permissions. Not required if setting a fsGroup via securityContext                                                     | `true`                                                                    |
| `elasticsearch.sys_chroot.enabled`                        | Enable giving Elasticsearch containers the "SYS_CHROOT" capability.                                                                                      | `true`                                                                    |
| `elasticsearch.sysctl.enabled`                            | Enable initContainer to set sysctl "vm.max_map_count"                                                                                                    | `true`                                                                  |
| `elasticsearch.securityConfig.enabled`                    | Use custom [security configs](https://github.com/opendistro-for-elasticsearch/security/tree/master/securityconfig)                                       | `"true"`                                                                |
| `elasticsearch.securityConfig.path`                       | Path to security config files                                                                                                                            | `"/usr/share/elasticsearch/plugins/opendistro_security/securityconfig"` |
| `elasticsearch.securityConfig.actionGroupsSecret`         | Name of secret with [action_groups.yml](https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/action_groups.yml) defined   | `""`                                                                    |
| `elasticsearch.securityConfig.configSecret`               | Name of secret with [config.yml](https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/config.yml) defined                 | `""`                                                                    |
| `elasticsearch.securityConfig.internalUsersSecret`        | Name of secret with [internal_users.yml](https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/internal_users.yml) defined | `""`                                                                    |
| `elasticsearch.securityConfig.rolesSecret`                | Name of secret with [roles.yml](https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/roles.yml) defined                   | `""`                                                                    |
| `elasticsearch.securityConfig.rolesMappingSecret`         | Name of secret with [roles_mapping.yml](https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/roles_mapping.yml) defined   | `""`                                                                    |
| `elasticsearch.securityConfig.tenantsSecret`              | Name of secret with [tenants.yml](https://github.com/opendistro-for-elasticsearch/security/blob/master/securityconfig/tenants.yml) defined               | `""`                                                                    |
| `elasticsearch.securityContextCustom`                     | securityContext for the ElasticSearch pods                                                                                                               | `{}`                                                                    |
| `elasticsearch.ssl.transport.existingCertSecret`          | Name of secret that contains the transport certs                                                                                                         | `""`                                                                    |
| `elasticsearch.ssl.transport.existingCertSecretCertSubPath`  | Subpath of elastic transport cert secret                                                                                                              | `"elk-transport-crt.pem"`                                               |
| `elasticsearch.ssl.transport.existingCertSecretKeySubPath`   | Subpath of elastic transport key secret                                                                                                               | `"elk-transport-key.pem"`                                               |
| `elasticsearch.ssl.transport.existingCertSecretRootCASubPath`| Subpath of elastic transport root ca secret                                                                                                           | `"elk-transport-root-ca.pem"`                                           |
| `elasticsearch.ssl.rest.enabled`                          | Enable REST SSL for Elasticsearch                                                                                                                        | `false`                                                                 |
| `elasticsearch.ssl.rest.existingCertSecret`               | Name of secret that contains the Elasticsearch REST certs                                                                                                | `""`                                                                    |
| `elasticsearch.ssl.rest.existingCertSecretCertSubPath`    | Subpath of elastic rest cert secret                                                                                                                      | `"elk-rest-crt.pem"`                                                    |
| `elasticsearch.ssl.rest.existingCertSecretKeySubPath`     | Subpath of elastic rest key secret                                                                                                                       | `"elk-rest-key.pem"`                                                    |
| `elasticsearch.ssl.rest.existingCertSecretRootCASubPath`  | Subpath of elastic rest root ca secret                                                                                                                   | `"elk-rest-root-ca.pem"`                                                |
| `elasticsearch.ssl.admin.enabled`                         | Enable Admin SSL cert usage for Elasticsearch                                                                                                            | `false`                                                                 |
| `elasticsearch.ssl.admin.existingCertSecret`              | Name of secret that contains the admin users Elasticsearch certs                                                                                         | `""`                                                                    |
| `elasticsearch.ssl.admin.existingCertSecretCertSubPath`   | Subpath of elastic admin cert secret                                                                                                                     | `"admin-crt.pem"`                                                       |
| `elasticsearch.ssl.admin.existingCertSecretKeySubPath`    | Subpath of elastic admin key secret                                                                                                                      | `"admin-key.pem"`                                                       |
| `elasticsearch.ssl.admin.existingCertSecretRootCASubPath` | Subpath of elastic admin root ca secret                                                                                                                  | `"admin-root-ca.pem"`                                                   |
| `elasticsearch.master.enabled`                            | Enables the Elasticsearch Master                                                                                                                         | `true`                                                                  |
| `elasticsearch.master.replicas`                           | Number of Elasticsearch masters to spin up                                                                                                               | `1`                                                                     |
| `elasticsearch.master.nodeAffinity`                       | Elasticsearch masters nodeAffinity                                                                                                                       | `{}`                                                                    |
| `elasticsearch.master.resources`                          | Elasticsearch masters resource requests & limits                                                                                                         | `{}`                                                                    |
| `elasticsearch.master.javaOpts`                           | Elasticsearch masters configurable java options to pass to startup script                                                                                | `"-Xms512m -Xmx512m"`                                                   |
| `elasticsearch.master.podDisruptionBudget.enabled`        | If true, create a disruption budget for elasticsearch master                                                                                             | `false`                                                                 |
| `elasticsearch.master.podDisruptionBudget.minAvailable`   | Minimum number / percentage of pods that [should remain scheduled](https://kubernetes.io/docs/tasks/run-application/configure-pdb/#think-about-how-your-application-reacts-to-disruptions)                                                                                         | `1`                                                                     |
| `elasticsearch.master.podDisruptionBudget.maxUnavailable` | Maximum number / percentage of pods that [may be unscheduled](https://kubernetes.io/docs/tasks/run-application/configure-pdb/#think-about-how-your-application-reacts-to-disruptions)                                                                                         | `""`                                                                    |
| `elasticsearch.master.tolerations`                        | If specified, the elasticsearch client pod's tolerations.                                                                                                | `[]`                                                                    |
| `elasticsearch.master.nodeSelector`                       | Define which Nodes the master pods are scheduled on.                                                                                                     | `{}`                                                                    |
| `elasticsearch.master.podAnnotations`                     | Elasticsearch master pods annotations                                                                                                      | `{}`                                                                    |
| `elasticsearch.master.livenessProbe`                      | Configuration for the [livenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)                     | `[]`                                                                    |
| `elasticsearch.master.readinessProbe`                     | Configuration for the [readinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)                    | `[]`                                                                    |
| `elasticsearch.master.startupProbe`                     | Configuration for the [startupProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)                    | `[]`                                                                    |
| `elasticsearch.master.updateStrategy`                     | The [updateStrategy](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#updating-statefulsets) for the master statefulset.    | `RollingUpdate`                                                         |
| `elasticsearch.master.persistence.enabled`                | Elasticsearch master enable persistent storage                                                                                                           | `true`                                                                     |
| `elasticsearch.master.persistence.existingClaim`          | Elasticsearch master persistent existingClaim                                                                                                            | disabled by default, see `values.yaml`                                  |
| `elasticsearch.master.persistence.subPath`                | Elasticsearch master persistence subPath                                                                                                                 | `""`                                                                    |
| `elasticsearch.master.persistence.storageClass`           | Elasticsearch master storageClassName                                                                                                                    | see `values.yaml` for defaults                                          |
| `elasticsearch.master.persistence.accessModes`            | Elasticsearch master persistence accessModes                                                                                                             | `- ReadWriteOnce`                                                  |
| `elasticsearch.master.persistence.size`                   | Elasticsearch master persistence size                                                                                                                    | `"8Gi"`                                                                 |
| `elasticsearch.master.persistence.annotations`            | Elasticsearch master persistent volume annotations                                                                                                       | `{}`                                                                    |
| `elasticsearch.master.extraInitContainers`                | Array of extra init containers                                                                                                                           | `[]`                                                                    |
| `elasticsearch.master.extraContainers`                    | Array of extra containers                                                                                                                                | `[]`                                                                    |
| `elasticsearch.client.enabled`                            | Enables the Elasticsearch Client/Ingester                                                                                                                | `true`                                                                  |
| `elasticsearch.client.dedicatedPod.enabled`               | Enables dedicated deployment for client/ingest. Otherwise master nodes as client/ingest                                                                  | `true`                                                                  |
| `elasticsearch.client.replicas`                           | Number of Elasticsearch clients to spin up                                                                                                               | `1`                                                                     |
| `elasticsearch.client.nodeAffinity`                       | Elasticsearch clients nodeAffinity                                                                                                                       | `{}`                                                                    |
| `elasticsearch.client.resources`                          | Elasticsearch clients resource requests & limits                                                                                                         | `{}`                                                                    |
| `elasticsearch.client.javaOpts`                           | Elasticsearch clients configurable java options to pass to startup script                                                                                | `"-Xms512m -Xmx512m"`                                                   |
| `elasticsearch.client.service.type`                       | Elasticsearch clients service type                                                                                                                       | `ClusterIP`                                                             |
| `elasticsearch.client.service.annotations`                | Elasticsearch clients service annotations                                                                                                                | `{}`                                                                    |
| `elasticsearch.client.ingress.enabled`                    | Enable Elasticsearch clients Ingress                                                                                                                     | `false`                                                                 |
| `elasticsearch.client.ingress.annotations`                | Elasticsearch clients Ingress annotations                                                                                                                | `{}`                                                                    |
| `elasticsearch.client.ingress.hosts`                      | Elasticsearch clients Ingress Hostnames                                                                                                                  | `[]`                                                                    |
| `elasticsearch.client.ingress.tls`                        | Elasticsearch clients Ingress TLS configuration                                                                                                          | `[]`                                                                    |
| `elasticsearch.client.ingress.labels`                     | Elasticsearch clients Ingress labels                                                                                                                     | `{}`                                                                    |
| `elasticsearch.client.livenessProbe`                      | Configuration for the [livenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)                     | `[]`                                                                    |
| `elasticsearch.client.readinessProbe`                     | Configuration for the [readinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)                    | `[]`                                                                    |
| `elasticsearch.client.startupProbe`                     | Configuration for the [startupProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)                    | `[]`                                                                    |
| `elasticsearch.client.podDisruptionBudget.enabled`        | If true, create a disruption budget for elasticsearch client                                                                                             | `false`                                                                 |
| `elasticsearch.client.podDisruptionBudget.minAvailable`   | Minimum number / percentage of pods that should remain scheduled                                                                                         | `1`                                                                     |
| `elasticsearch.client.podDisruptionBudget.maxUnavailable` | Maximum number / percentage of pods that should remain scheduled                                                                                         | `""`                                                                    |
| `elasticsearch.client.tolerations`                        | If specified, the elasticsearch client pod's tolerations.                                                                                                | `[]`                                                                    |
| `elasticsearch.client.nodeSelector`                       | Define which Nodes the client pods are scheduled on.                                                                                                     | `{}`                                                                    |
| `elasticsearch.client.podAnnotations`                     | Elasticsearch client pods annotations                                                                                                      | `{}`                                                                    |
| `elasticsearch.data.enabled`                              | Enables the Elasticsearch Data Node                                                                                                                      | `true`                                                                  |
| `elasticsearch.data.dedicatedPod.enabled`                 | Enables dedicated statefulset for data. Otherwise master nodes as data storage                                                                           | `true`                                                                  |
| `elasticsearch.data.replicas`                             | Number of Elasticsearch data nodes to spin up                                                                                                            | `1`                                                                     |
| `elasticsearch.data.nodeAffinity`                         | Elasticsearch data nodeAffinity                                                                                                                          | `{}`                                                                    |
| `elasticsearch.data.resources`                            | Elasticsearch data resource requests & limits                                                                                                            | `{}`                                                                    |
| `elasticsearch.data.javaOpts`                             | Elasticsearch data configurable java options to pass to startup script                                                                                   | `"-Xms512m -Xmx512m"`                                                   |
| `elasticsearch.data.persistence.enabled`                  | Elasticsearch data enable persistent storage                                                                                                             | `true`                                                                  |
| `elasticsearch.data.persistence.existingClaim`            | Elasticsearch data persistent existingClaim                                                                                                              | disabled by default, see `values.yaml`                                  |
| `elasticsearch.data.persistence.subPath`                  | Elasticsearch data persistence subPath                                                                                                                   | `""`                                                                    |
| `elasticsearch.data.persistence.storageClass`             | Elasticsearch data storageClassName                                                                                                                      | see `values.yaml` for defaults                                          |
| `elasticsearch.data.persistence.accessModes`              | Elasticsearch data persistence accessModes                                                                                                               | `- ReadWriteOnce`                                                  |
| `elasticsearch.data.persistence.size`                     | Elasticsearch data persistence size                                                                                                                      | `"8Gi"`                                                                 |
| `elasticsearch.data.persistence.annotations`              | Elasticsearch data persistent volume annotations                                                                                                         | `{}`                                                                    |
| `elasticsearch.data.podDisruptionBudget.enabled`          | If true, create a disruption budget for elasticsearch data node                                                                                          | `false`                                                                 |
| `elasticsearch.data.podDisruptionBudget.minAvailable`     | Minimum number / percentage of pods that should remain scheduled                                                                                         | `1`                                                                     |
| `elasticsearch.data.podDisruptionBudget.maxUnavailable`   | Maximum number / percentage of pods that should remain scheduled                                                                                         | `""`                                                                    |
| `elasticsearch.data.tolerations`                          | If specified, the elasticsearch client pod's tolerations.                                                                                                | `[]`                                                                    |
| `elasticsearch.data.nodeSelector`                         | Define which Nodes the data pods are scheduled on.                                                                                                       | `{}`                                                                    |
| `elasticsearch.data.podAnnotations`                       | Elasticsearch data pod annotations                                                                                                      | `{}`                                                                    |
| `elasticsearch.data.livenessProbe`                        | Configuration for the [livenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)                     | `[]`                                                                    |
| `elasticsearch.data.readinessProbe`                       | Configuration for the [readinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)                    | `[]`                                                                    |
| `elasticsearch.data.startupProbe`                       | Configuration for the [startupProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)                    | `[]`                                                                    |
| `elasticsearch.master.updateStrategy`                     | The [updateStrategy](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#updating-statefulsets) for the master statefulset.    | `RollingUpdate`                                                         |
| `elasticsearch.config`                                    | Elasticsearch Configuration (`elasticsearch.yml`)                                                                                                        | `{}`                                                                    |
| `elasticsearch.loggingConfig`                             | Elasticsearch Logging Configuration (`logging.yml`)                                                                                                      | see `values.yaml` for defaults                                          |
| `elasticsearch.log4jConfig`                               | Elasticsearch log4j Configuration                                                                                                                        | `""`                                                                    |
| `elasticsearch.transportKeyPassphrase.enabled`            | Elasticsearch transport key passphrase required                                                                                                          | `false`                                                                 |
| `elasticsearch.transportKeyPassphrase.passPhrase`         | Elasticsearch transport key passphrase                                                                                                                   | `""`                                                                    |
| `elasticsearch.sslKeyPassphrase.enabled`                  | Elasticsearch ssl key passphrase required                                                                                                                | `false`                                                                 |
| `elasticsearch.sslKeyPassphrase.passPhrase`               | Elasticsearch ssl key passphrase                                                                                                                         | `""`                                                                    |
| `elasticsearch.image`                                     | Elasticsearch container image                                                                                                                            | `amazon/opendistro-for-elasticsearch`                                   |
| `elasticsearch.imageTag`                                  | Elasticsearch container image  tag                                                                                                                       | `1.2.0`                                                                 |
| `elasticsearch.imagePullPolicy`                           | Elasticsearch container image  pull policy                                                                                                               | `Always`                                                                |
| `elasticsearch.serviceAccount.create`                     | Create a default serviceaccount for elasticsearch to use                                                                                                 | `true`                                                                  |
| `elasticsearch.initContainer.image`                       | Init container image                                                                                                                                     | `busybox`                                                               |
| `elasticsearch.initContainer.imageTag`                    | Init container image Tag                                                                                                                                 | `busybox`                                                               |
| `elasticsearch.serviceAccount.name`                       | Name for elasticsearch serviceaccount                                                                                                                    | `""`                                                                    |
| `elasticsearch.configDirectory`                           | Location of elasticsearch configuration                                                                                                                  | `"/usr/share/elasticsearch/config"`                                     |
| `elasticsearch.maxMapCount`                               | elasticsearch max_map_count                                                                                                                              | `262144`                                                                |
| `elasticsearch.extraEnvs`                                 | Extra environments variables to be passed to elasticsearch services                                                                                      | `[]`                                                                    |
| `elasticsearch.extraVolumes`                              | Array of extra volumes to be added                                                                                                                       | `[]`                                                                    |
| `elasticsearch.extraVolumeMounts`                         | Array of extra volume mounts to be added                                                                                                                 | `[]`                                                                    |
| `elasticsearch.extraInitContainers`                       | Array of extra init containers                                                                                                                           | `[]`                                                                    |

## Acknowledgements
* [Kalvin Chau](https://github.com/kalvinnchau) (Software Engineer - Viasat) for all his help with the Kubernetes internals, certs, and debugging
