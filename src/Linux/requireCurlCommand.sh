#!/usr/bin/env bash

# @description ensure command curl is available
# @exitcode 1 if curl command not available
# @stderr diagnostics information is displayed
Linux::requireCurlCommand() {
  Assert::commandExists curl
}
