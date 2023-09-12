#!/usr/bin/env bash

Options::command() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "parse" ]]; then
    verbose="0"
    local -i options_parse_optionParsedCountVerbose
    ((options_parse_optionParsedCountVerbose = 0)) || true
    local -i options_parse_argParsedCountSrcFile
    ((options_parse_argParsedCountSrcFile = 0)) || true
    local -i options_parse_argParsedCountDestFiles
    ((options_parse_argParsedCountDestFiles = 0)) || true
    local -i options_parse_parsedArgIndex=0
    while (($# > 0)); do
      local options_parse_arg="$1"
      case "${options_parse_arg}" in
        # Option 1/2
        # Option verbose --verbose|-v variableType Boolean min 0 max 1 authorizedValues '' regexp ''
        --verbose | -v)
          verbose="1"
          if ((options_parse_optionParsedCountVerbose >= 1)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ;;
        # Option 2/2
        # Option srcDirs --src-dirs|-s variableType StringArray min 0 max -1 authorizedValues '' regexp ''
        --src-dirs | -s)
          shift
          if (($# == 0)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - a value needs to be specified"
            return 1
          fi
          srcDirs+=("$1")
          ;;
        -*)
          Log::displayError "Command ${SCRIPT_NAME} - Invalid option ${options_parse_arg}"
          return 1
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
            srcFile="${options_parse_arg}"
          # Argument 2/2
          # Argument destFiles min 1 max 3 authorizedValues '' regexp ''
          elif ((options_parse_parsedArgIndex >= 1 && options_parse_parsedArgIndex < 4)); then
            if ((options_parse_argParsedCountDestFiles >= 3)); then
              Log::displayError "Command ${SCRIPT_NAME} - Argument destFiles - Maximum number of argument occurrences reached(3)"
              return 1
            fi
            ((++options_parse_argParsedCountDestFiles))
            destFiles+=("${options_parse_arg}")
          else
            Log::displayError "Command ${SCRIPT_NAME} - Argument - too much arguments provided: $*"
            return 1
          fi
          ((++options_parse_parsedArgIndex))
          ;;
      esac
      shift || true
    done
    export verbose
    export srcDirs
    if ((options_parse_argParsedCountSrcFile < 1)); then
      Log::displayError "Command ${SCRIPT_NAME} - Argument 'srcFile' should be provided at least 1 time(s)"
      return 1
    fi
    export srcFile
    if ((options_parse_argParsedCountDestFiles < 1)); then
      Log::displayError "Command ${SCRIPT_NAME} - Argument 'destFiles' should be provided at least 1 time(s)"
      return 1
    fi
    export destFiles
    Log::displayDebug "Command ${SCRIPT_NAME} - parse arguments: ${BASH_FRAMEWORK_ARGV[*]}"
    Log::displayDebug "Command ${SCRIPT_NAME} - parse filtered arguments: ${BASH_FRAMEWORK_ARGV_FILTERED[*]}"
  elif [[ "${options_parse_cmd}" = "help" ]]; then
    echo -e "$(Array::wrap " " 80 0 "${__HELP_TITLE_COLOR}DESCRIPTION:${__RESET_COLOR}" "super command")"
    echo

    echo -e "$(Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "${SCRIPT_NAME}" "[OPTIONS]" "[ARGUMENTS]")"
    echo -e "$(Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" \
      "${SCRIPT_NAME}" \
      "[--verbose|-v]" "[--src-dirs|-s <String>]")"
    echo
    echo -e "${__HELP_TITLE_COLOR}ARGUMENTS:${__RESET_COLOR}"
    echo -e "  ${__HELP_OPTION_COLOR}srcFile${__HELP_NORMAL} {single} (mandatory)"
    echo '    No help available'
    echo -e "  ${__HELP_OPTION_COLOR}destFiles${__HELP_NORMAL} {list} (at least 1 times) (at most 3 times)"
    echo '    No help available'
    echo
    echo -e "${__HELP_TITLE_COLOR}OPTIONS:${__RESET_COLOR}"
    printf "  %b\n" "${__HELP_OPTION_COLOR}--verbose${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-v${__HELP_NORMAL} (optional) (at most 1 times)"
    echo -e "    verbose mode"
    printf "  %b\n" "${__HELP_OPTION_COLOR}--src-dirs${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-s <String>${__HELP_NORMAL} (optional)"
    echo -e "    provide the directory where to find the functions source code."
  else
    Log::displayError "Command ${SCRIPT_NAME} - Option command invalid: '${options_parse_cmd}'"
    return 1
  fi
}
