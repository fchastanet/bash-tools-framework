#!/usr/bin/env bash

Options::command() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "parse" ]]; then
    help="0"
    local -i options_parse_optionParsedCountHelp
    ((options_parse_optionParsedCountHelp = 0)) || true
    verbose="0"
    local -i options_parse_optionParsedCountVerbose
    ((options_parse_optionParsedCountVerbose = 0)) || true
    quiet="0"
    local -i options_parse_optionParsedCountQuiet
    ((options_parse_optionParsedCountQuiet = 0)) || true
    local -i options_parse_argParsedCountSrcFile
    ((options_parse_argParsedCountSrcFile = 0)) || true
    local -i options_parse_argParsedCountDestFiles
    ((options_parse_argParsedCountDestFiles = 0)) || true
    # shellcheck disable=SC2034
    local -i options_parse_parsedArgIndex=0
    while (($# > 0)); do
      local options_parse_arg="$1"
      local argOptDefaultBehavior=0
      case "${options_parse_arg}" in
        # Option 1/4
        # Option help --help|-h variableType Boolean min 0 max 1 authorizedValues '' regexp ''
        --help | -h)
          # shellcheck disable=SC2034
          help="1"
          if ((options_parse_optionParsedCountHelp >= 1)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ((++options_parse_optionParsedCountHelp))
          helpCallback "${options_parse_arg}"
          ;;
        # Option 2/4
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
        # Option 3/4
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
        # Option 4/4
        # Option quiet --quiet|-q variableType Boolean min 0 max 1 authorizedValues '' regexp ''
        --quiet | -q)
          # shellcheck disable=SC2034
          quiet="1"
          if ((options_parse_optionParsedCountQuiet >= 1)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ((++options_parse_optionParsedCountQuiet))
          ;;
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
          # Argument 1/2
          # Argument srcFile min 1 max 1 authorizedValues '' regexp ''
          elif ((options_parse_parsedArgIndex >= 0 && options_parse_parsedArgIndex < 1)); then
            if ((options_parse_argParsedCountSrcFile >= 1)); then
              Log::displayError "Command ${SCRIPT_NAME} - Argument srcFile - Maximum number of argument occurrences reached(1)"
              return 1
            fi
            ((++options_parse_argParsedCountSrcFile))
            # shellcheck disable=SC2034
            srcFile="${options_parse_arg}"
            srcFileCallback "${srcFile}" -- "${@:2}"
          # Argument 2/2
          # Argument destFiles min 1 max 3 authorizedValues '' regexp ''
          elif ((options_parse_parsedArgIndex >= 1 && options_parse_parsedArgIndex < 4)); then
            if ((options_parse_argParsedCountDestFiles >= 3)); then
              Log::displayError "Command ${SCRIPT_NAME} - Argument destFiles - Maximum number of argument occurrences reached(3)"
              return 1
            fi
            ((++options_parse_argParsedCountDestFiles))
            # shellcheck disable=SC2034
            destFiles+=("${options_parse_arg}")
            destFilesCallback "${destFiles[@]}" -- "${@:2}"
          else
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
    if ((options_parse_argParsedCountDestFiles < 1)); then
      Log::displayError "Command ${SCRIPT_NAME} - Argument 'destFiles' should be provided at least 1 time(s)"
      return 1
    fi
    commandCallback
    Log::displayDebug "Command ${SCRIPT_NAME} - parse arguments: ${BASH_FRAMEWORK_ARGV[*]}"
    Log::displayDebug "Command ${SCRIPT_NAME} - parse filtered arguments: ${BASH_FRAMEWORK_ARGV_FILTERED[*]}"
  elif [[ "${options_parse_cmd}" = "help" ]]; then
    Array::wrap2 " " 80 0 "${__HELP_TITLE_COLOR}DESCRIPTION:${__RESET_COLOR}" "super command"
    echo

    echo -e "$(Array::wrap2 " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "${SCRIPT_NAME}" "[OPTIONS]" "[ARGUMENTS]")"
    echo -e "$(Array::wrap2 " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" \
      "${SCRIPT_NAME}" \
      "[--help|-h]" "[--src-dirs|-s <String>]" "[--verbose|-v]" "[--quiet|-q]")"
    echo
    echo -e "${__HELP_TITLE_COLOR}ARGUMENTS:${__RESET_COLOR}"
    echo -e "  ${__HELP_OPTION_COLOR}srcFile${__HELP_NORMAL} {single} (mandatory)"
    echo '    No help available'
    echo -e "  ${__HELP_OPTION_COLOR}destFiles${__HELP_NORMAL} {list} (at least 1 times) (at most 3 times)"
    echo '    No help available'
    echo
    echo -e "${__HELP_TITLE_COLOR}OPTIONS:${__RESET_COLOR}"
    echo -e "  ${__HELP_OPTION_COLOR}--help${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-h${__HELP_NORMAL} {single}"
    local -a helpArray
    # shellcheck disable=SC2054
    helpArray=(help)
    echo -e "    $(Array::wrap2 " " 76 4 "${helpArray[@]}")"
    echo -e "  ${__HELP_OPTION_COLOR}--src-dirs${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-s <String>${__HELP_NORMAL} {list} (optional)"
    local -a helpArray
    # shellcheck disable=SC2054
    helpArray=(provide\ the\ directory\ where\ to\ find\ the\ functions\ source\ code.)
    echo -e "    $(Array::wrap2 " " 76 4 "${helpArray[@]}")"
    echo
    echo -e "${__HELP_TITLE_COLOR}Command global options${__RESET_COLOR}"
    echo "The Console component adds some predefined options to all commands:"
    echo -e "  ${__HELP_OPTION_COLOR}--verbose${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-v${__HELP_NORMAL} {single}"
    local -a helpArray
    # shellcheck disable=SC2054
    helpArray=(verbose\ mode)
    echo -e "    $(Array::wrap2 " " 76 4 "${helpArray[@]}")"
    echo -e "  ${__HELP_OPTION_COLOR}--quiet${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-q${__HELP_NORMAL} {single}"
    local -a helpArray
    # shellcheck disable=SC2054
    helpArray=(quiet\ mode)
    echo -e "    $(Array::wrap2 " " 76 4 "${helpArray[@]}")"
  else
    Log::displayError "Command ${SCRIPT_NAME} - Option command invalid: '${options_parse_cmd}'"
    return 1
  fi
}
