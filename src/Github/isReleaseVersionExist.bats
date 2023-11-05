#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Github/isReleaseVersionExist.sh
source "${srcDir}/Github/isReleaseVersionExist.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
}

function teardown() {
  unstub_all
}

function Github::isReleaseVersionExist::curlFailure { #@test
  stub curl '-L -o /dev/null --silent --head --fail invalidUrl : exit 1'

  run Github::isReleaseVersionExist "invalidUrl"
  assert_failure 1
  assert_output ""
}

function Github::isReleaseVersionExist::curlSuccess { #@test
  stub curl '-L -o /dev/null --silent --head --fail validUrl : exit 0'
  run Github::isReleaseVersionExist "validUrl"
  assert_success
  assert_output ""
}
