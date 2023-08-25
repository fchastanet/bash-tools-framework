#!/usr/bin/env bash

<% ${commandFunctionName} %>() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    echo "parse"
  elif [[ "${cmd}" = "help" ]]; then
    .INCLUDE "${tplDir}/commandHelp.tpl"
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
