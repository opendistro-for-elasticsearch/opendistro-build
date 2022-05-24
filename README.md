 # Building Open Distro for Elasticsearch

This repo contains the scripts for building Open Distro for Elasticsearch & Kibana Docker images and packages for Linux distributions (RPM & DEB).

## Contributing

Open Distro for Elasticsearch is and will remain 100% open source under the Apache 2.0 license. As the project grows, we invite you to join the project and contribute. We want to make it easy for you to get started and remove friction—no lengthy Contributor License Agreement — so you can focus on writing great code.

## Questions

If you have any questions, please join our community forum [here](https://discuss.opendistrocommunity.dev/)

## Issues

File any issues [here](https://github.com/opendistro-for-elasticsearch/opendistro-build/issues).

## Helm releases

When building a new helm chart, run these commands from top of this repo:
```
(cd helm; helm package opendistro-es)
helm repo index helm/ --url https://raw.githubusercontent.com/opendistro-for-elasticsearch/opendistro-build/main/helm/
```

