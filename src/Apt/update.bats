#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Apt/update.sh
source "${srcDir}/Apt/update.sh"

teardown() {
  unset -f Retry::default || true
  unstub_all
}

function Apt::update::simple { #@test

  Retry::default() {
    if [[ "$@" =~ 'sudo apt-get update -y --fix-missing -o Acquire::ForceIPv4=true' ]]; then
      echo "success"
    else
      echo "failure"
    fi
  }

  run Apt::update

  assert_success
  assert_output "success"
}
