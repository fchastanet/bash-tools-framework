#!/usr/bin/env bash

# @description draw a line with the character passed in parameter repeated depending on terminal width
# including message in the middle of the screen
# @arg $2 msg:String msg to display on the middle
# @arg $1 character:String character to use as separator (default value #)
# @env COLUMNS number of columns, if not provided compute the screen width
UI::drawLineWithMsg() {
  local msg="${1:-}"
  local character="${2:-#}"
  if ((${#msg} == 0)); then
    UI::drawLine "${character}"
    return 0
  fi

  # compute screen width
  local -i width=${COLUMNS:-0}
  if ((width == 0)); then
    if [[ -t 0 ]]; then
      width=$(tput cols)
    fi
  fi
  if ((width == 0)); then
    width=80
  fi

  # compute msg
  local -i msgLen=${#msg}
  if ((msgLen + 4 > width)); then
    msg="${msg:0:$((width - 4))}"
  fi

  # compute left/right line
  local -i leftWidth=$(((width - msgLen - 2) / 2))
  local -i rightWidth=$((width - msgLen - 2 - leftWidth))

  # display line
  printf -- "${character}%.0s" $(seq "${leftWidth}")
  echo -n " ${msg} "
  printf -- "${character}%.0s" $(seq "${rightWidth}")
}
