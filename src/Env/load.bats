#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

setup() {
  export TMPDIR="${BATS_RUN_TMPDIR}"
  unset BASH_FRAMEWORK_INITIALIZED
}

teardown() {
  unstub_all
}

function Env::load::alreadyInitialized { #@test
  export BASH_FRAMEWORK_INITIALIZED=1
  run Env::load
  assert_success
  assert_output ""
}

function Env::load::forceLoadNonExistentFile { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_RUN_TMPDIR}/notExists"
  run Env::load
  assert_success
  assert_output --partial "WARN    - env file not not found - ${BATS_RUN_TMPDIR}/notExists"
}

function Env::load::forceLoadExistentFile { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/.env" "${BATS_RUN_TMPDIR}/.env"
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_RUN_TMPDIR}/.env"
  unset HOME
  Env::load || return 1
  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "${__LEVEL_INFO}" ]]
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "${__LEVEL_OFF}" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "${ROOT_DIR}/logs/${SCRIPT_NAME}.log" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}" = "5" ]]
}

function Env::load::loadRootDirConfEnvFile { #@test
  mkdir -p "${BATS_RUN_TMPDIR}/rootDir/conf"
  cp "${BATS_TEST_DIRNAME}/testsData/.envRootDir" "${BATS_RUN_TMPDIR}/rootDir/conf/.env"
  export ROOT_DIR="${BATS_RUN_TMPDIR}/rootDir"
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
  mkdir -p "${BATS_RUN_TMPDIR}/rootDir/conf"
  cp "${BATS_TEST_DIRNAME}/testsData/.envRootDir" "${BATS_RUN_TMPDIR}/rootDir/conf/.env"
  export ROOT_DIR="${BATS_RUN_TMPDIR}/rootDir"
  mkdir -p "${BATS_RUN_TMPDIR}/home"
  cp "${BATS_TEST_DIRNAME}/testsData/.envHomeDir" "${BATS_RUN_TMPDIR}/home/.env"
  export HOME="${BATS_RUN_TMPDIR}/home"

  Env::load || return 1
  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "2" ]]
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "2" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "/tmp/load.bats/test-home.log" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}" = "19" ]]
}

function Env::load::forceLoadExistentFileWithHomeAndRootEnvFiles { #@test
  mkdir -p "${BATS_RUN_TMPDIR}/rootDir/conf"
  cp "${BATS_TEST_DIRNAME}/testsData/.envRootDir" "${BATS_RUN_TMPDIR}/rootDir/conf/.env"
  export ROOT_DIR="${BATS_RUN_TMPDIR}/rootDir"
  mkdir -p "${BATS_RUN_TMPDIR}/home"
  cp "${BATS_TEST_DIRNAME}/testsData/.envHomeDir" "${BATS_RUN_TMPDIR}/home/.env"
  export HOME="${BATS_RUN_TMPDIR}/home"
  cp "${BATS_TEST_DIRNAME}/testsData/.envForced" "${BATS_RUN_TMPDIR}/.env"
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_RUN_TMPDIR}/.env"

  Env::load || return 1
  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "1" ]]
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "1" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "/tmp/load.bats/test-forced.log" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}" = "199" ]]
}

function Env::load::overrideWithParameter { #@test
  mkdir -p "${BATS_RUN_TMPDIR}/rootDir/conf"
  cp "${BATS_TEST_DIRNAME}/testsData/.envRootDir" "${BATS_RUN_TMPDIR}/rootDir/conf/.env"
  export ROOT_DIR="${BATS_RUN_TMPDIR}/rootDir"
  mkdir -p "${BATS_RUN_TMPDIR}/home"
  cp "${BATS_TEST_DIRNAME}/testsData/.envHomeDir" "${BATS_RUN_TMPDIR}/home/.env"
  export HOME="${BATS_RUN_TMPDIR}/home"
  cp "${BATS_TEST_DIRNAME}/testsData/.envForced" "${BATS_RUN_TMPDIR}/.env"
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_RUN_TMPDIR}/.env"

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

function Env::load::loadRootDirConfEnvFileAndOverride { #@test
  mkdir -p "${BATS_RUN_TMPDIR}/rootDir/conf"
  cp "${BATS_TEST_DIRNAME}/testsData/.envOverride" "${BATS_RUN_TMPDIR}/rootDir/conf/.env"
  export ROOT_DIR="${BATS_RUN_TMPDIR}/rootDir"
  unset HOME
  export OVERRIDE_BASH_FRAMEWORK_DISPLAY_LEVEL=overriddenDisplayLevel
  export OVERRIDE_BASH_FRAMEWORK_LOG_LEVEL=overriddenLogLevel
  export OVERRIDE_BASH_FRAMEWORK_LOG_FILE=overriddenLogFile
  export OVERRIDE_BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=overriddenLogFileMaxRotation
  export CUSTOM_VAR1=notTakenIntoAccount
  export OVERRIDE_CUSTOM_VAR2=modified
  Env::load || return 1
  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "overriddenDisplayLevel" ]]
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "overriddenLogLevel" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "overriddenLogFile" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}" = "overriddenLogFileMaxRotation" ]]
  [[ "${CUSTOM_VAR1}" = "notModified" ]]
  # shellcheck disable=SC2153
  [[ "${CUSTOM_VAR2}" = "modified" ]]
}
