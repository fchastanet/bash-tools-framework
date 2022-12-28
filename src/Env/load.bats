#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
  unset BASH_FRAMEWORK_INITIALIZED
}

teardown() {
  unstub_all
  rm -Rf "${BATS_TMP_DIR}" || true
}

function Env::load::alreadyInitialized { #@test
  export BASH_FRAMEWORK_INITIALIZED=1
  run Env::load
  assert_success
  assert_output ""
}

function Env::load::forceLoadNonExistentFile { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TMP_DIR}/notExists"
  run Env::load
  assert_failure 1
  assert_output --partial "FATAL   - env file not not found - ${BATS_TMP_DIR}/notExists"
}

function Env::load::forceLoadExistentFile { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/.env" "${BATS_TMP_DIR}/.env"
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TMP_DIR}/.env"
  unset HOME
  Env::load || return 1
  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "${__LEVEL_INFO}" ]]
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "${__LEVEL_OFF}" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "${ROOT_DIR}/logs/${SCRIPT_NAME}.log" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}" = "5" ]]
}

function Env::load::loadRootDirConfEnvFile { #@test
  mkdir -p "${BATS_TMP_DIR}/rootDir/conf"
  cp "${BATS_TEST_DIRNAME}/testsData/.envRootDir" "${BATS_TMP_DIR}/rootDir/conf/.env"
  export ROOT_DIR="${BATS_TMP_DIR}/rootDir"
  unset HOME
  Env::load || return 1
  echo "${BASH_FRAMEWORK_LOG_FILE}"
  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "4" ]]
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "4" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "/tmp/load.bats/test.log" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}" = "15" ]]
}

function Env::load::loadHomeEnvFileOverrideRootDirConfEnvFile { #@test
  mkdir -p "${BATS_TMP_DIR}/rootDir/conf"
  cp "${BATS_TEST_DIRNAME}/testsData/.envRootDir" "${BATS_TMP_DIR}/rootDir/conf/.env"
  export ROOT_DIR="${BATS_TMP_DIR}/rootDir"
  mkdir -p "${BATS_TMP_DIR}/home"
  cp "${BATS_TEST_DIRNAME}/testsData/.envHomeDir" "${BATS_TMP_DIR}/home/.env"
  export HOME="${BATS_TMP_DIR}/home"

  Env::load || return 1
  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "2" ]]
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "2" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "/tmp/load.bats/test-home.log" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}" = "19" ]]
}

function Env::load::forceLoadExistentFileWithHomeAndRootEnvFiles { #@test
  mkdir -p "${BATS_TMP_DIR}/rootDir/conf"
  cp "${BATS_TEST_DIRNAME}/testsData/.envRootDir" "${BATS_TMP_DIR}/rootDir/conf/.env"
  export ROOT_DIR="${BATS_TMP_DIR}/rootDir"
  mkdir -p "${BATS_TMP_DIR}/home"
  cp "${BATS_TEST_DIRNAME}/testsData/.envHomeDir" "${BATS_TMP_DIR}/home/.env"
  export HOME="${BATS_TMP_DIR}/home"
  cp "${BATS_TEST_DIRNAME}/testsData/.envForced" "${BATS_TMP_DIR}/.env"
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TMP_DIR}/.env"

  Env::load || return 1
  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "1" ]]
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "1" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "/tmp/load.bats/test-forced.log" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}" = "199" ]]
}

function Env::load::overrideWithParameter { #@test
  mkdir -p "${BATS_TMP_DIR}/rootDir/conf"
  cp "${BATS_TEST_DIRNAME}/testsData/.envRootDir" "${BATS_TMP_DIR}/rootDir/conf/.env"
  export ROOT_DIR="${BATS_TMP_DIR}/rootDir"
  mkdir -p "${BATS_TMP_DIR}/home"
  cp "${BATS_TEST_DIRNAME}/testsData/.envHomeDir" "${BATS_TMP_DIR}/home/.env"
  export HOME="${BATS_TMP_DIR}/home"
  cp "${BATS_TEST_DIRNAME}/testsData/.envForced" "${BATS_TMP_DIR}/.env"
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TMP_DIR}/.env"

  Env::load "${BATS_TEST_DIRNAME}/testsData/.envParam" || return 1
  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "param2" ]]
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "param1" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "/tmp/load.bats/test-param.log" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}" = "param3" ]]
}

function Env::load::noEnvFilesDefaultValues { #@test
  unset HOME
  unset BASH_FRAMEWORK_ENV_FILEPATH

  Env::load || return 1
  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "3" ]]
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "0" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "${ROOT_DIR}/logs/${SCRIPT_NAME}.log" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}" = "5" ]]
}
