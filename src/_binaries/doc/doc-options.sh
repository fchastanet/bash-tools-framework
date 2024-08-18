#!/usr/bin/env bash

# shellcheck disable=SC2034
declare copyrightBeginYear="2022"
# shellcheck disable=SC2034
declare versionNumber="1.1"
# shellcheck disable=SC2034
declare generateSkipDockerBuildOption=1

optionHelpCallback() {
  docCommandHelp
  exit 0
}
