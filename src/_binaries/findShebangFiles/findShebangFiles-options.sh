#!/usr/bin/env bash

declare -a commandToApply=()
unknownOptionArgFunction() {
  commandToApply+=("$1")
}

optionHelpCallback() {
  findShebangFilesCommandHelp
  exit 0
}
