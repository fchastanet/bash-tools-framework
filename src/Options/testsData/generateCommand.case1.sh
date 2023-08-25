#!/usr/bin/env bash

Options::command() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    echo "parse"
  elif [[ "${cmd}" = "help" ]]; then
    Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}Description:${__RESET_COLOR}" ""
    echo

    Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "${SCRIPT_NAME}" "[OPTIONS]"
    Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" \
      "${SCRIPT_NAME}" \
      "helpAlt"
    echo
    echo -e "${__HELP_TITLE_COLOR}OPTIONS:${__RESET_COLOR}"
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
