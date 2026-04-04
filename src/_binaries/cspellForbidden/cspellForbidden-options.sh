#!/usr/bin/env bash

beforeParseCallback() {
  Linux::requireJqCommand
  UI::requireTheme
}

unknownOption() {
  cspellOptions+=("$1")
}

optionHelpCallback() {
  cspellForbiddenCommandHelp
  exit 0
}
