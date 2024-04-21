#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Github/downloadReleaseVersion.sh
source "${srcDir}/Github/downloadReleaseVersion.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
}

function Github::downloadReleaseVersion::curlFailure { #@test
  Retry::default() {
    if [[ "$@" =~ ^curl\ -L\ --connect-timeout\ "5"\ -o ]] && [[ "$@" =~ --fail\ invalidUrl$ ]]; then
      echo "curlCallOK"
    else
      echo "curlCallFailure"
    fi
    return 1
  }
  run Github::downloadReleaseVersion "invalidUrl"
  assert_failure 1
  assert_output "curlCallOK"
}

function Github::downloadReleaseVersion::curlSuccess { #@test
  Retry::default() {
    if [[ "$@" =~ ^curl\ -L\ --connect-timeout\ "5"\ -o ]] && [[ "$@" =~ --fail\ validUrl$ ]]; then
      echo "$6" >"${BATS_TEST_TMPDIR}/result"
      echo "curlCallOK"
    else
      echo "curlCallFailure"
    fi
    return 0
  }
  run Github::downloadReleaseVersion "validUrl"
  assert_success
  assert_lines_count 2
  assert_line --index 0 "curlCallOK"
  assert_line --index 1 --partial "${BATS_TEST_TMPDIR}/github.newSoftware"
  [[ "$(cat "${BATS_TEST_TMPDIR}/result")" =~ ^${BATS_TEST_TMPDIR}/github\.newSoftware\. ]]
}
