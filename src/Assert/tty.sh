#!/usr/bin/env bash

# @description check if tty (interactive mode) is active
# @noargs
# @exitcode 1 if tty not active
# @stderr diagnostic information + help if second argument is provided
Assert::tty() {
  [[ -t 1 || -t 2 ]]
}
