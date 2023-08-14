#!/usr/bin/env bash

# @description ensure command jq is available
# @exitcode 1 if jq command not available
# @stderr diagnostics information is displayed
Linux::requireJqCommand() {
  Assert::commandExists jq
}
