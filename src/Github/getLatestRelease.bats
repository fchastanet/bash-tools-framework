#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Github/getLatestRelease.sh
source "${srcDir}/Github/getLatestRelease.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
}

function Github::getLatestRelease::curlFailure { #@test
  Retry::default() {
    if [[ "$@" =~ ^curl\ -L\ --connect-timeout\ 5\ -o ]] &&
      [[ "$@" =~ --fail\ --silent\ https://api.github.com/repos/invalidUrl/releases/latest$ ]]; then
      echo "curlCallOK"
    else
      echo "curlCallFailure"
    fi
    return 1
  }
  local ret=0
  local result=""
  Github::getLatestRelease "invalidUrl" result >"${BATS_TEST_TMPDIR}/result" 2>&1 || ret=$?
  [[ "${ret}" = "1" ]]
  [[ "${result}" = "" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output "curlCallOK"
}

function Github::getLatestRelease::curlSuccess { #@test
  Version::githubApiExtractVersion() {
    cat
  }
  Retry::default() {
    if [[ "$@" =~ ^curl\ -L\ --connect-timeout\ 5\ -o ]] &&
      [[ "$@" =~ --fail\ --silent\ https://api.github.com/repos/validUrl/releases/latest$ ]]; then
      echo "newSoftware" >"$6" # $6 = curl output
      echo "v1.0.0"
    else
      echo "curlCallFailure"
    fi
    return 0
  }
  local ret=0
  local result=""
  Github::getLatestRelease "validUrl" result &>"${BATS_TEST_TMPDIR}/result" || ret=$?
  [[ "${ret}" = "0" ]]
  [[ "${result}" = "newSoftware" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output "v1.0.0"
}
