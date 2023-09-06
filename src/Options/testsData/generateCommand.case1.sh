#!/usr/bin/env bash

Options::command() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "parse" ]]; then
    local -i options_parse_optionParsedCountFile
    ((options_parse_optionParsedCountFile = 0)) || true
    local -i options_parse_parsedArgIndex=0
    while (($# > 0)); do
      local options_parse_arg="$1"
      case "${options_parse_arg}" in
        # Option 1/1
        # Option file --file|-f variableType String min 0 max 1 authorizedValues '' regexp ''
        --file | -f)
          shift
          if (($# == 0)); then
            Log::displayError "Option ${options_parse_arg} - a value needs to be specified"
            return 1
          fi
          if ((options_parse_optionParsedCountFile >= 1)); then
            Log::displayError "Option ${options_parse_arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ((++options_parse_optionParsedCountFile))
          file="$1"
          ;;
        -*)
          Log::displayError "Invalid option ${options_parse_arg}"
          return 1
          ;;
        *)
          Log::displayError 'Argument - too much arguments provided'
          return 1
          ;;
      esac
      shift || true
    done
    export file
  elif [[ "${options_parse_cmd}" = "help" ]]; then
    echo -e "$(Array::wrap " " 80 0 "${__HELP_TITLE_COLOR}Description:${__RESET_COLOR}" "super command")"
    echo

    echo -e "$(Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "${SCRIPT_NAME}" "[OPTIONS]")"
    echo -e "$(Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" \
      "${SCRIPT_NAME}" \
      "[--file|-f <String>]")"
    echo
    echo -e "${__HELP_TITLE_COLOR}OPTIONS:${__RESET_COLOR}"
    echo -n -e "  ${__HELP_OPTION_COLOR}"
    echo -n "--file, -f"
    echo -n ' <String>'
    echo -n -e "${__HELP_NORMAL}"
    echo -n -e ' (optional)'
    echo -n -e ' (at most 1 times)'
    echo
    echo "    file"
    echo -e """very long help"""
  else
    Log::displayError "Option command invalid: '${options_parse_cmd}'"
    return 1
  fi
}
