#!/usr/bin/env bash

# @description ensure command docker-compose is available
# @exitcode 1 if docker-compose command not available
# @stderr diagnostics information is displayed
Docker::requireDockerComposeCommand() {
  Assert::commandExists docker
  Assert::commandExists docker-compose
}
