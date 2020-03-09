# MCStreetguy/Carrier – Just another Docker base image

This Docker image is designed to be used as a base for containerized applications.
It provides a customized init system based upon [`just-containers/s6-overlay`](https://github.com/just-containers/s6-overlay) and some additional utilities for simplified creation of app images.

## Usage

Just specify the image tag inside your Dockerfile `FROM` directive:

```Dockerfile
FROM mcstreetguy/carrier:latest

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
If you are not familiar with Alpine you can find some guides to get you started [in the official wiki](https://wiki.alpinelinux.org/wiki/Tutorials_and_Howtos).

### Preinstalled Packages

The following packages are preinstalled in their latest available version in the respective Alpine branch.

- [`bash`](https://pkgs.alpinelinux.org/package/edge/main/x86_64/bash)
- [`coreutils`](https://pkgs.alpinelinux.org/package/edge/main/x86_64/coreutils)

### Preinstalled Software / Libraries

The following external software or libraries are preinstalled in their latest available version.

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
| `S6_BEHAVIOUR_IF_STAGE2_FAILS` | By default, any error in `fix-attrs.d` and `cont-init.d` will cause the container to terminate. Set this to `0` to silently ignore any error or to `1` to show up a warning message, but continue to start up the container. |
| `S6_KILL_FINISH_MAXTIME` | The maximum time (in milliseconds) a script in `cont-finish.d` could take before sending a `KILL` signal to it. Take into account that this parameter will be used per each script execution, it's not a max time for the whole set of scripts. (default: 5000) |
| `S6_SERVICES_GRACETIME` | How long (in milliseconds) s6 should wait services before sending a `TERM` signal. (default: 3000) |
| `S6_KILL_GRACETIME` | How long (in milliseconds) s6 should wait to reap zombies before sending a `KILL` signal. (default: 3000) |
| `S6_FIX_ATTRS_HIDDEN` | Controls how `fix-attrs.d` scripts process files and directories. If set to `0`, hidden files and directories are excluded. If set to `1`, all files and directories are processed. (default: 0) |
| `S6_READ_ONLY_ROOT` | When running in a container whose root filesystem is read-only, set this env to 1 to inform init stage 2 that it should copy user-provided initialization scripts from /etc to /var/run/s6/etc before it attempts to change permissions, etc. |

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
