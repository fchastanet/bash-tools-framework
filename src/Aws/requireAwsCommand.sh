#!/usr/bin/env bash

# @description ensure command aws is available
# @exitcode 1 if aws command not available
# @stderr diagnostics information is displayed
Aws::requireAwsCommand() {
  Assert::commandExists aws
}
