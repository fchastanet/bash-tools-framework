---
title: Framework Overview
linkTitle: Framework Overview
description: Overview of the Bash Tools Framework functions and namespaces
type: docs
weight: 1001
creationDate: 2026-03-01
lastUpdated: 2026-03-01
version: 1.0
---

{{< articles-list >}}

This framework is a collection of several bash functions and commands that helps you to lint files, generate shell
documentation, compile bash files, and many more, ...

The Bash Tools Framework provides 150+ unit-tested functions organized by namespace. This section provides an overview
of the available namespaces and their key functions.

## 1. Generated Documentation

The complete function reference documentation is automatically generated from source code using shdoc. This
documentation includes detailed information about:

- Function parameters
- Return values
- Exit codes
- Usage examples
- Environment variables

To generate the documentation:

```bash
bin/doc
```

## 2. Framework Overview

Here an excerpt of the namespaces available in Bash tools framework:

- `Apt`: several functions to abstract the use of ubuntu apt-get function. these functions are using some default
  arguments and manage retry automatically.
  - `Linux::Apt::addRepository`
  - `Linux::Apt::install`
  - `Linux::Apt::remove`
  - `Linux::Apt::update`
- `Args`: functions to ease some recurrent arguments like -h|--help to display help
- `Array`: functions to ease manipulation of bash arrays like `Array::clone` or `Array::contains` that checks if an
  element is contained in an array
- `Assert`: various checks like
  - `Assert::expectUser`, `Assert::expectNonRootUser`, `Assert::expectRootUser` exits with message if current user is
    not the expected one
  - `Assert::commandExists` checks if command specified exists or exits with error message if not
  - `Assert::windows` determines if the script is executed under windows (git bash, wsl)
  - `Assert::validPath` checks if path provided is a valid linux path, it doesn't have to exist yet
  - `Assert::bashFrameworkFunction` checks if given name respects naming convention of this framework's functions
  - ...
- `Backup::file`, `Backup::dir` allows to create a backup of a file or a directory in a folder configured in a .env file
  managed by the framework (see `Env::requireLoad`)
- `Aws`: Aim is to abstract the use of some aws cli commands, for the moment only `Aws::imageExists` has been
  implemented allowing to check that a docker image exists with tags provided on AWS ecr(AWS docker repository)
- `Bats::installRequirementsIfNeeded` allows to install bats vendor requirements for this project, it uses mainly the
  useful function `Git::shallowClone`
- `Cache` : various cache methods to provide files or env variable with expiration management
- `Command::captureOutputAndExitCode` calls a command capturing output and exit code and displaying it also to error
  output to follow command's progress
- `Conf` : allows to manage the loading of .env file that contains configuration used by some functions of this
  framework.
- `Database` : abstraction of several mysql queries, like:
  - `Database::dump` dump db limited to optional table list
  - `Database::query` mysql query on a given db
  - `Database::dropTable` drop table if exists
  - `Database::dropDb` drop database if exists
  - `Database::createDb` create database if not already existing
  - `Database::isTableExists` check if table exists on given db
  - `Database::ifDbExists` check if given database exists
  - all these methods need to call `Database::newInstance` in order to reference target db connection
- `Dns` : various methods like `Dns::pingHost` or allowing etc/hosts manipulation.
- `Docker` : various docker cli abstractions that allowed to construct `bin/buildPushDockerImage` command.
- `Env` : functions allowing to load env variables or to alter them like `Env::pathAppend` allowing to add a bin path to
  `PATH` variable
- `File` : files and file paths manipulations.
- `Filters` : various functions to filter files using grep, awk or sed eg: `Filters::bashFrameworkFunctions` allows to
  find all the bash framework functions used in a file
- `Git` : provides git abstractions like `Git::cloneOrPullIfNoChange`, `Git::pullIfNoChanges` or `Git::shallowClone`
- `Install` : copy directory or file, backup them before if needed.
- `Github` : major feature is install automatically latest binary release using `Github::upgradeRelease`
- `Log::display\*` output colored message on error output and log the message
  - `Log::fatal` error message in red bold and exits with code 1
  - `Log::displayError` error message in red
  - `Log::displayWarning` warning message in yellow
  - `Log::displayInfo` info message in white on lightBlue
  - `Log::displaySuccess` success message in green
  - `Log::displayDebug` debug message in gray
