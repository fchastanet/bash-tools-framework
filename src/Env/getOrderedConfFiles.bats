#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Env/getOrderedConfFiles.sh
source "${srcDir}/Env/getOrderedConfFiles.sh"

setup() {
  unset BASH_FRAMEWORK_ENV_FILES
  TMPDIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR
}

function teardown() {
  unstub_all
}

function Env::getOrderedConfFiles::createDefaultEnvFileError { #@test
  Env::createDefaultEnvFile() {
    return 1
  }
  local status=0
  Env::getOrderedConfFiles >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Env::getOrderedConfFiles::noArgFileNotFound { #@test
  Env::createDefaultEnvFile() {
    echo "defaultEnvFile"
    return 0
  }
  local status=0
  Env::getOrderedConfFiles >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "2" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "One of the config file is not available 'defaultEnvFile'"
}

function Env::getOrderedConfFiles::FromEnv { #@test
  Env::createDefaultEnvFile() {
    echo "defaultEnvFile"
    return 0
  }
  local -a BASH_FRAMEWORK_ENV_FILES=('envFile')
  export BASH_FRAMEWORK_ENV_FILES
  local status=0
  Env::getOrderedConfFiles >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "2" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "One of the config file is not available 'envFile'"
}

function Env::getOrderedConfFiles::FromAll { #@test
  local -a BASH_FRAMEWORK_ENV_FILES=("${BATS_TEST_DIRNAME}/testsData/.envParam")
  export BASH_FRAMEWORK_ENV_FILES

  Env::createDefaultEnvFile() {
    echo "${BATS_TEST_DIRNAME}/testsData/.envHomeDir"
    return 0
  }

  local status=0
  Env::getOrderedConfFiles >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "${BATS_TEST_DIRNAME}/testsData/.envParam"
  assert_line --index 1 "${BATS_TEST_DIRNAME}/testsData/.envHomeDir"
}
