# Bash Tools Framework

## 1. Excerpt

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

## 2. Usage

simply add these lines to your script

```bash
#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/myCommand
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

# shellcheck disable=SC2034
SCRIPT_NAME=${0##*/}
REAL_SCRIPT_FILE="$(readlink -e "$(realpath "${BASH_SOURCE[0]}")")"
# shellcheck disable=SC2034
CURRENT_DIR="$(cd "$(readlink -e "${REAL_SCRIPT_FILE%/*}")" && pwd -P)"
BIN_DIR="${CURRENT_DIR}"
ROOT_DIR="$(cd "${BIN_DIR}/<% ${ROOT_DIR_RELATIVE_TO_BIN_DIR} %>" && pwd -P)"
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
- `# ROOT_DIR_RELATIVE_TO_BIN_DIR=..` it allows to compute the ROOT_DIR variable
  relative to this target bin file
- `# FUNCTIONS` is a placeholder that will be used to inject the functions of
  the framework that you are using in your script.

Then use the following command to generate your file.

**Eg:**

Let's say your source file is named `src/_binaries/myCommand.sh`, then use the
following command
`bin/constructBinFile "src/_binaries/myCommand.sh" "src" "bin" "."`
