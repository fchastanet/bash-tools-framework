#!/usr/bin/env bash

Options::group() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "help" ]]; then
    eval "$(Options::group helpTpl)"
  elif [[ "${options_parse_cmd}" = "helpTpl" ]]; then
    echo $'    echo -e "${__HELP_TITLE_COLOR}Global options${__RESET_COLOR}"'
    echo $'    echo "help"'
  elif [[ "${options_parse_cmd}" = "id" ]]; then
    echo $'Options::group'
  else
    Log::displayError "Option group invalid: '${options_parse_cmd}'"
    return 1
  fi
}
