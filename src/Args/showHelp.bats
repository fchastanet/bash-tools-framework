#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Args/showHelp.sh
source "${srcDir}/Args/showHelp.sh"

function Args::showHelp::message { #@test
  run Args::showHelp "Help"
  assert_success
  assert_output "Help"
}
