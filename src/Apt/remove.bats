#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Apt/remove.sh
source "${srcDir}/Apt/remove.sh"

teardown() {
  unset -f Retry::default || true
  unstub_all
}

function Apt::remove::simple { #@test

  Retry::default() {
    if [[ "$@" =~ 'sudo dpkg --purge pkg1' ]]; then
      echo "success"
    else
      echo "failure"
    fi
  }

  run Apt::remove "pkg1"

  assert_success
  assert_output "success"
}
