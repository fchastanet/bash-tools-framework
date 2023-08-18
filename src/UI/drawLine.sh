#!/usr/bin/env bash

# @description draw a line with the character passed in parameter repeated depending on terminal width
# @arg $1 character:String character to use as separator (default value #)
UI::drawLine() {
  local character="${1:-#}"
  printf '%*s\n' "${COLUMNS:-$([[ -t 0 ]] && tput cols || echo)}" '' | tr ' ' "${character}"
}
