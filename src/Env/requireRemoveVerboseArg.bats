#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Env/requireRemoveVerboseArg.sh
source "${srcDir}/Env/requireRemoveVerboseArg.sh"

function Env::requireRemoveVerboseArg::empty { #@test
  BASH_FRAMEWORK_ARGV=()
  local status=0
  Env::requireRemoveVerboseArg >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${BASH_FRAMEWORK_ARGV[*]}" = "" ]]
}

function Env::requireRemoveVerboseArg::noVerboseArg { #@test
  BASH_FRAMEWORK_ARGV=(--help arg1 arg2)
  local status=0
  Env::requireRemoveVerboseArg >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${BASH_FRAMEWORK_ARGV[*]}" = "--help arg1 arg2" ]]
}

function Env::requireRemoveVerboseArg::verboseArgs { #@test
  BASH_FRAMEWORK_ARGV=(--verbose --help -v arg1 -vv arg2 -vvv)
  local status=0
  Env::requireRemoveVerboseArg >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${BASH_FRAMEWORK_ARGV[*]}" = "--help arg1 arg2" ]]
}
