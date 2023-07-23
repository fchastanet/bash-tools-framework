#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

setup() {
  export TMPDIR="${BATS_RUN_TMPDIR}"

  unset HOME
  unset ROOT_DIR
  export BASH_FRAMEWORK_INITIALIZED=0
  export BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=0
}

teardown() {
  unstub_all
}

generateLogs() {
  debugMsg=$(Log::displayDebug "debug" 2>&1)
  expectedDebugMsg="$(echo -e "${__DEBUG_COLOR}DEBUG   - debug${__RESET_COLOR}")"
  infoMsg=$(Log::displayInfo "info" 2>&1)
  expectedInfoMsg="$(echo -e "${__INFO_COLOR}INFO    - info${__RESET_COLOR}")"
  successMsg=$(Log::displaySuccess "success" 2>&1)
  expectedSuccessMsg="$(echo -e "${__SUCCESS_COLOR}SUCCESS - success${__RESET_COLOR}")"
  skippedMsg=$(Log::displaySkipped "skipped" 2>&1)
  expectedSkippedMsg="$(echo -e "${__SKIPPED_COLOR}SKIPPED - skipped${__RESET_COLOR}")"
  helpMsg=$(Log::displayHelp "help" 2>&1)
  expectedHelpMsg="$(echo -e "${__HELP_COLOR}HELP    - help${__RESET_COLOR}")"
  warningMsg=$(Log::displayWarning "warning" 2>&1)
  expectedWarningMsg="$(echo -e "${__WARNING_COLOR}WARN    - warning${__RESET_COLOR}")"
  errorMsg=$(Log::displayError "error" 2>&1)
  expectedErrorMsg="$(echo -e "${__ERROR_COLOR}ERROR   - error${__RESET_COLOR}")"
  fatalMsg=$(
    trap '' EXIT
    Log::fatal 'fatal' 2>&1
  ) || true
  expectedFatalMsg="$(echo -e "${__ERROR_COLOR}FATAL   - fatal${__RESET_COLOR}")"
}

function Log::display::debugLevel { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/Log.debug.env"
  Env::load

  # shellcheck source=src/Log/ZZZ.sh
  source "${srcDir}/Log/ZZZ.sh"

  generateLogs
  [[ "${debugMsg}" == "${expectedDebugMsg}" ]]
  [[ "${infoMsg}" == "${expectedInfoMsg}" ]]
  [[ "${successMsg}" == "${expectedSuccessMsg}" ]]
  [[ "${skippedMsg}" == "${expectedSkippedMsg}" ]]
  [[ "${helpMsg}" == "${expectedHelpMsg}" ]]
  [[ "${warningMsg}" == "${expectedWarningMsg}" ]]
  [[ "${errorMsg}" == "${expectedErrorMsg}" ]]
  [[ "${fatalMsg}" == "${expectedFatalMsg}" ]]
}

function Log::display::infoLevel { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/Log.info.env"
  Env::load

  # shellcheck source=src/Log/ZZZ.sh
  source "${srcDir}/Log/ZZZ.sh"

  generateLogs
  [[ -z "${debugMsg}" ]]
  [[ "${infoMsg}" == "${expectedInfoMsg}" ]]
  [[ "${successMsg}" == "${expectedSuccessMsg}" ]]
  [[ "${skippedMsg}" == "${expectedSkippedMsg}" ]]
  [[ "${helpMsg}" == "${expectedHelpMsg}" ]]
  [[ "${warningMsg}" == "${expectedWarningMsg}" ]]
  [[ "${errorMsg}" == "${expectedErrorMsg}" ]]
  [[ "${fatalMsg}" == "${expectedFatalMsg}" ]]
}

function Log::display::successLevel { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/Log.success.env"
  Env::load

  # shellcheck source=src/Log/ZZZ.sh
  source "${srcDir}/Log/ZZZ.sh"

  generateLogs
  [[ -z "${debugMsg}" ]]
  [[ "${infoMsg}" == "${expectedInfoMsg}" ]]
  [[ "${successMsg}" == "${expectedSuccessMsg}" ]]
  [[ "${skippedMsg}" == "${expectedSkippedMsg}" ]]
  [[ "${helpMsg}" == "${expectedHelpMsg}" ]]
  [[ "${warningMsg}" == "${expectedWarningMsg}" ]]
  [[ "${errorMsg}" == "${expectedErrorMsg}" ]]
  [[ "${fatalMsg}" == "${expectedFatalMsg}" ]]
}

function Log::display::warningLevel { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/Log.warning.env"
  Env::load

  # shellcheck source=src/Log/ZZZ.sh
  source "${srcDir}/Log/ZZZ.sh"

  generateLogs
  [[ -z "${debugMsg}" ]]
  [[ -z "${infoMsg}" ]]
  [[ -z "${successMsg}" ]]
  [[ -z "${skippedMsg}" ]]
  [[ -z "${helpMsg}" ]]
  [[ "${warningMsg}" == "${expectedWarningMsg}" ]]
  [[ "${errorMsg}" == "${expectedErrorMsg}" ]]
  [[ "${fatalMsg}" == "${expectedFatalMsg}" ]]
}

function Log::display::errorLevel { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/Log.error.env"
  Env::load

  # shellcheck source=src/Log/ZZZ.sh
  source "${srcDir}/Log/ZZZ.sh"

  generateLogs
  [[ -z "${debugMsg}" ]]
  [[ -z "${infoMsg}" ]]
  [[ -z "${successMsg}" ]]
  [[ -z "${skippedMsg}" ]]
  [[ -z "${helpMsg}" ]]
  [[ -z "${warningMsg}" ]]
  [[ "${errorMsg}" == "${expectedErrorMsg}" ]]
  [[ "${fatalMsg}" == "${expectedFatalMsg}" ]]
}

function Log::display::offLevel { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/Log.off.env"
  Env::load

  # shellcheck source=src/Log/ZZZ.sh
  source "${srcDir}/Log/ZZZ.sh"

  generateLogs
  [[ -z "${debugMsg}" ]]
  [[ -z "${infoMsg}" ]]
  [[ -z "${successMsg}" ]]
  [[ -z "${skippedMsg}" ]]
  [[ -z "${helpMsg}" ]]
  [[ -z "${warningMsg}" ]]
  [[ -z "${errorMsg}" ]]
  [[ "${fatalMsg}" == "${expectedFatalMsg}" ]]
}
