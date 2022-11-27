#!/bin/bash

LIB_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd)
ROOT_DIR="$(cd "${LIB_DIR}/.." && pwd)"

# shellcheck source=/lib/common.sh
source "${LIB_DIR}/common.sh"

if (($# < 1)); then
  Log::fatal "missing arguments"
fi
PROFILE="$1"
shift
PREPARE_EXPORT="$1"
shift
SKIP_INSTALL="$1"
shift
SKIP_CONFIGURE="$1"
shift
SKIP_TEST="$1"
shift
CONFIG_LIST=("$@")

export PREPARE_EXPORT

set -o errexit
set -o pipefail
err_report() {
  echo "$0 - Upgrade failure - Error on line $1"
  exit 1
}
trap 'err_report $LINENO' ERR

loadAndCheckConfig "${ROOT_DIR}" || exit 1
Log::displayInfo "Installation $(date '+%Y-%m-%d %H:%M:%S')"

loadProfile "${PROFILE}" "${CONFIG_LIST[@]}"
Log::displayInfo "Will Install ${CONFIG_LIST[*]}"

( # reset counters
  ((INSTALL_COUNT = 0)) || true
  ((INSTALL_ERROR_COUNT = 0)) || true
  ((INSTALL_SUCCESS_COUNT = 0)) || true
  ((INSTALL_INCOMPLETE_COUNT = 0)) || true
  ((INSTALL_WARNING_COUNT = 0)) || true

  ((CONFIG_COUNT = 0)) || true
  ((CONFIG_ERROR_COUNT = 0)) || true
  ((CONFIG_SUCCESS_COUNT = 0)) || true
  ((CONFIG_INCOMPLETE_COUNT = 0)) || true
  ((CONFIG_WARNING_COUNT = 0)) || true

  ((TEST_COUNT = 0)) || true
  ((TEST_ERROR_COUNT = 0)) || true
  ((TEST_SUCCESS_COUNT = 0)) || true
  ((TEST_INCOMPLETE_COUNT = 0)) || true
  ((TEST_WARNING_COUNT = 0)) || true

  ((currentInstallNb = 0)) || true

  stats() {
    local commandStatus="$1"
    local -n successCount=$2
    local -n warningCount=$3
    local -n incompleteCount=$4
    local -n errorCount=$5

    if [[ ! -f /tmp/result.log ]]; then
      return 0
    fi

    local result
    result="$(cat /tmp/result.log || echo "")"
    rm -f /tmp/result.log || true

    # check config result
    local currentSkipCount
    local currentWarningCount
    currentSkipCount="$(echo "${result}" | Functions::removeAnsiCodes | grep -c '^SKIPPED - ')" || true
    currentWarningCount="$(echo "${result}" | Functions::removeAnsiCodes | grep -c '^WARN    - ')" || true

    color="${__TEST_ERROR_COLOR}"
    status=""
    if [[ "${currentWarningCount}" != "0" ]]; then
      ((++warningCount))
    fi
    if [[ "${commandStatus}" = "0" ]]; then
      if [[ "${currentSkipCount}" = "0" ]]; then
        ((++successCount))
        color="${__SUCCESS_COLOR}"
        status="SUCCESS - ${configName} successful"
      else
        ((++incompleteCount))
        color="${__SKIPPED_COLOR}"
        status="SKIPPED - ${configName} skipped"
      fi
    else
      ((++errorCount))
      status="ERROR  - ${configName} in error"
    fi
    # overwrite final TEST line
    echo -e "${color}${status}${__RESET_COLOR}"
  }

  summary() {
    # summary
    UI::drawLine '-'
    if [[ "${SKIP_INSTALL}" = "0" ]]; then
      echo -e "${__SUCCESS_COLOR}${INSTALL_SUCCESS_COUNT}${__RESET_COLOR} / ${__INFO_COLOR}${INSTALL_COUNT}${__RESET_COLOR} installations successful"
      echo -e " - ${__ERROR_COLOR}${INSTALL_ERROR_COUNT} installation(s) with error${__RESET_COLOR}"
      echo -e " - ${__SKIPPED_COLOR}${INSTALL_INCOMPLETE_COUNT} partial installation(s) (check logs marked as skipped)${__RESET_COLOR}"
      echo -e " - ${__WARNING_COLOR}${INSTALL_WARNING_COUNT} installation(s) with warning${__RESET_COLOR}"
    fi
    if [[ "${SKIP_CONFIGURE}" = "0" ]]; then
      echo -e "${__SUCCESS_COLOR}${CONFIG_SUCCESS_COUNT}${__RESET_COLOR} / ${__INFO_COLOR}${CONFIG_COUNT}${__RESET_COLOR} configurations successful"
      echo -e " - ${__ERROR_COLOR}${CONFIG_ERROR_COUNT} configuration(s) with error${__RESET_COLOR}"
      echo -e " - ${__SKIPPED_COLOR}${CONFIG_INCOMPLETE_COUNT} partial configuration(s) (check logs marked as skipped)${__RESET_COLOR}"
      echo -e " - ${__WARNING_COLOR}${CONFIG_WARNING_COUNT} configuration(s) with warning${__RESET_COLOR}"
    fi

    if [[ "${SKIP_TEST}" = "0" ]]; then
      echo -e "${__SUCCESS_COLOR}${TEST_SUCCESS_COUNT}${__RESET_COLOR} / ${__INFO_COLOR}${TEST_COUNT}${__RESET_COLOR} tests successful"
      echo -e " - ${__ERROR_COLOR}${TEST_ERROR_COUNT} error${__RESET_COLOR}"
      echo -e " - ${__SKIPPED_COLOR}${TEST_INCOMPLETE_COUNT} partial test(s) (check logs marked as skipped)${__RESET_COLOR}"
      echo -e " - ${__WARNING_COLOR}${TEST_WARNING_COUNT} test(s) with warning${__RESET_COLOR}"
    fi
  }

  trap 'summary' EXIT INT TERM ABRT

  # install
  for configName in "${CONFIG_LIST[@]}"; do
    ((++currentInstallNb))

    UI::drawLine '-'
    msg="$(UI::textLine "PROCESS - Processing ${configName} (${currentInstallNb}/${#CONFIG_LIST[@]})" " ")"
    echo -e "${__TEST_COLOR}${msg}${__RESET_COLOR}"
    # run install
    installStatus="0"
    if [[ "${SKIP_INSTALL}" = "0" ]]; then
      msg="$(UI::textLine "INSTALL - Installing ${configName}" " ")"
      echo -e "${__TEST_COLOR}${msg}${__RESET_COLOR}"
      ((++INSTALL_COUNT))
      trap 'stats "${installStatus}" INSTALL_SUCCESS_COUNT INSTALL_WARNING_COUNT INSTALL_INCOMPLETE_COUNT INSTALL_ERROR_COUNT && summary' EXIT INT TERM ABRT
      "${SCRIPTS_DIR}/${configName}/install" "${CONFIG_LIST[@]}" 2>&1 | tee /tmp/result.log ||
        installStatus="$?"

      stats "${installStatus}" INSTALL_SUCCESS_COUNT INSTALL_WARNING_COUNT INSTALL_INCOMPLETE_COUNT INSTALL_ERROR_COUNT

      if [[ "${installStatus}" != "0" ]]; then
        # break at first install error
        break
      fi
    fi

    # run configuration
    configStatus="0"
    if [[ "${SKIP_CONFIGURE}" = "0" && "${installStatus}" = "0" ]]; then
      msg="$(UI::textLine "CONFIG  - Configuring ${configName}" " ")"
      echo -e "${__TEST_COLOR}${msg}${__RESET_COLOR}"

      ((++CONFIG_COUNT))

      trap 'stats "${configStatus}" CONFIG_SUCCESS_COUNT CONFIG_WARNING_COUNT CONFIG_INCOMPLETE_COUNT CONFIG_ERROR_COUNT && summary' EXIT INT TERM ABRT
      # shellcheck disable=SC2024
      PATH="${PATH}" PROFILE_NAME="${PROFILE_NAME}" \
        "${SCRIPTS_DIR}/${configName}/configure" "${CONFIG_LIST[@]}" 2>&1 | tee /tmp/result.log ||
        configStatus="$?" || true

      stats "${configStatus}" CONFIG_SUCCESS_COUNT CONFIG_WARNING_COUNT CONFIG_INCOMPLETE_COUNT CONFIG_ERROR_COUNT
      if [[ "${configStatus}" != "0" && -f "${SCRIPTS_DIR}/${configName}/breakOnConfigFailure" ]]; then
        # break if config script error
        break
      fi
    fi

    # run test
    if [[ "${SKIP_TEST}" = "0" && "${installStatus}" = "0" && "${configStatus}" = "0" ]]; then
      msg="$(UI::textLine "TEST    - Testing ${configName}" " ")"
      echo -e "${__TEST_COLOR}${msg}${__RESET_COLOR}"

      testScript="${SCRIPTS_DIR}/${configName}/test"
      ((++TEST_COUNT))

      # run the test
      trap 'stats "${testStatus}" TEST_SUCCESS_COUNT TEST_WARNING_COUNT TEST_INCOMPLETE_COUNT TEST_ERROR_COUNT && summary' EXIT INT TERM ABRT
      testStatus=0
      PATH="${PATH}" PROFILE_NAME="${PROFILE_NAME}" Functions::asUserInheritEnv \
        "${testScript}" "${CONFIG_LIST[@]}" 2>&1 | tee /tmp/result.log || testStatus="$?" || true

      stats "${testStatus}" TEST_SUCCESS_COUNT TEST_WARNING_COUNT TEST_INCOMPLETE_COUNT TEST_ERROR_COUNT
      if [[ "${testStatus}" != "0" && -f "${SCRIPTS_DIR}/${configName}/breakOnTestFailure" ]]; then
        # break if config script error
        break
      fi
    fi
  done
)
