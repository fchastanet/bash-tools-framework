#!/usr/bin/env bash

declare logFile
ROOT_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
setup() {
  export HOME="/tmp/home"
  mkdir -p /tmp/home
  logFile="$(mktemp -p "${TMPDIR:-/tmp}" -t "bash.framework.XXXXXXXXXXXX")"
}

teardown() {
  rm -f "${logFile}" || true
}

function framework_is_loaded { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_ENV_FILEPATH="" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1

  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
}

function default_value_for_BASH_FRAMEWORK_DISPLAY_LEVEL { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_ENV_FILEPATH="" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1

  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "${__LEVEL_INFO}" ]]
}

function default_value_for_BASH_FRAMEWORK_LOG_LEVEL { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_ENV_FILEPATH="" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1

  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "${__LEVEL_OFF}" ]]
}

function default_value_for_BASH_FRAMEWORK_LOG_FILE { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_ENV_FILEPATH="" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1

  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "/tmp/home/.bash-tools/logs/bash.log" ]]
}

function __BASH_FRAMEWORK_ROOT_PATH { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_ENV_FILEPATH="" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1

  [[ "${__BASH_FRAMEWORK_ROOT_PATH}" = "$(cd "${BATS_TEST_DIRNAME}/../../bash-framework" && pwd)" ]]
}

function __BASH_FRAMEWORK_CALLING_SCRIPT { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_ENV_FILEPATH="" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1

  [[ "${__BASH_FRAMEWORK_CALLING_SCRIPT}" = "$(cd "${BATS_TEST_DIRNAME}/../../vendor/bats/libexec/bats-core" && pwd)" ]]
}

function __BASH_FRAMEWORK_VENDOR_PATH { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_ENV_FILEPATH="" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1

  [[ "${__BASH_FRAMEWORK_VENDOR_PATH}" = "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)" ]]
}

function load_alternative_env_file { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Framework.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "${__LEVEL_ERROR}" ]]
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "${__LEVEL_OFF}" ]] # because log file not provided
}

function load_alternative_env_file_2 { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Framework-debug.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "${__LEVEL_DEBUG}" ]]
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "${__LEVEL_OFF}" ]] # because log file not writable
}

function load_alternative_env_file_2_with_log_file_provided { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Framework-debug-nologfile.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "${__LEVEL_DEBUG}" ]]
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "${__LEVEL_DEBUG}" ]]
}
