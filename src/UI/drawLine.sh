#!/usr/bin/env bash

# draw a line with the character passed in parameter repeated depending on terminal width
# @param {String} $1 character to use as separator (default value #)
UI::drawLine() {
  local character="${1:-#}"
  printf '%*s\n' "${COLUMNS:-$([[ -t 0 ]] && tput cols || echo)}" '' | tr ' ' "${character}"
}
