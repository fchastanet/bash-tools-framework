---
title: Framework Overview
linkTitle: Framework
description: Overview of the Bash Tools Framework functions and namespaces
type: docs
weight: 3
creationDate: 2026-03-01
lastUpdated: 2026-03-01
---

{{< articles-list >}}

The Bash Tools Framework provides 150+ unit-tested functions organized by namespace. This section provides an overview of the available namespaces and their key functions.

## Available Namespaces

### Apt
Several functions to abstract the use of Ubuntu apt-get function. These functions use default arguments and manage retry automatically.

- `Linux::Apt::addRepository`
- `Linux::Apt::install`
- `Linux::Apt::remove`
- `Linux::Apt::update`

### Args
Functions to ease handling of recurrent arguments like `-h|--help` to display help.

### Array
Functions to ease manipulation of bash arrays:

- `Array::clone` - Clone an array
- `Array::contains` - Checks if an element is contained in an array

### Assert
Various checks and validations:

- `Assert::expectUser`, `Assert::expectNonRootUser`, `Assert::expectRootUser` - Exits with message if current user is not the expected one
- `Assert::commandExists` - Checks if command specified exists or exits with error message
- `Assert::windows` - Determines if the script is executed under Windows (git bash, WSL)
- `Assert::validPath` - Checks if path provided is a valid Linux path (doesn't have to exist yet)
- `Assert::bashFrameworkFunction` - Checks if given name respects naming convention of this framework's functions

### Backup
Create backups of files or directories:

- `Backup::file` - Backup a file in a configured folder
- `Backup::dir` - Backup a directory in a configured folder

### AWS
Abstract AWS CLI commands:

- `Aws::imageExists` - Check that a docker image exists with tags provided on AWS ECR

### Bats
Testing utilities:

- `Bats::installRequirementsIfNeeded` - Install bats vendor requirements

### Cache
Various cache methods to provide files or environment variables with expiration management.

### Command
Command execution utilities:

- `Command::captureOutputAndExitCode` - Calls a command capturing output and exit code, displaying it also to error output to follow command's progress

### Conf
Manage loading of .env files that contain configuration used by framework functions.

### Database
Abstraction of several MySQL queries:

- `Database::dump` - Dump database limited to optional table list
- `Database::query` - MySQL query on a given database
- `Database::dropTable` - Drop table if exists
- `Database::dropDb` - Drop database if exists
- `Database::createDb` - Create database if not already existing
- `Database::isTableExists` - Check if table exists on given database
- `Database::ifDbExists` - Check if given database exists
- All these methods need to call `Database::newInstance` to reference target database connection

### Dns
Various DNS methods:

- `Dns::pingHost` - Ping a host
- Functions for /etc/hosts manipulation

### Docker
Various Docker CLI abstractions. See [Docker Guide](/docs/guides/docker/) for usage examples.

### Env
Functions for managing environment variables:

- `Env::pathAppend` - Add a bin path to `PATH` variable
- `Env::requireLoad` - Load configuration files (see [Config Files Guide](/docs/guides/config-files/))

### File
File and file path manipulation utilities.

### Filters
Various functions to filter files using grep, awk or sed:

- `Filters::bashFrameworkFunctions` - Find all bash framework functions used in a file

### Git
Git abstractions:

- `Git::cloneOrPullIfNoChange`
- `Git::pullIfNoChanges`
- `Git::shallowClone`

### Github
GitHub utilities:

- `Github::upgradeRelease` - Install automatically latest binary release

### Install
Copy directory or file, backup them before if needed.

### Log
Output colored messages and logging:

**Display functions** (output to error output):
- `Log::fatal` - Error message in red bold and exits with code 1
- `Log::displayError` - Error message in red
- `Log::displayWarning` - Warning message in yellow
- `Log::displayInfo` - Info message in white on light blue
- `Log::displaySuccess` - Success message in green
- `Log::displayDebug` - Debug message in gray

**Log functions** (output to log file):
- `Log::logError`
- `Log::logWarning`
- `Log::logInfo`
- `Log::logSuccess`
- `Log::logDebug`
- `Log::rotate` - Automatically rotates the log file (used internally)

### OS
Ubuntu-related functions.

### Profiles
Methods mainly used by [Bash Dev Env project](https://fchastanet.github.io/bash-dev-env/) that allow indicating scripts list to install with the ability to include all dependencies recursively.

### Retry
Retry a command on failure easily.

### ShellDoc
Framework shell documentation generation.

### Ssh
SSH utilities:

- `Ssh::fixAuthenticityOfHostCantBeEstablished`

### Sudo
Execute commands as sudo if needed.

### UI
User interaction functions:

- `UI::askToContinue` - Ask the user if they wish to continue a process
- `UI::askYesNo` - Ask the user a confirmation
- `UI::askToIgnoreOverwriteAbort` - Ask the user to ignore(i), overwrite(o) or abort(a)

### Version
Version comparison utilities:

- `Version::checkMinimal` - Ensure that command exists with expected version
- `Version::compare` - Compare two versions

### Wsl
Windows Subsystem for Linux utilities. Commands wslvar and wslpath are expensive, avoid multiple calls using cache.

### Standalone Functions
`src/_standalone` regroups methods that do not respect framework naming conventions, like `assert_lines_count` that is used to assert the number of lines of output in bats tests.

## Generated Documentation

The complete function reference documentation is automatically generated from source code using shdoc. This documentation includes detailed information about:

- Function parameters
- Return values
- Exit codes
- Usage examples
- Environment variables

To generate the documentation:

```bash
bin/doc
```
