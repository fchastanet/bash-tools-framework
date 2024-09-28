#!/usr/bin/env bash

# shellcheck disable=SC2034
declare generateSkipDockerBuildOption=1

optionHelpCallback() {
  docCommandHelp
  exit 0
}
