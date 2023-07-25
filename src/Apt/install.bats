#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Apt/install.sh
source "${srcDir}/Apt/install.sh"

teardown() {
  unset -f Retry::default || true
  unstub_all
}

function Apt::install::simple { #@test

  Retry::default() {
    if [[ "$@" =~ 'sudo apt-get install -y -q pkg1' ]]; then
      echo "success"
    else
      echo "failure"
    fi
  }

  run Apt::install "pkg1"

  assert_success
  assert_output "success"
}
