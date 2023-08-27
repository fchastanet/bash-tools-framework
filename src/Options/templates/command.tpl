#!/usr/bin/env bash

<% ${commandFunctionName} %>() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "parse" ]]; then
    .INCLUDE "${tplDir}/command.parse.tpl"
  elif [[ "${options_parse_cmd}" = "help" ]]; then
    .INCLUDE "${tplDir}/command.help.tpl"
  else
    Log::displayError "Option command invalid: '${options_parse_cmd}'"
    return 1
  fi
}
