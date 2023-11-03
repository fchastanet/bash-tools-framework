#!/usr/bin/env bash

Options::command() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "parse" ]]; then
    local -i options_parse_optionParsedCountFile
    ((options_parse_optionParsedCountFile = 0)) || true
    # shellcheck disable=SC2034
    local -i options_parse_parsedArgIndex=0
    while (($# > 0)); do
      local options_parse_arg="$1"
      local argOptDefaultBehavior=0
      case "${options_parse_arg}" in
        # Option 1/1
        # Option file --file|-f variableType String min 0 max 1 authorizedValues '' regexp ''
        --file | -f)
          shift
          if (($# == 0)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - a value needs to be specified"
            return 1
          fi
          if ((options_parse_optionParsedCountFile >= 1)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ((++options_parse_optionParsedCountFile))
          # shellcheck disable=SC2034
          file="$1"
          ;;
        -*)
          if [[ "${argOptDefaultBehavior}" = "0" ]]; then
            Log::displayError "Command ${SCRIPT_NAME} - Invalid option ${options_parse_arg}"
            return 1
          fi
          ;;
        *)
          if [[ "${argOptDefaultBehavior}" = "0" ]]; then
            Log::displayError "Command ${SCRIPT_NAME} - Argument - too much arguments provided"
            return 1
          fi
          ;;
      esac
      shift || true
    done
    Log::displayDebug "Command ${SCRIPT_NAME} - parse arguments: ${BASH_FRAMEWORK_ARGV[*]}"
    Log::displayDebug "Command ${SCRIPT_NAME} - parse filtered arguments: ${BASH_FRAMEWORK_ARGV_FILTERED[*]}"
  elif [[ "${options_parse_cmd}" = "help" ]]; then
    echo -e "$(Array::wrap " " 80 0 "${__HELP_TITLE_COLOR}DESCRIPTION:${__RESET_COLOR}" "super command")"
    echo

    echo -e "$(Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "${SCRIPT_NAME}" "[OPTIONS]")"
    echo -e "$(Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" \
      "${SCRIPT_NAME}" \
      "[--file|-f <String>]")"
    echo
    echo -e "${__HELP_TITLE_COLOR}OPTIONS:${__RESET_COLOR}"
    echo -e "  ${__HELP_OPTION_COLOR}--file${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-f <String>${__HELP_NORMAL} (optional) (at most 1 times)"
    local -a helpArray
    # shellcheck disable=SC2054
    helpArray=(file)
    echo -e "    $(Array::wrap " " 76 4 "${helpArray[@]}")"
    echo -e """very long help"""
  else
    Log::displayError "Command ${SCRIPT_NAME} - Option command invalid: '${options_parse_cmd}'"
    return 1
  fi
}