- `Log::log\*` output message in a log file
  - `Log::logError`
  - `Log::logWarning`
  - `Log::logInfo`
  - `Log::logSuccess`
  - `Log::logDebug`
- `Log::rotate` automatically rotates the log file, this function is used internally by `Log::log\*` functions.
- `OS`: ubuntu related functions
- `Profiles`: methods mainly used by [Bash-dev-env project](https://fchastanet.github.io/bash-dev-env/#/) that allows to
  indicate scripts list to install with the ability to include all the dependencies recursively. This file
  `src/Profiles/lintDefinitions.sh` is the precursor of a first bash interface implementation.
- `Retry`: retry a command on failure easily
- `ShellDoc`: this framework shell documentation generation
- `Ssh`: mainly `Ssh::fixAuthenticityOfHostCantBeEstablished`
- `Sudo`: executes command as sudo if needed
- `UI`
  - `UI::askToContinue` ask the user if he wishes to continue a process
  - `UI::askYesNo` ask the user a confirmation
  - `UI::askToIgnoreOverwriteAbort` ask the user to ignore(i), overwrite(o) or abort(a)
- `Version`
  - `Version::checkMinimal` ensure that command exists with expected version
  - `Version::compare` compares two versions
- `Wsl`: commands wslvar and wslpath are expensive, avoid multiple calls using cache
- `src/_standalone` regroups methods that do not respect framework naming conventions like `assert_lines_count` that is
  used to assert the number of lines of output in bats tests

## 3. Development Environment

### 3.1. Precommit hook

This repository uses pre-commit software to ensure every commits respects a set of rules specified by the
`.pre-commit-config.yaml` file. It supposes pre-commit software is [installed](https://pre-commit.com/#install) in your
environment.

You also have to execute the following command to enable it:

```bash
pre-commit install --hook-type pre-commit --hook-type pre-push
```

### 3.2. UT

All the methods of this framework are unit tested, you can run the unit tests using the following command

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

### 3.3. Debug bats

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

The web page uses [Hugo](https://gohugo.io/) with the [Docsy](https://www.docsy.dev/) theme to generate a static
documentation site.

To preview the website locally, you need to clone my-documents repository

```bash
git clone git@github.com:fchastanet/my-documents.git
```

And run the following command from the root of this repository:

```bash
SITE=bash-tools-framework make start-site
```

Navigate to <http://localhost:1313/bash-tools-framework/>

## 4. Troubleshooting

### 4.1. compile.bats embed not working on alpine investigation

exit code 127 is returned but process seems to go until the end. This error only occurs on alpine.

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

Strace didn't helped me a lot. But as I added recently this option `shopt -u lastpipe`, I removed it from compile binary
and the issue disappeared.

As I was suspecting the while piped inside `Compiler::Embed::inject`. I added the following code in this function to
remove the tracing just after the error occurs:

```bash
trap 'set +x' EXIT
set -x
```

It allows me to find that the last command executed was `read -r line`.

Finally I understand that the issue comes when `read -r line` exits with code 1 because of end of file.

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

## 5. External Resources

For comprehensive guides on Bash best practices, please refer to these documents:

- [General Bash Best Practices](https://fchastanet.github.io/my-documents/docs/bash-scripts/basic-best-practices/) -
  Core Bash scripting practices
- [Linux Commands Best Practices](https://fchastanet.github.io/my-documents/docs/bash-scripts/linux-commands-best-practices/)
  \- Effective Linux command usage
- [Bats Best Practices](https://fchastanet.github.io/my-documents/docs/bash-scripts/bats-best-practices/) - Testing best
  practices with Bats

## 6. Related Projects

This framework is part of a suite of projects:

- [My Documents](https://fchastanet.github.io/my-documents/)
- [Bash Tools](https://fchastanet.github.io/bash-tools/)
- [Bash Dev Env](https://fchastanet.github.io/bash-dev-env/)
- [Bash Compiler](https://fchastanet.github.io/bash-compiler/)
