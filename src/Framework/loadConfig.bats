#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

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
  export TMPDIR="${BATS_TEST_TMPDIR}"
  mkdir -p "${BATS_TEST_TMPDIR}/dir1/dir/dir1.1"
  mkdir -p "${BATS_TEST_TMPDIR}/dir2/dir/dir2.1"
  echo "echo '.framework-config loaded'" >"${BATS_TEST_TMPDIR}/dir1/.framework-config"
}

function Framework::loadConfigNoSrcDir { #@test
  run Framework::loadConfig configFile
  assert_failure 1
  assert_line --index 0 --partial "Config file '.framework-config' not found in any source directories provided"
}

function Framework::loadConfigNotFound { #@test
  run Framework::loadConfig configFile "${BATS_TEST_TMPDIR}/dir2/dir/dir2.1"
  assert_failure 1
  assert_line --index 0 --partial "Config file '.framework-config' not found in any source directories provided"
}

function Framework::loadConfigFoundInDir1 { #@test
  configFile=""
  Framework::loadConfig configFile "${BATS_TEST_TMPDIR}/dir1/dir/dir1.1"
  [[ "${configFile}" = "${BATS_TEST_TMPDIR}/dir1/.framework-config" ]]
}
