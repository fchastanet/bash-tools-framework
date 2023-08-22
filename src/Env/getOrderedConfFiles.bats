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

function Env::getOrderedConfFiles::parseVerboseArgError { #@test
  Env::parseVerboseArg() {
    return 1
  }
  local status=0
  Env::getOrderedConfFiles >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Env::getOrderedConfFiles::parseEnvFileArgError { #@test
  Env::parseVerboseArg() {
    return 0
  }
  Env::parseEnvFileArg() {
    return 1
  }
  local status=0
  Env::getOrderedConfFiles >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Env::getOrderedConfFiles::createDefaultEnvFileError { #@test
  Env::parseVerboseArg() {
    return 0
  }
  Env::parseEnvFileArg() {
    return 0
  }
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
  Env::parseVerboseArg() {
    return 0
  }
  Env::parseEnvFileArg() {
    return 0
  }
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
  Env::parseVerboseArg() {
    return 0
  }
  Env::parseEnvFileArg() {
    return 0
  }
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
  Env::parseVerboseArg() {
    echo "${BATS_TEST_DIRNAME}/testsData/.env"
    return 0
  }
  Env::parseEnvFileArg() {
    echo "${BATS_TEST_DIRNAME}/testsData/.envForced"
    return 0
  }
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
  assert_lines_count 4
  assert_line --index 0 "${BATS_TEST_DIRNAME}/testsData/.env"
  assert_line --index 1 "${BATS_TEST_DIRNAME}/testsData/.envForced"
  assert_line --index 2 "${BATS_TEST_DIRNAME}/testsData/.envParam"
  assert_line --index 3 "${BATS_TEST_DIRNAME}/testsData/.envHomeDir"
}
