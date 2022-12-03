#!/usr/bin/env bash

# Display given text and complete the rest of the line with given character
# @param {String} $1 text to display
# @param {String} $2 (default:#) character to use to complete the line
UI::textLine() {
  local text="$1"
  local character="${2:-#}"
  ((textSize = ${#text}))
  ((fullWith = $(tput cols)))
  ((remainingWidth = $((fullWith - textSize))))
  echo -n "${text}"
  printf '%*s\n' "${remainingWidth}" '' | tr ' ' "${character}"
}
