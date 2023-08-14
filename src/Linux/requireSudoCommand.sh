#!/usr/bin/env bash

# @description ensure command sudo is available
# @exitcode 1 if sudo command not available
# @stderr diagnostics information is displayed
Linux::requireSudoCommand() {
  Assert::commandExists sudo
}
