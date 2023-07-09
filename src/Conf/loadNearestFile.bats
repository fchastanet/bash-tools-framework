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
  mkdir -p "${BATS_TMP_DIR}/dir/dir/dir1"
  mkdir -p "${BATS_TMP_DIR}/dir/dir/dir2"
  echo "echo '.framework-config1 loaded'" >"${BATS_TMP_DIR}/dir/dir/dir1/.framework-config1"
  echo "echo '.framework-config2 loaded'" >"${BATS_TMP_DIR}/dir/dir/.framework-config2"
  echo "echo '.framework-config3 loaded'" >"${BATS_TMP_DIR}/dir/dir/dir2/.framework-config3"
  echo "echo '.framework-configRoot loaded'" >"${BATS_TMP_DIR}/.framework-configRoot"
}

teardown() {
  rm -Rf "${BATS_TMP_DIR}" || true
}

function Conf::loadNearestFileFileNoSrcDir { #@test
  run Conf::loadNearestFile "anyConfFile"
  assert_failure 1
  assert_line --index 0 --partial "Config file 'anyConfFile' not found in any source directories provided"
}

function Conf::loadNearestFileFileNotFound { #@test
  run Conf::loadNearestFile "anyConfFile" "${BATS_TMP_DIR}/dir/dir/dir1" "${BATS_TMP_DIR}/dir/dir/dir2"
  assert_failure 1
  assert_line --index 0 --partial "Config file 'anyConfFile' not found in any source directories provided"
}

function Conf::loadNearestFileFileFoundInDir1 { #@test
  run Conf::loadNearestFile ".framework-config1" "${BATS_TMP_DIR}/dir/dir/dir1" "${BATS_TMP_DIR}/dir/dir/dir2" 2>&1
  assert_success
  assert_line --index 0 --partial ".framework-config1 loaded"
}

function Conf::loadNearestFileFileFoundInDir2 { #@test
  run Conf::loadNearestFile ".framework-config2" "${BATS_TMP_DIR}/dir/dir/dir1" "${BATS_TMP_DIR}/dir/dir/dir2" 2>&1
  assert_success
  assert_line --index 0 --partial ".framework-config2 loaded"
}

function Conf::loadNearestFileFileFoundInDir3 { #@test
  run Conf::loadNearestFile ".framework-config3" "${BATS_TMP_DIR}/dir/dir/dir1" "${BATS_TMP_DIR}/dir/dir/dir2" 2>&1
  assert_success
  assert_line --index 0 --partial ".framework-config3 loaded"
}

function Conf::loadNearestFileFileFoundInRootDir { #@test
  run Conf::loadNearestFile ".framework-configRoot" "${BATS_TMP_DIR}/dir/dir/dir1" "${BATS_TMP_DIR}/dir/dir/dir2" 2>&1
  assert_success
  assert_line --index 0 --partial ".framework-configRoot loaded"
}
