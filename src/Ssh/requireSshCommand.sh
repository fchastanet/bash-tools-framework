#!/usr/bin/env bash

# @description ensure command ssh is available
# @exitcode 1 if ssh command not available
# @stderr diagnostics information is displayed
Ssh::requireSshCommand() {
  Assert::commandExists ssh
}
