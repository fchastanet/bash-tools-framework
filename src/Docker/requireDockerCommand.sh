#!/usr/bin/env bash

# @description ensure command docker is available
# @exitcode 1 if docker command not available
# @stderr diagnostics information is displayed
Docker::requireDockerCommand() {
  Assert::commandExists docker
}
