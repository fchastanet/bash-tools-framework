# bash-tools-framework

<!-- remove -->

> **_NOTE:_** Documentation is best viewed on
> [github-pages](https://fchastanet.github.io/bash-tools-framework/)

<!-- endRemove -->

> **_TIP:_** Checkout related projects of this suite
>
> - [My documents](https://fchastanet.github.io/my-documents/)
> - **[Bash Tools Framework](https://fchastanet.github.io/bash-tools-framework/)**
> - [Bash Tools](https://fchastanet.github.io/bash-tools/)
> - [Bash Dev Env](https://fchastanet.github.io/bash-dev-env/)
> - [Bash Compiler](https://fchastanet.github.io/bash-compiler/)

<!-- markdownlint-capture -->

<!-- markdownlint-disable MD013 -->

[![GitHub release (latest SemVer)](https://img.shields.io/github/release/fchastanet/bash-tools-framework?logo=github&sort=semver)](https://github.com/fchastanet/bash-tools-framework/releases)
[![GitHubLicense](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)](https://github.com/fchastanet/bash-tools-framework/blob/master/LICENSE)
[![CI/CD](https://github.com/fchastanet/bash-tools-framework/actions/workflows/lint-test.yml/badge.svg)](https://github.com/fchastanet/bash-tools-framework/actions?query=workflow%3A%22Lint+and+test%22+branch%3Amaster)
[![ProjectStatus](http://opensource.box.com/badges/active.svg)](http://opensource.box.com/badges "Project Status")
[![DeepSource](https://deepsource.io/gh/fchastanet/bash-tools-framework.svg/?label=active+issues&show_trend=true)](https://deepsource.io/gh/fchastanet/bash-tools-framework/?ref=repository-badge)
[![DeepSource](https://deepsource.io/gh/fchastanet/bash-tools-framework.svg/?label=resolved+issues&show_trend=true)](https://deepsource.io/gh/fchastanet/bash-tools-framework/?ref=repository-badge)
[![AverageTimeToResolveAnIssue](http://isitmaintained.com/badge/resolution/fchastanet/bash-tools-framework.svg)](http://isitmaintained.com/project/fchastanet/bash-tools-framework "Average time to resolve an issue")
[![PercentageOfIssuesStillOpen](http://isitmaintained.com/badge/open/fchastanet/bash-tools-framework.svg)](http://isitmaintained.com/project/fchastanet/bash-tools-framework "Percentage of issues still open")

<!-- markdownlint-restore -->

- [1. Excerpt](#1-excerpt)
  - [1.1. Compile command](#11-compile-command)
  - [1.2. Build tools](#12-build-tools)
  - [1.3. Internal tools](#13-internal-tools)
- [2. Framework](#2-framework)
  - [2.1. Excerpt](#21-excerpt)
  - [2.2. FrameworkLint](#22-frameworklint)
  - [2.3. Best practices](#23-best-practices)
- [3. Development Environment](#3-development-environment)
  - [3.1. Install dev dependencies](#31-install-dev-dependencies)
  - [3.2. Precommit hook](#32-precommit-hook)
  - [3.3. UT](#33-ut)
    - [3.3.1. Debug bats](#331-debug-bats)
  - [3.4. connect to container manually](#34-connect-to-container-manually)
  - [3.5. auto generated bash doc](#35-auto-generated-bash-doc)
  - [3.6. github page](#36-github-page)
- [4. Troubleshooting](#4-troubleshooting)
  - [4.1. compile.bats embed not working on alpine investigation](#41-compilebats-embed-not-working-on-alpine-investigation)
- [5. Acknowledgements](#5-acknowledgements)

## 1. Excerpt

[Full documentation can be found here](/#/FrameworkIndex) but here an excerpt of
the capabilities of this framework. This framework is a collection of several
bash functions and commands that helps you to lint files, generate shell
documentation, compile bash files, and many more, ...

### 1.1. Compile command

New compiler (GoLang implementation)

- using generated binary

```bash
export PATH=$PATH:/home/wsl/fchastanet/bash-compiler/bin
FRAMEWORK_ROOT_DIR=$(pwd) bash-compiler \
  src/_binaries/commandDefinitions/shellcheckLint-binary.yaml
```

- using go interpreter (has to be executed from bash-compiler folder)

```bash
export FRAMEWORK_ROOT_DIR=/home/wsl/fchastanet/bash-dev-env/vendor/bash-tools-framework
go run ./cmd/bash-compiler "${FRAMEWORK_ROOT_DIR}/src/_binaries/commandDefinitions/shellcheckLint-binary.yaml"
```

- compile every `*-binary.yaml` files at once

```bash
export FRAMEWORK_ROOT_DIR=/home/wsl/fchastanet/bash-dev-env/vendor/bash-tools-framework
go run ./cmd/bash-compiler $(find "${BASH_TOOLS_ROOT_DIR}/src/_binaries" -name '*-binary.yaml' -print)
```

see related documentation
[Bash-Compiler](https://github.com/fchastanet/bash-compiler).

### 1.2. Build tools

- **awkLint** : Lint all files with .awk extension in specified folder.
- **dockerLint** : hadolint wrapper, auto installing hadolint
- **shellcheckLint** : shellcheck wrapper, auto installing shellcheck

### 1.3. Internal tools

- **test.sh** : test this framework by launching bats inside docker container
  with the needed dependencies
- **doc** : generate markdown documentation for this framework

## 2. Framework

### 2.1. Excerpt

Here an excerpt of the namespaces available in Bash tools framework:

- Apt : several functions to abstract the use of ubuntu apt-get function. these
  functions ar using some default arguments and manage retry automatically.
  - Linux::Apt::addRepository
  - Linux::Apt::install
  - Linux::Apt::remove
  - Linux::Apt::update
- Args : functions to ease some recurrent arguments like -h|--help to display
  help
- Array : functions to ease manipulation of bash arrays like Array::clone or
  Array::contains that checks if an element is contained in an array
- Assert : various checks like
  - Assert::expectUser, Assert::expectNonRootUser, Assert::expectRootUser exits
    with message if current user is not the expected one
  - Assert::commandExists checks if command specified exists or exits with error
    message if not
  - Assert::windows determines if the script is executed under windows (git
    bash, wsl)
  - Assert::validPath checks if path provided is a valid linux path, it doesn't
    have to exist yet
  - Assert::bashFrameworkFunction checks if given name respects naming
    convention of this framework's functions
  - ...
- Backup::file, Backup::dir allows to create a backup of a file or a directory
  in a folder configured in a .env file managed by the framework (see
  Env::requireLoad)
- Aws : Aim is to abstract the use of some aws cli commands, for the moment only
  Aws::imageExists has been implemented allowing to check that a docker image
  exists with tags provided on AWS ecr(AWS docker repository)
- Bats::installRequirementsIfNeeded allows to install bats vendor requirements
  for this project, it uses mainly the useful function Git::shallowClone
- Cache : various cache methods to provide files or env variable with expiration
  management
- Command::captureOutputAndExitCode calls a command capturing output and exit
  code and displaying it also to error output to follow command's progress
- Compiler : various function used by `bin/compiler` script allowing to generate
  binaries using the functions of this framework (see
  [Compile command](doc/CompileCommand.md)).
- Conf : allows to manage the loading of .env file that contains configuration
  used by some functions of this framework.
- Database : abstraction of several mysql queries, like:
  - Database::dump dump db limited to optional table list
  - Database::query mysql query on a given db
  - Database::dropTable drop table if exists
  - Database::dropDb drop database if exists
  - Database::createDb create database if not already existing
  - Database::isTableExists check if table exists on given db
  - Database::ifDbExists check if given database exists
  - all these methods need to call Database::newInstance in order to reference
    target db connection
- Dns : various methods like Dns::pingHost or allowing etc/hosts manipulation.
- Docker : various docker cli abstractions that allowed to construct
  `bin/buildPushDockerImage` command.
- Embed : functions that allows `bin/compiler` to manage `EMBED directives` (see
  [Compile command](doc/CompileCommand.md)).
- Env : functions allowing to load env variables or to alter them like
  Env::pathAppend allowing to add a bin path to `PATH` variable
- File : files and file paths manipulations.
- Filters : various functions to filter files using grep, awk or sed eg:
  Filters::bashFrameworkFunctions allows to find all the bash framework
  functions used in a file
- Framework : Framework::loadConfig loads `.framework-config` configuration
  file.
- Git : provides git abstractions like Git::cloneOrPullIfNoChange,
  Git::pullIfNoChanges or Git::shallowClone
- Install : copy directory or file, backup them before if needed.
- Github : major feature is install automatically latest binary release using
  `Github::upgradeRelease`
- Log::display\* output colored message on error output and log the message
  - Log::fatal error message in red bold and exits with code 1
  - Log::displayError error message in red
  - Log::displayWarning warning message in yellow
  - Log::displayInfo info message in white on lightBlue
  - Log::displaySuccess success message in green
  - Log::displayDebug debug message in gray
- Log::log\* output message in a log file
  - Log::logError
  - Log::logWarning
  - Log::logInfo
  - Log::logSuccess
  - Log::logDebug
- Log::rotate automatically rotates the log file, this function is used
  internally by Log::log\* functions.
- OS : ubuntu related functions
- Profiles : methods mainly used by
  [Bash-dev-env project](https://fchastanet.github.io/bash-dev-env/#/) that
  allows to indicate scripts list to install with the ability to include all the
  dependencies recursively. This file `src/Profiles/lintDefinitions.sh` is the
  precursor of a first bash interface implementation.
- Retry : retry a command on failure easily
- ShellDoc : this framework shell documentation generation
- Ssh : mainly Ssh::fixAuthenticityOfHostCantBeEstablished
- Sudo : executes command as sudo if needed
- UI
  - UI::askToContinue ask the user if he wishes to continue a process
  - UI::askYesNo ask the user a confirmation
  - UI::askToIgnoreOverwriteAbort ask the user to ignore(i), overwrite(o) or
    abort(a)
- Version
  - Version::checkMinimal ensure that command exists with expected version
  - Version::compare compares two versions
- Wsl : commands wslvar and wslpath are expensive, avoid multiple calls using
  cache
- |`src/_standalone` regroups methods that do not respect framework naming
  conventions like assert_lines_count that is used to assert the number of lines
  of output in bats tests

### 2.2. FrameworkLint

Lint files of the current repository

- check if all Namespace::functions are existing in the framework
- check that function defined in a .sh is correctly named
- check that each framework function has a bats file associated (warning if not)
- check that `REQUIRE` directive `AS` ids are not duplicated
- check for `# FUNCTIONS`, `# REQUIREMENTS` and `# ENTRYPOINT` presence
- check `# FUNCTIONS` placeholder is defined before `# REQUIREMENTS`
- check `# REQUIREMENTS` placeholder is defined before `# ENTRYPOINT`

This linter is used in precommit hooks, see
[.pre-commit-config.yaml](https://github.com/fchastanet/bash-tools-framework/blob/master/.pre-commit-config.yaml).

### 2.3. Best practices

**DISCLAIMER:** Some of the best practices mentioned in this document are not
applied in this project because I wrote some of them while writing this project.

[General Bash best practices](https://github.com/fchastanet/my-documents/blob/master/HowTo/HowTo-Write-Bash-Scripts/00-Basic-BestPractices.md)
[Linux Best practices](https://github.com/fchastanet/my-documents/blob/master/HowTo/HowTo-Write-Bash-Scripts/10-LinuxCommands-BestPractices.md)
[Bats Best practices](https://github.com/fchastanet/my-documents/blob/master/HowTo/HowTo-Write-Bash-Scripts/20-Bats-BestPractices.md)

`@embed` keyword is really useful to inline configuration files. However to run
framework function using sudo, it is recommended to call the same binary but
passing options to change the behavior. This way the content of the script file
does not seem to be obfuscated.

## 3. Development Environment

### 3.1. Install dev dependencies

Dependencies are automatically installed when used.

`bin/installRequirements` script will install the following libraries inside
`vendor` folder:

- [bats-core/bats-core](https://github.com/bats-core/bats-core.git)
- [bats-core/bats-support](https://github.com/bats-core/bats-support.git)
- [bats-core/bats-assert](https://github.com/bats-core/bats-assert.git)
- [Flamefire/bats-mock](https://github.com/Flamefire/bats-mock.git)
- hadolint
- shellcheck

`bin/doc` script will install:

- [reconquest/shdoc](https://github.com/reconquest/shdoc)
- hadolint
- shellcheck

To avoid checking for libraries update and have an impact on performance, a file
is created in vendor dir.

- `vendor/.shdocInstalled`
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
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 -r src -j 30
```

Launch UT on different environments:

```bash
./test.sh scrasnups/build:bash-tools-ubuntu-4.4 -r src -j 30
./test.sh scrasnups/build:bash-tools-ubuntu-5.0 -r src -j 30
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 -r src -j 30
./test.sh scrasnups/build:bash-tools-alpine-4.4 -r src -j 30
./test.sh scrasnups/build:bash-tools-alpine-5.0 -r src -j 30
./test.sh scrasnups/build:bash-tools-alpine-5.3 -r src -j 30
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
bin/doc
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

## 4. Troubleshooting

### 4.1. compile.bats embed not working on alpine investigation

exit code 127 is returned but process seems to go until the end. This error only
occurs on alpine.

commands to compile and debug:

```bash
# run docker alpine interactively
docker run --rm -it -w /bash -v "$(pwd):/bash" --entrypoint="" --user 1000:1000 build:bash-tools-alpine-4.4-user bash

# launch bats test that fails
vendor/bats/bin/bats -r src/_binaries/compile.bats --filter embed

# launch directly compile command that returns the same exit code
bin/compile src/_binaries/testsData/bin/embed.sh --template-dir src --bin-dir bin --root-dir $PWD --src-dir src/_binaries/testsData/src
echo $? # prints 127

# try to get more logs
KEEP_TEMP_FILES=1 BASH_FRAMEWORK_DISPLAY_LEVEL=4 bin/compile \
  src/_binaries/testsData/bin/embed.sh \
  --template-dir src \
  --bin-dir bin \
  --root-dir "${PWD}" \
  --src-dir src/_binaries/testsData/src

# try to use strace
docker run --rm -it \
  -w /bash -v "$(pwd):/bash" \
  --entrypoint="" \
  build:bash-tools-alpine-4.4-user bash
apk update
apk add strace
```

Strace didn't helped me a lot. But as I added recently this option
`shopt -u lastpipe`, I removed it from compile binary and the issue disappeared.

As I was suspecting the while piped inside `Compiler::Embed::inject`. I added
the following code in this function to remove the tracing just after the error
occurs:

```bash
trap 'set +x' EXIT
set -x
```

It allows me to find that the last command executed was `read -r line`.

Finally I understand that the issue comes when `read -r line` exits with code 1
because of end of file.

previous simplified code:

```bash
cat file | {
  local line
  while IFS="" read -r line; do
    # ...
  done
}
```

Resulting in exit code 127 because of pipe and `shopt -u lastpipe`.

Fixed code is to remove error if :

```bash
cat file | {
  local line
  while true; do
    local status=0
    IFS="" read -r line || status=$?
    if [[ "${status}" = "1" ]]; then
      # end of file
      return 0
    elif [[ "${status}" != "0" ]]; then
      # other error
      return "${status}"
    fi
    # ...
  done
}
```

## 5. Acknowledgements

Like so many projects, this effort has roots in many places.

I would like to thank particularly Bazyli Brzóska for his work on the project
[Bash Infinity](https://github.com/niieani/bash-oo-framework). Framework part of
this project is largely inspired by his work(some parts copied). You can see his
[blog](https://invent.life/project/bash-infinity-framework) too that is really
interesting
