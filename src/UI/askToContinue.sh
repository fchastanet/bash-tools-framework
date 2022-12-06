#!/usr/bin/env bash

# Public: ask the user if he wishes to continue a process
#
# **Input**: user input y or Y characters
# **Output**: displays message <pre>Are you sure, you want to continue (y or n)?</pre>
# **Exit**: with error code 1 if y or Y, other keys do nothing
UI::askToContinue() {
  read -p "Are you sure, you want to continue (y or n)? " -n 1 -r
  echo # move to a new line
  if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
    # answer is other than y or Y
    exit 1
  fi
}
