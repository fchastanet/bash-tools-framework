#!/usr/bin/env bash

# @description ensure command yq is available
# @exitcode 1 if yq command not available
# @stderr diagnostics information is displayed
Linux::requireYqCommand() {
  if [[ "${SKIP_REQUIRE_YQ:-0}" = "0" && "${SKIP_REQUIRES:-0}" = "0" ]]; then
    Assert::commandExists yq
  fi
}
