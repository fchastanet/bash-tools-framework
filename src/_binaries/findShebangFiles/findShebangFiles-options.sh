#!/usr/bin/env bash

# shellcheck disable=SC2034
declare copyrightBeginYear="2023"
# shellcheck disable=SC2034
declare versionNumber="1.0"

declare -a commandToApply=()
unknownOptionArgFunction() {
  commandToApply+=("$1")
}

optionHelpCallback() {
  findShebangFilesCommandHelp
  exit 0
}
