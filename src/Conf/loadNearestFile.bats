#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Conf/loadNearestFile.sh
source "${srcDir}/Conf/loadNearestFile.sh"
# shellcheck source=/src/File/upFind.sh
source "${srcDir}/File/upFind.sh"
# shellcheck source=/src/Array/contains.sh
source "${srcDir}/Array/contains.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  mkdir -p "${BATS_TEST_TMPDIR}/dir/dir/dir1"
  mkdir -p "${BATS_TEST_TMPDIR}/dir/dir/dir2"
  export BASH_FRAMEWORK_DISPLAY_LEVEL="${__LEVEL_DEBUG}"
  echo "echo '.framework-config1 loaded'" >"${BATS_TEST_TMPDIR}/dir/dir/dir1/.framework-config1"
  echo "echo '.framework-config2 loaded'" >"${BATS_TEST_TMPDIR}/dir/dir/.framework-config2"
  echo "echo '.framework-config3 loaded'" >"${BATS_TEST_TMPDIR}/dir/dir/dir2/.framework-config3"
  echo "echo '.framework-configRoot loaded'" >"${BATS_TEST_TMPDIR}/.framework-configRoot"
}

function Conf::loadNearestFileFileNoSrcDir { #@test
  run Conf::loadNearestFile "anyConfFile" configFile
  assert_failure 1
  assert_line --index 0 --partial "Config file 'anyConfFile' not found in any source directories provided"
}

function Conf::loadNearestFileFileNotFound { #@test
  run Conf::loadNearestFile "anyConfFile" configFile "${BATS_TEST_TMPDIR}/dir/dir/dir1" "${BATS_TEST_TMPDIR}/dir/dir/dir2"
  assert_failure 1
  assert_line --index 0 --partial "Config file 'anyConfFile' not found in any source directories provided"
}

function Conf::loadNearestFileFileFoundInDir1 { #@test
  Conf::loadNearestFile ".framework-config1" configFile "${BATS_TEST_TMPDIR}/dir/dir/dir1" "${BATS_TEST_TMPDIR}/dir/dir/dir2" 2>&1
  [[ "${configFile}" = "${BATS_TEST_TMPDIR}/dir/dir/dir1/.framework-config1" ]]
}

function Conf::loadNearestFileFileFoundInDir2 { #@test
  Conf::loadNearestFile ".framework-config2" configFile "${BATS_TEST_TMPDIR}/dir/dir/dir1" "${BATS_TEST_TMPDIR}/dir/dir/dir2" 2>&1
  [[ "${configFile}" = "${BATS_TEST_TMPDIR}/dir/dir/.framework-config2" ]]
}

function Conf::loadNearestFileFileFoundInDir3 { #@test
  Conf::loadNearestFile ".framework-config3" configFile "${BATS_TEST_TMPDIR}/dir/dir/dir1" "${BATS_TEST_TMPDIR}/dir/dir/dir2" 2>&1
  [[ "${configFile}" = "${BATS_TEST_TMPDIR}/dir/dir/dir2/.framework-config3" ]]
}

function Conf::loadNearestFileFileFoundInRootDir { #@test
  run Conf::loadNearestFile ".framework-configRoot" configFile "${BATS_TEST_TMPDIR}/dir/dir/dir1" "${BATS_TEST_TMPDIR}/dir/dir/dir2" 2>&1
  assert_success
  assert_line --index 0 --partial ".framework-configRoot loaded"
}
