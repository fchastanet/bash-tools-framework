#!/usr/bin/env bash

# shellcheck disable=SC2034
declare copyrightBeginYear="2022"
# shellcheck disable=SC2034
declare versionNumber="1.0"

optionHelpCallback() {
  awkLintCommandHelp
  exit 0
}
