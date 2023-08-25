#!/usr/bin/env bash

Options::command() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    local -i optionParsedCountFile
    ((optionParsedCountFile = 0)) || true
    while (($# > 0)); do
      local arg="$1"
      case "${arg}" in
        --file | -f)
          shift
          if (($# == 0)); then
            Log::displayError "Option ${arg} - a value needs to be specified"
            return 1
          fi
          if ((optionParsedCountFile >= 1)); then
            Log::displayError "Option ${arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ((++optionParsedCountFile))
          file="$1"
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    export file
  elif [[ "${cmd}" = "help" ]]; then
    Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}Description:${__RESET_COLOR}" "super command"
    echo

    Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "${SCRIPT_NAME}" "[OPTIONS]"
    Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" \
      "${SCRIPT_NAME}" \
      "[--file|-f <String>]"
    echo
    echo -e "${__HELP_TITLE_COLOR}OPTIONS:${__RESET_COLOR}"
    echo -n -e "  ${__HELP_OPTION_COLOR}"
    echo -n "--file, -f"
    echo -n ' <String>'
    echo -n -e "${__HELP_NORMAL}"
    echo -n -e ' (optional)'
    echo -n -e ' (at most 1 times)'
    echo
    echo '    file'
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
