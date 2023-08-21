#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Compiler/Facade/requireCommandBinDir.sh
source "${srcDir}/Compiler/Facade/requireCommandBinDir.sh"
# shellcheck source=src/Env/pathPrepend.sh
source "${srcDir}/Env/pathPrepend.sh"

teardown() {
  unstub_all
  unset -f Env::pathPrepend
}

function Compiler::Facade::requireCommandBinDir::failure { #@test
  Env::pathPrepend() {
    return 1
  }
  export CURRENT_DIR="${BATS_TEST_DIRNAME}"
  local status=0
  Compiler::Facade::requireCommandBinDir >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${CURRENT_DIR}" = "${BATS_TEST_DIRNAME}" ]]
}

function Compiler::Facade::requireCommandBinDir::success { #@test
  export PATH="/usr/bin"
  export CURRENT_DIR="${BATS_TEST_DIRNAME}"
  local status=0
  Compiler::Facade::requireCommandBinDir >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${CURRENT_DIR}" = "${BATS_TEST_DIRNAME}" ]]
  [[ "${PATH}" = "${BATS_TEST_DIRNAME}:/usr/bin" ]]
}
