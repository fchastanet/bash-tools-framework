#!/usr/bin/env bash

Options::command() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "parse" ]]; then
    local -i options_parse_argParsedCountSrcFile
    ((options_parse_argParsedCountSrcFile = 0)) || true
    # shellcheck disable=SC2034
    local -i options_parse_parsedArgIndex=0
    while (($# > 0)); do
      local options_parse_arg="$1"
      local argOptDefaultBehavior=0
      case "${options_parse_arg}" in
        -*)
          if [[ "${argOptDefaultBehavior}" = "0" ]]; then
            Log::displayError "Command ${SCRIPT_NAME} - Invalid option ${options_parse_arg}"
            return 1
          fi
          ;;
        *)
          if ((0)); then
            # Technical if - never reached
            :
          # Argument 1/1
          # Argument srcFile min 1 max 1 authorizedValues '' regexp ''
          elif ((options_parse_parsedArgIndex >= 0 && options_parse_parsedArgIndex < 1)); then
            if ((options_parse_argParsedCountSrcFile >= 1)); then
              Log::displayError "Command ${SCRIPT_NAME} - Argument srcFile - Maximum number of argument occurrences reached(1)"
              return 1
            fi
            ((++options_parse_argParsedCountSrcFile))
            # shellcheck disable=SC2034
            srcFile="${options_parse_arg}"
            everyArgumentCallback 'srcFile' "${options_parse_arg}" || true
          else
            everyArgumentCallback '' "${options_parse_arg}" || argOptDefaultBehavior=$?
            if [[ "${argOptDefaultBehavior}" = "0" ]]; then
              Log::displayError "Command ${SCRIPT_NAME} - Argument - too much arguments provided: $*"
              return 1
            fi
          fi
          ((++options_parse_parsedArgIndex))
          ;;
      esac
      shift || true
    done
    if ((options_parse_argParsedCountSrcFile < 1)); then
      Log::displayError "Command ${SCRIPT_NAME} - Argument 'srcFile' should be provided at least 1 time(s)"
      return 1
    fi
    Log::displayDebug "Command ${SCRIPT_NAME} - parse arguments: ${BASH_FRAMEWORK_ARGV[*]}"
    Log::displayDebug "Command ${SCRIPT_NAME} - parse filtered arguments: ${BASH_FRAMEWORK_ARGV_FILTERED[*]}"
  elif [[ "${options_parse_cmd}" = "help" ]]; then
    echo -e "$(Array::wrap " " 80 0 "${__HELP_TITLE_COLOR}DESCRIPTION:${__RESET_COLOR}" "super command")"
    echo

    echo -e "$(Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "${SCRIPT_NAME}" "[ARGUMENTS]")"
    echo
    echo -e "${__HELP_TITLE_COLOR}ARGUMENTS:${__RESET_COLOR}"
    echo -e "  ${__HELP_OPTION_COLOR}srcFile${__HELP_NORMAL} {single} (mandatory)"
    echo '    No help available'
  else
    Log::displayError "Command ${SCRIPT_NAME} - Option command invalid: '${options_parse_cmd}'"
    return 1
  fi
}
