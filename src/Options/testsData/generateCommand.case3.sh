#!/usr/bin/env bash

Options::command() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "parse" ]]; then
    verbose="0"
    local -i options_parse_optionParsedCountVerbose
    ((options_parse_optionParsedCountVerbose = 0)) || true
    # shellcheck disable=SC2034
    local -i options_parse_parsedArgIndex=0
    while (($# > 0)); do
      local options_parse_arg="$1"
      local argOptDefaultBehavior=0
      case "${options_parse_arg}" in
        # Option 1/2
        # Option verbose --verbose|-v variableType Boolean min 0 max 1 authorizedValues '' regexp ''
        --verbose | -v)
          # shellcheck disable=SC2034
          verbose="1"
          if ((options_parse_optionParsedCountVerbose >= 1)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ((++options_parse_optionParsedCountVerbose))
          ;;
        # Option 2/2
        # Option srcDirs --src-dirs|-s variableType StringArray min 0 max -1 authorizedValues '' regexp ''
        --src-dirs | -s)
          shift
          if (($# == 0)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - a value needs to be specified"
            return 1
          fi
          ((++options_parse_optionParsedCountSrcDirs))
          srcDirs+=("$1")
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
    Array::wrap2 " " 80 0 "${__HELP_TITLE_COLOR}DESCRIPTION:${__RESET_COLOR}" "super command"
    echo

    echo -e "$(Array::wrap2 " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "${SCRIPT_NAME}" "[OPTIONS]")"
    echo -e "$(Array::wrap2 " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" \
      "${SCRIPT_NAME}" \
      "[--verbose|-v]" "[--src-dirs|-s <String>]")"
    echo
    echo -e "${__HELP_TITLE_COLOR}OPTIONS:${__RESET_COLOR}"
    echo -e "  ${__HELP_OPTION_COLOR}--verbose${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-v${__HELP_NORMAL} {single}"
    local -a helpArray
    # shellcheck disable=SC2054
    helpArray=(verbose\ mode)
    echo -e "    $(Array::wrap2 " " 76 4 "${helpArray[@]}")"
    echo -e "  ${__HELP_OPTION_COLOR}--src-dirs${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-s <String>${__HELP_NORMAL} {list} (optional)"
    local -a helpArray
    # shellcheck disable=SC2054
    helpArray=(provide\ the\ directory\ where\ to\ find\ the\ functions\ source\ code.)
    echo -e "    $(Array::wrap2 " " 76 4 "${helpArray[@]}")"
  else
    Log::displayError "Command ${SCRIPT_NAME} - Option command invalid: '${options_parse_cmd}'"
    return 1
  fi
}
