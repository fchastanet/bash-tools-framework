#!/usr/bin/env bash

# @description ensure command ssh-keyscan is available
# @exitcode 1 if ssh-keyscan command not available
# @stderr diagnostics information is displayed
Ssh::requireSshKeyscanCommand() {
  Assert::commandExists ssh-keyscan
}
