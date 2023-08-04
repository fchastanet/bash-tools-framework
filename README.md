# bash-tools-framework

- [1. Excerpt](#1-excerpt)
  - [1.1. Build tools](#11-build-tools)
  - [1.2. Compile command](#12-compile-command)
  - [1.3. Internal tools](#13-internal-tools)
- [2. Framework](#2-framework)
  - [2.1. Excerpt](#21-excerpt)
  - [2.2. Usage](#22-usage)
- [3. Development Environment](#3-development-environment)
  - [3.1. Install dev dependencies](#31-install-dev-dependencies)
  - [3.2. Precommit hook](#32-precommit-hook)
  - [3.3. UT](#33-ut)
    - [3.3.1. Debug bats](#331-debug-bats)
  - [3.4. connect to container manually](#34-connect-to-container-manually)
  - [3.5. auto generated bash doc](#35-auto-generated-bash-doc)
  - [3.6. github page](#36-github-page)
- [4. Acknowledgements](#4-acknowledgements)

<!-- remove -->

> **_NOTE:_** Documentation is best viewed on
> [github-pages](https://fchastanet.github.io/bash-tools-framework/)

<!-- endRemove -->

> **_TIP:_** Checkout related projects of this suite
>
> - **[Bash Tools Framework](https://fchastanet.github.io/bash-tools-framework/)**
> - [Bash Tools](https://fchastanet.github.io/bash-tools/)
> - [Bash Dev Env](https://fchastanet.github.io/bash-dev-env/)

<!-- prettier-ignore-start -->
<!-- markdownlint-capture -->
<!-- markdownlint-disable MD013 -->
[![GitHubLicense](
  https://img.shields.io/github/license/Naereen/StrapDown.js.svg
)](
  https://github.com/fchastanet/bash-tools-framework/blob/master/LICENSE
)
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

## 1. Excerpt

This is a collection of several bash functions and commands that helps you to
lint files, generate shell documentation and compile bash files.

### 1.1. Build tools

- **awkLint** : Lint all files with .awk extension in specified folder.
- **dockerLint** : hadolint wrapper, auto installing hadolint
- **shellcheckLint** : shellcheck wrapper, auto installing shellcheck
- **generateShellDoc**: find all .sh files and generate shDoc in markdown format
  in the specified target directory

### 1.2. Compile command

- **compile** : Inlines all the functions used in the script given in parameter

see related documentation [Compile command](CompileCommand.md).

### 1.3. Internal tools

- **test** : test this framework by launching bats inside docker container with
  the needed dependencies
- **doc** : generate markdown documentation for this framework
- **runBuildContainer** : run docker container with the Dockerfile of this
  project, allowing to build doc and run tests

## 2. Framework

### 2.1. Excerpt

Here an excerpt of the functions available in Bash tools framework:

- Assert
  - **Assert::expectUser** exits with message if current user is not the
    expected one
  - **Assert::expectNonRootUser** exits with message if current user is root
  - **Assert::commandExists** check if command specified exists or exits with
    error message if not
  - **Assert::windows** determine if the script is executed under windows (git
    bash, wsl)
- Database
  - **Database::dump** dump db limited to optional table list
  - **Database::query** mysql query on a given db
  - **Database::dropTable** drop table if exists
  - **Database::dropDb** drop database if exists
  - **Database::createDb** create database if not already existing
  - **Database::isTableExists** check if table exists on given db
  - **Database::ifDbExists** check if given database exists
  - all these methods need to call **Database::newInstance** in order to
    reference target db connection
- Array
  - **Array::contains** check if an element is contained in an array
- Functions
  - **Functions::quote** quote a string replace ' with \'
  - **Functions::addTrap** add a trap to existing trap or simply set the trap if
    no existing trap
- UI
  - **UI::askToContinue** ask the user if he wishes to continue a process
  - **UI::askYesNo** ask the user a confirmation
  - **UI::askToIgnoreOverwriteAbort** ask the user to ignore(i), overwrite(o) or
    abort(a)
- Version
  - **Version::checkMinimal** ensure that command exists with expected version
  - **Version::compare** compares two versions
- Log::display\* output colored message on error output and log the message
  - **Log::fatal** error message in red bold and exits with code 1
  - **Log::displayError** error message in red
  - **Log::displayWarning** warning message in yellow
  - **Log::displayInfo** info message in white on lightBlue
  - **Log::displaySuccess** success message in green
  - **Log::displayDebug** debug message in grey
- Log::log\* output message in a log file
  - **Log::logError**
  - **Log::logWarning**
  - **Log::logInfo**
  - **Log::logSuccess**
  - **Log::logDebug**

### 2.2. Usage

simply add these lines to your script

```bash
#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/myCommand

# shellcheck disable=SC2034
SCRIPT_NAME=${0##*/}
REAL_SCRIPT_FILE="$(readlink -e "$(realpath "${BASH_SOURCE[0]}")")"
# shellcheck disable=SC2034
CURRENT_DIR="$(cd "$(readlink -e "${REAL_SCRIPT_FILE%/*}")" && pwd -P)"
BIN_DIR="${CURRENT_DIR}"
# shellcheck disable=SC2034
SRC_DIR="<%% echo '${ROOT_DIR}/src' %>"
# shellcheck disable=SC2034
VENDOR_DIR="<%% echo '${ROOT_DIR}/vendor' %>"
# shellcheck disable=SC2034
VENDOR_BIN_DIR="<%% echo '${ROOT_DIR}/vendor/bin' %>"
export PATH="${BIN_DIR}":"${VENDOR_BIN_DIR}":${PATH}

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_commonHeader.sh"

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_colors.sh"

# FUNCTIONS

```

Then add below the rest of your script.

Special comments:

- `# BIN_FILE=${ROOT_DIR}/bin/myCommand` indicates where the resulting file will
  be generated
- `# FUNCTIONS` is a placeholder that will be used to inject the functions of
  the framework that you are using in your script.

Then use the following command to generate your file.

**Eg:**

Let's say your source file is named `src/_binaries/myCommand.sh`, then use the
following command :

```bash
bin/compile src/_binaries/myCommand.sh
```

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

### 3.2. Precommit hook

This repository uses pre-commit software to ensure every commits respects a set
of rules specified by the `.pre-commit-config.yaml` file. It supposes pre-commit
software is [installed](https://pre-commit.com/#install) in your environment.

You also have to execute the following command to enable it:

```bash
pre-commit install --hook-type pre-commit --hook-type pre-push
```

### 3.3. UT

All the methods of this framework are unit tested, you can run the unit tests
using the following command

```bash
./bin/test -r src
```

Launch UT on different environments:

```bash
VENDOR="alpine" BASH_TAR_VERSION=4.4 BASH_IMAGE=bash SKIP_BUILD=0 SKIP_USER=1 ./bin/test -r src
VENDOR="alpine" BASH_TAR_VERSION=5.0 BASH_IMAGE=bash SKIP_BUILD=0 SKIP_USER=1 ./bin/test -r src
VENDOR="alpine" BASH_TAR_VERSION=5.1 BASH_IMAGE=bash SKIP_BUILD=0 SKIP_USER=1 ./bin/test -r src

VENDOR="ubuntu" BASH_TAR_VERSION=4.4 BASH_IMAGE=ubuntu:20.04 SKIP_BUILD=0 SKIP_USER=1 ./bin/test -r src
VENDOR="ubuntu" BASH_TAR_VERSION=5.0 BASH_IMAGE=ubuntu:20.04 SKIP_BUILD=0 SKIP_USER=1 ./bin/test -r src
VENDOR="ubuntu" BASH_TAR_VERSION=5.1 BASH_IMAGE=ubuntu:20.04 SKIP_BUILD=0 SKIP_USER=1 ./bin/test -r src
```

#### 3.3.1. Debug bats

use the following command:

```bash
vendor/bats/bin/bats -r src/Conf/loadNearestFile.bats --trace --verbose-run --filter "Conf::loadNearestFileFileFoundInDir1"
```

### 3.4. connect to container manually

Alpine with bash version 4.4

```bash
docker run --rm -it -w /bash -v "$(pwd):/bash" --entrypoint="" --user 1000:1000 bash-tools-alpine-4.4-user bash
```

Ubuntu with bash version 5.1

```bash
docker run --rm -it -w /bash -v "$(pwd):/bash" --entrypoint="" --user 1000:1000 bash-tools-ubuntu-5.1-user bash
```

### 3.5. auto generated bash doc

generated by running

```bash
./bin/doc
```

### 3.6. github page

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
