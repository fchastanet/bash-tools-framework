#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/Apt/remove.sh
source "${srcDir}/Linux/Apt/remove.sh"

teardown() {
  unset -f Retry::default || true
  unstub_all
}

function Linux::Apt::remove::simple { #@test

  Retry::default() {
    if [[ "$@" =~ 'sudo dpkg --purge pkg1' ]]; then
      echo "success"
    else
      echo "failure"
    fi
  }

  run Linux::Apt::remove "pkg1"

  assert_success
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Apt remove pkg1"
  assert_line --index 1 "success"
}
