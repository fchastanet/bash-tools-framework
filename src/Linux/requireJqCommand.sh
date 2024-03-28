#!/usr/bin/env bash

# @description ensure command jq is available
# @exitcode 1 if jq command not available
# @stderr diagnostics information is displayed
Linux::requireJqCommand() {
  if [[ "${SKIP_REQUIRE_JQ:-0}" = "0" && "${SKIP_REQUIRES:-0}" = "0" ]]; then
    Assert::commandExists jq
  fi
}
