---
title: 'Bash Framework'
permalink: /bash-framework
---

# Bash Framework

All these tools are based on _Bash framework_ with the following features:

- A bootstrap that allows to import automatically .env file in home folder or
  ~/.bash-tools folder in order to load some environment variables
- **import alias** allows to import (only once) a bash file found in following
  folders (in order)
  - vendor/bash-framework
  - vendor
  - calling script path
  - absolute path
- **source alias**, same as import but multiple times import allowed
- Framework
  - **Assert::expectUser** exits with message if current user is not the
    expected one
  - **Assert::expectNonRootUser** exits with message if current user is root
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
  - **Assert::commandExists** check if command specified exists or exits with
    error message if not
  - **Assert::windows** determine if the script is executed under windows (git
    bash, wsl)
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

**Usage:** simply add these lines to your script

```bash
#!/usr/bin/env bash

# load bash-framework
# shellcheck source=bash-framework/_bootstrap.sh
BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$( cd "${BIN_DIR}/.." && pwd )/bash-framework/_bootstrap.sh"

# bash framework is loaded, .env has been loaded (default .env file present in bash-framework is loaded if none exists yet)

# exits with message if this script is executed using root user
Assert::expectNonRootUser

# import some useful apis
import bash-framework/Database
import bash-framework/Array
```

@@@bash_doc_index@@@
