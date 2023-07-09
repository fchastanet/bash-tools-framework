#!/usr/bin/env bash

FRAMEWORK_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
vendorDir="${FRAMEWORK_DIR}/vendor"
srcDir="${FRAMEWORK_DIR}/src"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Conf/loadNearestFile.sh
source "${srcDir}/Conf/loadNearestFile.sh"
# shellcheck source=/src/Framework/loadConfig.sh
source "${srcDir}/Framework/loadConfig.sh"
# shellcheck source=/src/File/upFind.sh
source "${srcDir}/File/upFind.sh"
# shellcheck source=/src/Array/contains.sh
source "${srcDir}/Array/contains.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
  mkdir -p "${BATS_TMP_DIR}/dir1/dir/dir1.1"
  mkdir -p "${BATS_TMP_DIR}/dir2/dir/dir2.1"
  echo "echo '.framework-config loaded'" >"${BATS_TMP_DIR}/dir1/.framework-config"
}

teardown() {
  rm -Rf "${BATS_TMP_DIR}" || true
}

function Framework::loadConfigNoSrcDir { #@test
  run Framework::loadConfig
  assert_failure 1
  assert_line --index 0 --partial "Config file '.framework-config' not found in any source directories provided"
}

function Framework::loadConfigNotFound { #@test
  run Framework::loadConfig "${BATS_TMP_DIR}/dir2/dir/dir2.1"
  assert_failure 1
  assert_line --index 0 --partial "Config file '.framework-config' not found in any source directories provided"
}

function Framework::loadConfigFoundInDir1 { #@test
  run Framework::loadConfig "${BATS_TMP_DIR}/dir1/dir/dir1.1"
  assert_success
  assert_line --index 0 --partial ".framework-config loaded"
  assert_line --index 1 "${BATS_TMP_DIR}/dir1/.framework-config"
}
