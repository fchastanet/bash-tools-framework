#!/usr/bin/env bash

<% ${groupFunctionName} %>() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "help" ]]; then
    eval "$(<% ${groupFunctionName} %> helpTpl)"
  elif [[ "${options_parse_cmd}" = "helpTpl" ]]; then
    echo $'    echo -e "${__HELP_TITLE_COLOR}<% ${title} %>${__RESET_COLOR}"'
    echo $'    echo "<% ${help} %>"'
  elif [[ "${options_parse_cmd}" = "id" ]]; then
    echo $'<% ${id} %>'
  else
    Log::displayError "Option group invalid: '${options_parse_cmd}'"
    return 1
  fi
}
