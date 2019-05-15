 # Open Distro for Elasticsearch Kibana build

This repo contains the scripts for building Open Distro for Elasticsearch Kibana Docker images and packages for Linux distributions (RPM & DEB).

The default version to build is set in version.json for both Docker and Linux distributions.

## Getting started
```
git clone https://github.com/opendistro-for-elasticsearch/opendistro-build.git
```

Then change directory into either kibana/docker or kibana/linux_distributions.

## Docker

### Credit

The docker build scripts are based on [elastic/kibana-docker](https://github.com/elastic/kibana-docker/tree/6.5)

The image is built on [CentOS 7](https://github.com/CentOS/sig-cloud-instance-images/blob/CentOS-7/docker/Dockerfile)

### Supported Docker versions

The images have been tested on Docker 18.09.2.

### Requirements

A full build and test requires (assume you are on Ubuntu 18.04):

- Docker
```
sudo apt-get update
sudo apt-get install docker.io
sudo usermod -a -G docker $USER
```
Then log out and back in again.

- GNU Make
- Python 3.5 with 

    pip
    ```
    sudo apt install python3-pip
    ```

    and virtualenv

    ```
    sudo apt-get install python-virtualenv
    ```

### Running a build
To build an image with the latest nightly snapshot of Kibana, run:

To build an image with a released version of Kibana, run Make while specifying the exact version Open Distro for Elasticsearch AND Elasticsearch.
For example:
```
OPENDISTRO_VERSION=0.8.0 ES_VERSION=6.6.2 make build
```

For running builds with a different repository name, run the following
```
OPENDISTRO_REPOSITORY=<repo_name> make build
```

### Testing the image
```
make test
```

## Linux Distributions

### Preparing the environment

The Linux distributions are built within a Docker image.

```
docker pull opendistroforelasticsearch/jsenv:v1
docker run -it opendistroforelasticsearch/jsenv:v1
```

Within the Docker container, clone this repo
```
git clone https://github.com/opendistro-for-elasticsearch/opendistro-build.git
```

Make sure you're in the Kibana Linux distributions directory
```
cd opendistro-build/kibana/linux_distributions
```


### Build Linux artifacts

To build the rpm package
```
./generate-pkg.sh rpm
```

To build the deb package
```
./generate-pkg.sh deb
```

To build rpm & deb packages
```
./generate-pkg.sh
```

## Contributing

Open Distro for Elasticsearch is and will remain 100% open source under the Apache 2.0 license. As the project grows, we invite you to join the project and contribute. We want to make it easy for you to get started and remove friction — no lengthy Contributor License Agreement — so you can focus on writing great code.

## Questions

If you have any questions, please join our community forum [here](https://discuss.opendistrocommunity.dev/)

## Issues

File any issues [here](https://github.com/opendistro-for-elasticsearch/community/issues).
