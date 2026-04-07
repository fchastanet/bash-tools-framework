#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/File/detectBashFileInit.sh
source "${srcDir}/File/detectBashFileInit.sh"
# shellcheck source=/src/Assert/bashFile.sh
source "${srcDir}/Assert/bashFile.sh"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
}

function File::detectBashFileInit::missingBashFileListAlreadySet { #@test
  File::detectBashFile() {
    true
  }
  export missingBashFileList="${BATS_TEST_TMPDIR}/missingBashFileList"
  touch "${missingBashFileList}"
  run File::detectBashFileInit
  assert_success
  assert_output ""
  [[ ! -e "${missingBashFileList}" ]]
}

function File::detectBashFileInit::normal { #@test
  File::detectBashFile() {
    true
  }
  missingBashFileList=""
  export missingBashFileList

  local status=0
  File::detectBashFileInit || status=$?
  [[ "${status}" = "0" ]]
  [[ -n "${missingBashFileList}" ]]
  [[ -e "${missingBashFileList}" ]]
}
