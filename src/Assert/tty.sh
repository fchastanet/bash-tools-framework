#!/usr/bin/env bash

# @description check if tty (interactive mode) is active
# @noargs
# @exitcode 1 if tty not active
# @env NON_INTERACTIVE if 1 consider as not interactive even if environment is interactive
# @env INTERACTIVE if 1 consider as interactive even if environment is not interactive
Assert::tty() {
  if [[ "${NON_INTERACTIVE:-0}" = "1" ]]; then
    return 1
  fi
  if [[ "${INTERACTIVE:-0}" = "1" ]]; then
    return 0
  fi
  # check if stdout or stderr is connected to terminal
  [[ -t 1 || -t 2 ]]
}
