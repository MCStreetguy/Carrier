# MCStreetguy/Carrier – Just another Docker base image

This Docker image is designed to be used as a base for containerized applications.

- [MCStreetguy/Carrier – Just another Docker base image](#mcstreetguycarrier-%e2%80%93-just-another-docker-base-image)
  - [Usage](#usage)
    - [Fix ownership and permissions](#fix-ownership-and-permissions)
      - [Examples](#examples)
    - [Execute initialization tasks](#execute-initialization-tasks)
    - [Creating service scripts](#creating-service-scripts)
    - [Execute finalization tasks](#execute-finalization-tasks)
    - [Environment variables](#environment-variables)
      - [Services](#services)
      - [Inside init or finish scripts](#inside-init-or-finish-scripts)
    - [Dropping privileges](#dropping-privileges)
  - [Overview](#overview)
    - [Init Stages](#init-stages)
    - [Customizing Behaviour](#customizing-behaviour)
  - [Reference](#reference)
    - [Binaries](#binaries)
      - [`/sbin/package`](#sbinpackage)
      - [`/bin/deeplog`](#bindeeplog)
      - [`/bin/mirrorlog`](#binmirrorlog)
      - [`/bin/deeperr`](#bindeeperr)
      - [`/bin/mirrorerr`](#binmirrorerr)
      - [`/bin/prefixlog`](#binprefixlog)
      - [`/bin/execdir`](#binexecdir)
      - [`/bin/execenv`](#binexecenv)
      - [`/usr/bin/containerip`](#usrbincontainerip)
      - [`/usr/bin/hostip`](#usrbinhostip)
      - [`/usr/bin/awaits`](#usrbinawaits)
    - [Environment](#environment)
      - [`HOSTIP`](#hostip)
      - [`CONTAINERIP`](#containerip)

## Usage

Just specify the image tag inside your Dockerfile `FROM` directive:

```Dockerfile
FROM mcstreetguy/carrier:latest
```

You may choose from the following available tags, to restrict the underlying OS:

| Tag version | Description |
|:-----------:|:------------|
| `latest` | The latest available version, based upon the latest stable Ubuntu. |
| `ubuntu-18.04` | The latest available version, based upon Ubuntu 18.04 LTS. |
| `ubuntu-16.04` | The latest available version, based upon Ubuntu 16.04 LTS. |
| `ubuntu-14.04` | The latest available version, based upon Ubuntu 14.04 LTS. |
| `alpine-edge` | The latest available version, based upon the latest stable Alpine Linux. |
| `alpine-3.11` | The latest available version, based upon Alpine Linux 3.11. |
| `alpine-3.10` | The latest available version, based upon Alpine Linux 3.10. |
| `alpine-3.9` | The latest available version, based upon Alpine Linux 3.9. |
| `alpine-3.8` | The latest available version, based upon Alpine Linux 3.8. |
| `alpine-3.7` * | The latest available version, based upon Alpine Linux 3.7. |
| `alpine-3.6` * | The latest available version, based upon Alpine Linux 3.6. |
| `alpine-3.5` * | The latest available version, based upon Alpine Linux 3.5. |
| `alpine-3.4` * | The latest available version, based upon Alpine Linux 3.4. |
| `alpine-3.3` * | The latest available version, based upon Alpine Linux 3.3. |
| `alpine-3.2` * | The latest available version, based upon Alpine Linux 3.2. |

_(* this version of alpine is no longer maintained, you should upgrade soon!)_

As the image mainly relies on [`just-containers/s6-overlay`](https://github.com/just-containers/s6-overlay), their usage instructions apply here too.

### Fix ownership and permissions

You may provide text files inside `/etc/fix-attrs.d`, containing instructions for setting file permissions.
Each line has to contain the following information:

```plain
path recurse account fmode dmode
```

Whereas `path` specifies the absolute path to work on,
`recurse` (either `true` or `false`) specifies if the path should be crawled recursively,
`account` specifies the owner and optionally group for the found files and directories,
`fmode` is a four-digit octal unix permission code set on files and
`dmode` is a four-digit octal unix permission code set on directories.

_(see also: [https://github.com/just-containers/s6-overlay#fixing-ownership--permissions](https://github.com/just-containers/s6-overlay#fixing-ownership--permissions))_

#### Examples

`/etc/fix-attrs.d/01-mysql-data-dir`:

```plain
/var/lib/mysql true mysql 0600 0700
```

`/etc/fix-attrs.d/02-mysql-log-dirs`:

```plain
/var/log/mysql-error-logs true nobody,32768:32768 0644 2700
/var/log/mysql-general-logs true nobody,32768:32768 0644 2700
/var/log/mysql-slow-query-logs true nobody,32768:32768 0644 2700
```

### Execute initialization tasks

You may provide scripts inside `/etc/cont-init.d`, which will be executed after permissions have been fixed.
These can contain initialization tasks and will be run each time the container starts.  
If used for installation scripts that should only run once, make sure to check for the first run manually!  
The scripts can be written in any language as long as you provide a shebang at the beginning.
Commonly this would be either `/bin/bash` as interpreter or the `/bin/execlineb` interpreter for [`s6-execline` scripting language](https://skarnet.org/software/execline/).

_(see also: [https://github.com/just-containers/s6-overlay#executing-initialization-andor-finalization-tasks](https://github.com/just-containers/s6-overlay#executing-initialization-andor-finalization-tasks))_

### Creating service scripts

Creating supervised, long-lived services for your container is as easy as creating a directory with it's name inside `/etc/services.d/` and create a `run` file in it.  
That file is expected to be a script and execute the service in some way.  
**It may not terminate** unless the service itself terminates, thus it has to run in foreground!  
As before, this script has to provide a shebang with some interpreter for it's contents.

Services are automatically restarted by the s6 supervisor, unless you provide an optional `finish` script file in the service directory.
If such a script is present, it will be executed as soon as the `run` script terminates and will bring the container down afterwards (i.e. makes the init system proceed to the shutdown stage).
If you only want to prevent the restart of any service, it may contain only an `exit 0` statement (which is valid in both `bash` and `execline`).

If you would like to know more about the possibilities of services beyond the shown common usage, consult the [s6 servicedir documentation](http://skarnet.org/software/s6/servicedir.html).

_(see also: [https://github.com/just-containers/s6-overlay#writing-a-service-script](https://github.com/just-containers/s6-overlay#writing-a-service-script) and [https://github.com/just-containers/s6-overlay#writing-an-optional-finish-script](https://github.com/just-containers/s6-overlay#writing-an-optional-finish-script))_

### Execute finalization tasks

In the same way as we provided [intialization tasks](#execute-initialization-tasks) before, we may provide such scripts inside `/etc/cont-finish.d/` to create a finalization task, which is executed during early shutdown stage.

_(see also: [https://github.com/just-containers/s6-overlay#executing-initialization-andor-finalization-tasks](https://github.com/just-containers/s6-overlay#executing-initialization-andor-finalization-tasks))_

### Environment variables

To make your script have environment variables available, you need to modify your sheband a little bit.
Normally, the entire environment is dropped upon execution to improve security when passing sensitive information through and `.env` file for example.

#### Services

It is good practice to provide only the bare minimum of required environment variables to your services.
To do so, you may provide the [`KEEP_ENV` environment variable](#customizing-behaviour) with a space-separated list of variable names to store for later service execution.
This may be done using and `ENV KEEP_ENV=...` statement in your Dockerfile.

Then in your services `run` script, prepend the following binary to your shebang:

```plain
/bin/execenv
```

The resulting shebang should look like such:

```shell
#!/bin/execenv /bin/bash
# or
#!/bin/execenv /bin/execlineb -P
```

Now the service only has a reduced set of environment variables available.
Namely some common system variables and the ones listed in `KEEP_ENV`.

If your service does not depend on the environment in any way, it is good practice to drop it explicitly.

**`bash`:**

```bash
#!/bin/bash
exec -c -- myservice
```

**`execline`:**

```execline
#!/bin/execlineb -P
/bin/exec -c --
myservice
```

#### Inside init or finish scripts

Inside initialisation or finish tasks you normally want all your configuration to be available.
To achieve this you may use the `with-contenv` helper script:

```shell
#!/usr/bin/with-contenv /bin/bash
# or
#!/usr/bin/with-contenv /bin/execlineb -P
```

### Dropping privileges

When it comes to executing a service, a very good practice is to drop privileges before executing it.
This is done easily with the provided helpers in both common scripting languages.

**`bash`:**

```bash
#!/bin/bash
exec s6-setuidgid daemon myservice
```

**`execline`:**

```execline
#!/usr/bin/execlineb -P
s6-setuidgid daemon
myservice
```

_(see also [https://github.com/just-containers/s6-overlay#dropping-privileges](https://github.com/just-containers/s6-overlay#dropping-privileges))_

## Overview

The image is based fully upon Alpine Linux to be as small and fast as possible.  
If you are not familiar with Alpine you can find some guides to get you started [in the official wiki](https://wiki.alpinelinux.org/wiki/Tutorials_and_Howtos).

### Init Stages

See the [respective section in the `README` of `just-containers/s6-overlay`](https://github.com/just-containers/s6-overlay#init-stages) for detailled information about the init stages.

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

#### `/sbin/package`

A wrapper script for the OS-specific package manager (`apk` under Alpine, `apt` under Ubuntu).
Supports installation, removal, updates and prevention of packages.

> USAGE: /sbin/package <command> <arguments>
> 
> Available commands:
>   install    Install a package
>   remove     Remove/Uninstall a package
>   update     Update all or specific packages
>   prevent    Prevent the installation, update or removal of a package
>   allow      Re-allow the installation, update or removal of a package

```shell
# Install a single package
/sbin/package install nano
# Install multiple packages at once
/sbin/package install pkg1 pkg2 pkg3
# Remove a single package
/sbin/package remove nano
# Remove multiple packages at once
/sbin/package remove pkg1 pkg2 pkg3
# Update all packages
/sbin/package update
# Update only one/some packages
/sbin/package update pkg1 pkg2
# Prevent the installation of a package (Ubuntu specific)
/sbin/package prevent spell
# Re-allow the installation of a package (Ubuntu specific)
/sbin/package allow spell
```

#### `/bin/deeplog`

Send output directly to the attached Docker daemon's stdout file descriptor (e.g. the docker-compose container output).  
The sent lines are not mirrored to the terminal! See [`mirrorlog`](#binmirrorlog) if you need such behaviour.
Arguments do not need to be quoted, but it is advised to do so either way.

```shell
/bin/deeplog "Hello World!"
```

You may also pipe output to it directly:

**Bash:**  
```shell
some_command_with_output | /bin/deeplog
```

**Execline:**  
```shell
/bin/pipeline { some_command_with_output } /bin/deeplog
```

#### `/bin/mirrorlog`

Exactly the same as [`deeplog`](#bindeeplog), except that it also outputs to the invoking shell.

#### `/bin/deeperr`

Send output directly to the attached Docker daemon's stderr file descriptor (e.g. the docker-compose container output).  
The sent lines are not mirrored to the terminal! See [`mirrorerr`](#binmirrorerr) if you need such behaviour.
Arguments do not need to be quoted, but it is advised to do so either way.

```shell
/bin/deeperr "Hello World!"
```

You may also pipe output to it directly:

**Bash:**  
```shell
some_command_with_output | /bin/deeplog
```

**Execline:**  
```shell
/bin/pipeline { some_command_with_output } /bin/deeplog
```

#### `/bin/mirrorerr`

Exactly the same as [`deeperr`](#bindeeperr), except that it also outputs to the invoking shell.

#### `/bin/prefixlog`

Apply a prefix to pipelined output.

**Bash:**  
```shell
some_command_with_output | /bin/prefixlog "My Prefix:"
```

**Execline:**  
```shell
/bin/pipeline { some_command_with_output } /bin/prefixlog "My Prefix:"
```

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
$ /usr/bin/containerip
172.21.0.1
```

#### `/usr/bin/hostip`

Get the internal IP address of the host, running the Docker daemon.

```shell
$ /usr/bin/hostip
172.21.0.1
```

#### `/usr/bin/awaits`

Wait for a given service to be reachable, then exit. This is actually the same functionality as described in ['Wait for external service connections'](#wait-for-external-service-connections) but provided solely to give you the ability of waiting for services whenever this suits your setup best, and not always at the very beginning of the startup process.

```shell
$ /usr/bin/awaits google.com 80 60 5
awaiting service at 'google.com:80'...
service not ready yet, retrying in 3 seconds...
# ...
connection to service at 'google.com:80' succeeded.
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
