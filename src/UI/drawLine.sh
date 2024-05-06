#!/usr/bin/env bash

# @description draw a line with the character passed in parameter repeated depending on terminal width
# @arg $1 character:String character to use as separator (default value #)
UI::drawLine() {
  local character="${1:-#}"
  local -i width=${COLUMNS:-0}
  if ((width == 0)) && [[ -t 1 ]]; then
    width=$(tput cols)
  fi
  if ((width == 0)); then
    width=80
  fi
  printf -- "${character}%.0s" $(seq "${COLUMNS:-$([[ -t 1 ]] && tput cols || echo '80')}")
  echo
}
