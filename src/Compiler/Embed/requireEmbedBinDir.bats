#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Compiler/Embed/requireEmbedBinDir.sh
source "${srcDir}/Compiler/Embed/requireEmbedBinDir.sh"
# shellcheck source=src/Env/pathPrepend.sh
source "${srcDir}/Env/pathPrepend.sh"

teardown() {
  unstub_all
  unset -f Env::pathPrepend
}

function Compiler::Embed::requireEmbedBinDir::failure { #@test
  Env::pathPrepend() {
    return 1
  }
  export PATH="/usr/bin"
  export CURRENT_DIR="${BATS_TEST_DIRNAME}"
  local status=0
  Compiler::Embed::requireEmbedBinDir >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${PATH}" = "/usr/bin" ]]
}

function Compiler::Embed::requireEmbedBinDir::notExistingDir { #@test
  export PATH="/usr/bin"
  export CURRENT_DIR="${BATS_TEST_DIRNAME}"
  export TMPDIR="/mytmpdir"
  local status=0
  Compiler::Embed::requireEmbedBinDir >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "mkdir: cannot create directory '/mytmpdir': Permission denied"
  assert_line --index 1 --partial "ERROR   - unable to create directory /mytmpdir/bin"
  [[ "${PATH}" = "/usr/bin" ]]
}

function Compiler::Embed::requireEmbedBinDir::success { #@test
  export PATH="/usr/bin"
  export CURRENT_DIR="${BATS_TEST_DIRNAME}"
  export TMPDIR="${BATS_TEST_TMPDIR}"
  local status=0
  Compiler::Embed::requireEmbedBinDir >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ -d "${BATS_TEST_TMPDIR:-/tmp}/bin" ]]
  [[ "${PATH}" = "${BATS_TEST_TMPDIR}/bin:/usr/bin" ]]
}
