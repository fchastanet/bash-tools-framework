#!/usr/bin/env bash

# shellcheck disable=SC2317,SC2329 # if function is overridden
beforeParseCallback() {
  Linux::requireJqCommand
  UI::requireTheme
}

unknownOption() {
  cspellOptions+=("$1")
}

# shellcheck disable=SC2317,SC2329 # if function is overridden
optionHelpCallback() {
  cspellForbiddenCommandHelp
  exit 0
}
