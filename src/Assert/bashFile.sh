#!/usr/bin/env bash

# @description ensure that file begin with a bash shebang
# @arg $1 file:String
# @exitcode 1 if file doesn't have a bash shebang
# @exitcode 2 if file doesn't exist
Assert::bashFile() {
  local file="$1"
  local head=""
  if [[ ! -f "${file}" ]]; then
    return 2
  fi
  head="$(head -n 1 "${file}")"
  [[ "${head}" =~ ^#\!.*bash ]]
}
