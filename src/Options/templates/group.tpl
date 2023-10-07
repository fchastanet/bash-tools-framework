#!/usr/bin/env bash

<% ${functionName} %>() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "help" ]]; then
    eval "$(<% ${functionName} %> helpTpl)"
  elif [[ "${options_parse_cmd}" = "helpTpl" ]]; then
    echo $'    echo -e "${__HELP_TITLE_COLOR}<% ${title} %>${__RESET_COLOR}"'
    % if [[ -n "${help}" ]]; then
    echo $'    echo "<% ${help} %>"'
    % fi
  elif [[ "${options_parse_cmd}" = "id" ]]; then
    echo $'<% ${functionName} %>'
  else
    Log::displayError "Option group invalid: '${options_parse_cmd}'"
    return 1
  fi
}
