#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Conf/load.sh
source "${srcDir}/Conf/load.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  mkdir -p "${BATS_TEST_TMPDIR}/home/.bash-tools/cliProfiles"
  cp "${BATS_TEST_DIRNAME}/testsData/cliProfiles/default.sh" "${BATS_TEST_TMPDIR}/home/.bash-tools/cliProfiles"
  mkdir -p "${BATS_TEST_TMPDIR}/home/.bash-tools/dsn"
  cp "${BATS_TEST_DIRNAME}/testsData/dsn/"* "${BATS_TEST_TMPDIR}/home/.bash-tools/dsn"
  export HOME="${BATS_TEST_TMPDIR}/home"
}

teardown() {
  unstub_all
}

function Conf::loadAbsoluteFile { #@test
  Conf::load "anyFolder" "${BATS_TEST_TMPDIR}/home/.bash-tools/cliProfiles/default.sh"
  # shellcheck disable=SC2154
  [[ "${finalUserArg}" = "www-data" ]]
  # shellcheck disable=SC2154
  [[ "${finalCommandArg}" = "//bin/bash" ]]
  # shellcheck disable=SC2154
  [[ "${finalContainerArg}" = "project-apache2" ]]
}

function Conf::loadDefault { #@test
  Conf::load "cliProfiles" "default"

  # shellcheck disable=SC2154
  [[ "${finalUserArg}" = "www-data" ]]
  # shellcheck disable=SC2154
  [[ "${finalCommandArg}" = "//bin/bash" ]]
  # shellcheck disable=SC2154
  [[ "${finalContainerArg}" = "project-apache2" ]]
}

function Conf::loadDsn { #@test
  Conf::load "dsn" "default.local" ".env"
  [[ "${HOSTNAME}" = "127.0.0.1" ]]
  [[ "${USER}" = "root" ]]
  [[ "${PASSWORD}" = "root" ]]
  [[ "${PORT}" = "3306" ]]
}

function Conf::loadFileNotFound { #@test
  run Conf::load "dsn" "not found" ".sh"
  assert_failure 1
  assert_output ""
}
