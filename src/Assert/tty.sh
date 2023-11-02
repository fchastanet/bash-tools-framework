#!/usr/bin/env bash

# @description check if tty (interactive mode) is active
# @noargs
# @exitcode 1 if tty not active
# @environment NON_INTERACTIVE if 1 consider as not interactive even if environement is interactive
# @environment INTERACTIVE if 1 consider as interactive even if environement is not interactive
# @stderr diagnostic information + help if second argument is provided
Assert::tty() {
  if [[ "${NON_INTERACTIVE:-0}" = "1" ]]; then
    return 1
  fi
  if [[ "${INTERACTIVE:-0}" = "1" ]]; then
    return 0
  fi
  [[ -t 1 || -t 2 ]]
}
