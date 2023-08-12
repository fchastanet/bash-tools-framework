#!/usr/bin/env bash

# @description Display given text and complete the rest of the line with given character
# @arg $1 text:String text to display
# @arg $2 character:String (default:#) character to use to complete the line
UI::textLine() {
  local text="$1"
  local character="${2:-#}"
  ((textSize = ${#text}))
  ((fullWith = $(tput cols)))
  ((remainingWidth = $((fullWith - textSize))))
  echo -n "${text}"
  printf '%*s\n' "${remainingWidth}" '' | tr ' ' "${character}"
}
