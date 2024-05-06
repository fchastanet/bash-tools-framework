#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Web/getReleases.sh
source "${srcDir}/Web/getReleases.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
}

function teardown() {
  unstub_all
}

function Web::getReleases::curlFailure { #@test
  stub curl '-L --connect-timeout 5 --fail --silent invalidUrl : exit 1'
  Retry::parameterized() {
    shift 3
    "$@"
  }
  run Web::getReleases "invalidUrl" 2>&1
  assert_failure 1
  assert_output ""
}

function Web::getReleases::curlSuccess { #@test
  stub curl '-L --connect-timeout 5 --fail --silent validUrl : echo versions'
  Retry::parameterized() {
    shift 3
    "$@"
  }
  run Web::getReleases "validUrl" 2>&1
  assert_success
  assert_output "versions"
}
