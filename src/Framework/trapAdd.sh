#!/usr/bin/env bash

# @description appends a command to a trap
# when you define a trap, an eventual existing trap is replaced by the new one.
# This method allows to add trap on several signals without removing previous handler.
#
# @example
#   trap "echo '- SIGUSR1 original'" SIGUSR1
#   Framework::trapAdd "echo '- SIGUSR1&2 overridden'" SIGUSR1 SIGUSR2
#   kill -SIGUSR1 $$
#   # output
#   # - SIGUSR1 original
#   # - SIGUSR1&2 overridden
#   kill -SIGUSR2 $$
#   # output
#   # - SIGUSR1&2 overridden
#
# @arg $1 trapAddCmd:String command to execute if trap
# @arg $@ signals:String[] signals to trap
# @exitcode 1 if traps not provided
# @see https://stackoverflow.com/a/7287873
Framework::trapAdd() {
  local trapAddCmd="$1"
  shift || Log::fatal "${FUNCNAME[0]} usage error"
  # helper fn to get existing trap command from `trap -p` output
  # shellcheck disable=SC2317
  extract_trap_cmd() { printf '%s\n' "$3"; }
  for trapAddName in "$@"; do
    trap -- "$(
      # print existing trap command with newline
      eval "extract_trap_cmd $(trap -p "${trapAddName}")"
      # print the new trap command
      printf '%s\n' "${trapAddCmd}"
    )" "${trapAddName}" ||
      Log::fatal "unable to add to trap ${trapAddName}"
  done
}
