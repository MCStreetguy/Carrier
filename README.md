# MCStreetguy/Harbour – Just another Docker base image

This Docker image is designed to be used as a base for containerized applications.
It provides a customized init system based upon [`just-containers/s6-overlay`](https://github.com/just-containers/s6-overlay) and some additional utilities for simplified creation of app images.

## Usage

Just specify the image tag inside your Dockerfile `FROM` directive:

```Dockerfile
FROM mcstreetguy/harbour:latest

# ...
```

### Versions

You may choose from the following available tag versions:

| Tag version | Description |
|:-----------:|:------------|
| `latest` | The latest available version, based upon the latest stable Alpine Linux. |
| `alpine-3.11` | The latest available version, based upon Alpine Linux 3.11. |
| `alpine-3.10` | The latest available version, based upon Alpine Linux 3.10. |
| `alpine-3.9` | The latest available version, based upon Alpine Linux 3.9. |
| `alpine-3.8` | The latest available version, based upon Alpine Linux 3.8. |

## Overview

The image is based fully upon Alpine Linux to be as small and fast as possible.

### Preinstalled Packages

- [`bash`](https://pkgs.alpinelinux.org/package/edge/main/x86_64/bash)
- [`coreutils`](https://pkgs.alpinelinux.org/package/edge/main/x86_64/coreutils)

### Preinstalled Software / Libraries

- [Skarnet skalibs](https://skarnet.org/software/skalibs/)
- [Skarnet execline](https://skarnet.org/software/execline/)
- [Skarnet s6](https://skarnet.org/software/s6/)
- [Skarnet s6-linux-utils](https://skarnet.org/software/s6-linux-utils/)
- [Skarnet s6-linux-init](https://skarnet.org/software/s6-linux-init/)
- [just-containers/s6-overlay](https://github.com/just-containers/s6-overlay)

### Init Stages

_to be written_

### Customizing Behaviour

You may set any of the following environmental variables on the container to customize some behaviour of the init system:

| Variable | Description |
|:--------:|:------------|
| `KEEP_ENV` | A space-separated list of environment variables to dump onto the filesystem for later retrieval. (see [`execenv`](#binexecenv) for more info) |

## Reference

### Binaries

#### `/bin/execdir`

Execute each file in a given directory, then exit into another program.  
If the given directory could not be found, the script exits with a non-zero code.
If a file in the given directory is not executable, it is skipped silently.

```shell
/bin/execdir <script_directory> prog...
```

#### `/bin/execenv`

Execute another program with dropped environment variables.
Only variables defined in the `KEEP_ENV` environment variable (excluding itself) will be loaded into the programs environment.

```shell
/bin/execenv prog...
```

#### `/usr/bin/containerip`

Get the internal IP address of the container.

```shell
$ /usr/bin/hostip
172.21.0.1
```

#### `/usr/bin/hostip`

Get the internal IP address of the host, running the Docker daemon.

```shell
$ hostip
172.21.0.1
```

### Environment

In the early init stage some default environment variables are written to the system.
Find the available variables and respective value explanations below.

#### `HOSTIP`

Contains the internal IP address of the host, running the docker daemon.
This yields the same result as executing [`/usr/bin/hostip`](#usrbinhostip).

#### `CONTAINERIP`

Contains the internal IP address of the current container.
This yields the same result as executing [`/usr/bin/containerip`](#usrbincontainerip).
