# bash-tools-framework

<!-- remove -->

> **_NOTE:_** Documentation is best viewed on
> [github-pages](https://fchastanet.github.io/bash-tools-framework/)

<!-- endRemove -->

> [!TIP|label:Checkout related projects of this suite]
>
> - **[Bash Tools Framework](https://fchastanet.github.io/bash-tools-framework/)**
> - [Bash Tools](https://fchastanet.github.io/bash-tools/)
> - [Bash Dev Env](https://fchastanet.github.io/bash-dev-env/)

<!-- prettier-ignore-start -->
<!-- markdownlint-capture -->
<!-- markdownlint-disable MD013 -->

[![CI/CD](
  https://github.com/fchastanet/bash-tools-framework/actions/workflows/lint-test.yml/badge.svg
)](
  https://github.com/fchastanet/bash-tools-framework/actions?query=workflow%3A%22Lint+and+test%22+branch%3Amaster
)
[![ProjectStatus](
  http://opensource.box.com/badges/active.svg
)](
  http://opensource.box.com/badges
  'Project Status'
)
[![DeepSource](
  https://deepsource.io/gh/fchastanet/bash-tools-framework.svg/?label=active+issues&show_trend=true
)](
  https://deepsource.io/gh/fchastanet/bash-tools-framework/?ref=repository-badge
)
[![DeepSource](
  https://deepsource.io/gh/fchastanet/bash-tools-framework.svg/?label=resolved+issues&show_trend=true
)](
  https://deepsource.io/gh/fchastanet/bash-tools-framework/?ref=repository-badge
)
[![AverageTimeToResolveAnIssue](
  http://isitmaintained.com/badge/resolution/fchastanet/bash-tools-framework.svg
)](
  http://isitmaintained.com/project/fchastanet/bash-tools-framework
  'Average time to resolve an issue'
)
[![PercentageOfIssuesStillOpen](
  http://isitmaintained.com/badge/open/fchastanet/bash-tools-framework.svg
)](
  http://isitmaintained.com/project/fchastanet/bash-tools-framework
  'Percentage of issues still open'
)
<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

- [1. Excerpt](#1-excerpt)
  - [1.1. Build tools](#11-build-tools)
  - [1.2. Compilation tools](#12-compilation-tools)
  - [1.3. Internal tools](#13-internal-tools)
- [3. Development Environment](#3-development-environment)
  - [3.1. Install dev dependencies](#31-install-dev-dependencies)
  - [3.2. UT](#32-ut)
  - [3.3. connect to container manually](#33-connect-to-container-manually)
  - [3.4. auto generated bash doc](#34-auto-generated-bash-doc)
  - [3.5. github page](#35-github-page)
- [4. Acknowledgements](#4-acknowledgements)

## 1. Excerpt

This is a collection of several bash functions and commands that helps you to
lint files, generate shell documentation and compile bash files.

### 1.1. Build tools

- **awkLint** : Lint all files with .awk extension in specified folder.
- **dockerLint** : hadolint wrapper, auto installing hadolint
- **shellcheckLint** : shellcheck wrapper, auto installing shellcheck
- **generateShellDoc**: find all .sh files and generate shDoc in markdown format
  in the specified target directory

### 1.2. Compilation tools

- **compile** : Inlines all the functions used in the script given in parameter
- **constructBinFile** : create binary file from a srcFile

### 1.3. Internal tools

- **test** : test this framework by launching bats inside docker container with
  the needed dependencies
- **doc** : generate markdown documentation for this framework
- **runBuildContainer** : run docker container with the Dockerfile of this
  project, allowing to build doc and run tests

## 3. Development Environment

### 3.1. Install dev dependencies

Dependencies are automatically installed when used.

`bin/test` script will install the following libraries inside `vendor` folder:

- [bats-core/bats-core](https://github.com/bats-core/bats-core.git)
- [bats-core/bats-support](https://github.com/bats-core/bats-support.git)
- [bats-core/bats-assert](https://github.com/bats-core/bats-assert.git)
- [Flamefire/bats-mock](https://github.com/Flamefire/bats-mock.git)

`./bin/doc` script will install:

- [fchastanet/tomdoc.sh](https://github.com/fchastanet/tomdoc.sh.git)

To avoid checking for libraries update and have an impact on performance, a file
is created in vendor dir.

- `vendor/.tomdocInstalled`
- `vendor/.batsInstalled` You can remove these files to force the update of the
  libraries, or just wait 24 hours that the timeout expires.

### 3.2. UT

All the methods of this framework are unit tested, you can run the unit tests
using the following command

```bash
./bin/test -r src
```

Launch UT on different environments:

```bash
VENDOR="alpine" BASH_TAR_VERSION=4.4 BASH_IMAGE=bash SKIP_BUILD=0 SKIP_USER=1 ./bin/test -r tests
VENDOR="alpine" BASH_TAR_VERSION=5.0 BASH_IMAGE=bash SKIP_BUILD=0 SKIP_USER=1 ./bin/test -r tests
VENDOR="alpine" BASH_TAR_VERSION=5.1 BASH_IMAGE=bash SKIP_BUILD=0 SKIP_USER=1 ./bin/test -r tests

VENDOR="ubuntu" BASH_TAR_VERSION=4.4 BASH_IMAGE=ubuntu:20.04 SKIP_BUILD=0 SKIP_USER=1 ./bin/test -r tests
VENDOR="ubuntu" BASH_TAR_VERSION=5.0 BASH_IMAGE=ubuntu:20.04 SKIP_BUILD=0 SKIP_USER=1 ./bin/test -r tests
VENDOR="ubuntu" BASH_TAR_VERSION=5.1 BASH_IMAGE=ubuntu:20.04 SKIP_BUILD=0 SKIP_USER=1 ./bin/test -r tests
```

### 3.3. connect to container manually

Alpine with bash version 4.4

```bash
docker run --rm -it -w /bash -v "$(pwd):/bash" --entrypoint="" --user 1000:1000 bash-tools-alpine-4.4-user bash
```

Ubuntu with bash version 5.1

```bash
docker run --rm -it -w /bash -v "$(pwd):/bash" --entrypoint="" --user 1000:1000 bash-tools-ubuntu-5.1-user bash
```

### 3.4. auto generated bash doc

generated by running

```bash
./bin/doc
```

### 3.5. github page

The web page uses [Docsify](https://docsify.js.org/) to generate a static web
site.

It is recommended to install docsify-cli globally, which helps initializing and
previewing the website locally.

`npm i docsify-cli -g`

Run the local server with docsify serve.

`docsify serve pages`

Navigate to <http://localhost:3000/>

## 4. Acknowledgements

This project is using [bash-tpl](https://github.com/TekWizely/bash-tpl) in order
to compile several bash files into one files.

Like so many projects, this effort has roots in many places.

I would like to thank particularly Bazyli Brzóska for his work on the project
[Bash Infinity](https://github.com/niieani/bash-oo-framework). Framework part of
this project is largely inspired by his work(some parts copied). You can see his
[blog](https://invent.life/project/bash-infinity-framework) too that is really
interesting
