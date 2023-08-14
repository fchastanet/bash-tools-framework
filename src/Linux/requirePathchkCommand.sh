#!/usr/bin/env bash

# @description ensure command pathchk is available
# @exitcode 1 if pathchk command not available
# @stderr diagnostics information is displayed
Linux::requirePathchkCommand() {
  Assert::commandExists pathchk
}
