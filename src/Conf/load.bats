#!/usr/bin/env bash

FRAMEWORK_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
vendorDir="${FRAMEWORK_DIR}/vendor"
srcDir="${FRAMEWORK_DIR}/src"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Conf/load.sh
source "${srcDir}/Conf/load.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
  mkdir -p "${BATS_TMP_DIR}/home/.bash-tools/cliProfiles"
  cp "${BATS_TEST_DIRNAME}/testsData/cliProfiles/default.sh" "${BATS_TMP_DIR}/home/.bash-tools/cliProfiles"
  mkdir -p "${BATS_TMP_DIR}/home/.bash-tools/dsn"
  cp "${BATS_TEST_DIRNAME}/testsData/dsn/"* "${BATS_TMP_DIR}/home/.bash-tools/dsn"
  export HOME="${BATS_TMP_DIR}/home"
}

teardown() {
  unstub_all
  rm -Rf "${BATS_TMP_DIR}" || true
}

function Conf::loadAbsoluteFile { #@test
  Conf::load "anyFolder" "${BATS_TMP_DIR}/home/.bash-tools/cliProfiles/default.sh"
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
