#!/usr/bin/env bash

# @description ensure command ssh-keygen is available
# @exitcode 1 if ssh-keygen command not available
# @stderr diagnostics information is displayed
Ssh::requireSshKeygenCommand() {
  Assert::commandExists ssh-keygen
}
