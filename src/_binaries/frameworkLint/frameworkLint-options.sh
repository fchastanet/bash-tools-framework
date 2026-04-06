#!/usr/bin/env bash

declare optionFormatDefault="tty"
# shellcheck disable=SC2034
declare optionFormat="${optionFormatDefault}"

# shellcheck disable=SC2317,SC2329 # if function is overridden
beforeParseCallback() {
  Env::requireLoad
  UI::requireTheme
  Log::requireLoad
}

# shellcheck disable=SC2317,SC2329 # if function is overridden
optionExpectedWarningsCountCallback() {
  if [[ ! "$2" =~ ^[0-9]+$ ]] || (($2 < 0)); then
    Log::fatal "Command ${SCRIPT_NAME} - Expected warnings count value should be a number greater or equal to 0"
  fi
}

# shellcheck disable=SC2317,SC2329 # if function is overridden
optionHelpCallback() {
  frameworkLintCommandHelp
  exit 0
}
