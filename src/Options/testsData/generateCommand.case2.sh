#!/usr/bin/env bash

Options::command() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    verbose="0"
    local -i optionParsedCountVerbose
    ((optionParsedCountVerbose = 0)) || true
    while (($# > 0)); do
      local arg="$1"
      case "${arg}" in
        --verbose | -v)
          verbose="1"
          if ((optionParsedCountVerbose >= 1)); then
            Log::displayError "Option ${arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    export verbose
  elif [[ "${cmd}" = "help" ]]; then
    Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}Description:${__RESET_COLOR}" "super command"
    echo

    Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "${SCRIPT_NAME}" "[OPTIONS]"
    Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" \
      "${SCRIPT_NAME}" \
      "[--verbose|-v]"
    echo
    echo -e "${__HELP_TITLE_COLOR}OPTIONS:${__RESET_COLOR}"
    echo -n -e "  ${__HELP_OPTION_COLOR}"
    echo -n "--verbose, -v"
    echo -n -e "${__HELP_NORMAL}"
    echo -n -e ' (optional)'
    echo -n -e ' (at most 1 times)'
    echo
    echo '    verbose mode'
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
