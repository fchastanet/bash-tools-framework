#!/usr/bin/env bash

# @description ensure command realpath is available
# @exitcode 1 if realpath command not available
# @stderr diagnostics information is displayed
Linux::requireRealpathCommand() {
  Assert::commandExists realpath
}
