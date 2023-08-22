#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Env/mergeConfFiles.sh
source "${srcDir}/Env/mergeConfFiles.sh"
# shellcheck source=src/Framework/createTempFile.sh
source "${srcDir}/Framework/createTempFile.sh"
# shellcheck source=src/Filters/commentLines.sh
source "${srcDir}/Filters/commentLines.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
}

teardown() {
  unset KEY_1
  unset KEY_2
  unset HOME
  unset BASH_FRAMEWORK_DISPLAY_LEVEL
}

function Env::mergeConfFiles::noFile { #@test
  run Env::mergeConfFiles
  assert_success
  assert_output ""
}

function Env::mergeConfFiles::oneFileCase1 { #@test
  local status=0
  unset KEY_1
  unset KEY_2
  Env::mergeConfFiles \
    "${BATS_TEST_DIRNAME}/testsData/mergeConfFiles.env1" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  [[ "${status}" = "0" ]]
  [[ "${KEY_1}" = "some value" ]]
  [[ "${KEY_2}" = "some value" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Env::mergeConfFiles::twoFiles { #@test
  local status=0
  unset KEY_1
  unset KEY_2
  Env::mergeConfFiles \
    "${BATS_TEST_DIRNAME}/testsData/mergeConfFiles.env1" \
    "${BATS_TEST_DIRNAME}/testsData/mergeConfFiles.env2" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  [[ "${status}" = "0" ]]
  [[ "${KEY_1}" = "some value" ]]
  [[ "${KEY_2}" = "some value" ]]
  [[ "${SHARED_KEY_1}" = "some shared value" ]]
  [[ "${SHARED_KEY_2}" = "some shared value" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Env::mergeConfFiles::secondFileNoOverrideFirstFile { #@test
  local status=0
  unset KEY_1
  unset KEY_2
  Env::mergeConfFiles \
    "${BATS_TEST_DIRNAME}/testsData/mergeConfFiles.env1" \
    "${BATS_TEST_DIRNAME}/testsData/mergeConfFiles.env1.noOverride" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  [[ "${status}" = "0" ]]
  [[ "${KEY_1}" = "some value" ]]
  [[ "${KEY_2}" = "some value" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Env::mergeConfFiles::interDependentConfigFiles { #@test
  local status=0
  unset ENV_1_SHARED_KEY
  unset ENV_1_KEY
  unset ENV_2_SHARED_KEY
  unset ENV_2_KEY
  Env::mergeConfFiles \
    "${BATS_TEST_DIRNAME}/testsData/mergeConfFiles.interDependent.env1" \
    "${BATS_TEST_DIRNAME}/testsData/mergeConfFiles.interDependent.env2" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  [[ "${status}" = "0" ]]
  [[ "${ENV_1_SHARED_KEY}" = "shared key env 1" ]]
  [[ "${ENV_1_KEY}" = "shared key env 2" ]]
  [[ "${ENV_2_SHARED_KEY}" = "shared key env 2" ]]
  [[ "${ENV_2_KEY}" = "shared key env 1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Env::mergeConfFiles::envFileWithError { #@test
  local status=0
  unset KEY_1
  Env::mergeConfFiles \
    "${BATS_TEST_DIRNAME}/testsData/mergeConfFiles.withError" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  [[ "${status}" = "3" ]]
  [[ "${KEY_1}" = "key1" ]] # env partially loaded
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 --partial "line 2: KEY_2shared key env 1: command not found"
  assert_line --index 1 --partial "line 3: KEY_3: command not found"
}

function Env::mergeConfFiles::envFileWithBashArrayError { #@test
  local status=0
  unset KEY_1
  unset KEY_2
  unset KEY_3
  Env::mergeConfFiles \
    "${BATS_TEST_DIRNAME}/testsData/mergeConfFiles.withBashArrayError" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  [[ "${status}" = "3" ]]
  [[ "${KEY_1}" = "key1" ]] # env partially loaded
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 4
  assert_line --index 0 --partial "line 3: item1: command not found"
  assert_line --index 1 --partial "line 4: item2: command not found"
  assert_line --index 2 --partial "line 5: syntax error near unexpected token \`)'"
  assert_line --index 3 --partial "line 5: \`)'"
}

function Env::mergeConfFiles::withBashArrayOneLine { #@test
  local status=0
  unset KEY_1
  unset KEY_2
  Env::mergeConfFiles \
    "${BATS_TEST_DIRNAME}/testsData/mergeConfFiles.withBashArrayOneLine" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  [[ "${status}" = "0" ]]
  [[ "${KEY_1}" = "key1" ]]
  # array is changed into a string
  [[ "${KEY_2}" = '(item1 item2)' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Env::mergeConfFiles::variableInitFromEnv { #@test
  local status=0
  unset KEY_1
  export KEY_1_FROM_ENV="key1 from env"
  Env::mergeConfFiles \
    "${BATS_TEST_DIRNAME}/testsData/mergeConfFiles.variableInitFromEnv" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  [[ "${status}" = "0" ]]
  [[ "${KEY_1}" = "completed with env var key1 from env" ]]
  [[ "${KEY_1_FROM_ENV}" = "key1 from env" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}
