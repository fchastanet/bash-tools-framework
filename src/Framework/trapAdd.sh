#!/usr/bin/env bash

# appends a command to a trap
#
# - 1st arg:  code to add
# - remaining args:  names of traps to modify
#
Framework::trapAdd() {
  local trapAddCmd="$1"
  shift || Log::fatal "${FUNCNAME[0]} usage error"
  # helper fn to get existing trap command from output
  # of trap -p
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
