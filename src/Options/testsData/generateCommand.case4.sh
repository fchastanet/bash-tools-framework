#!/usr/bin/env bash

Options::command() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    verbose="0"
    local -i optionParsedCountVerbose
    ((optionParsedCountVerbose = 0)) || true
    local -i argParsedCountSrcFile
    ((argParsedCountSrcFile = 0)) || true
    local -i argParsedCountDestFiles
    ((argParsedCountDestFiles = 0)) || true
    local -i parsedArgIndex=0
    while (($# > 0)); do
      local arg="$1"
      case "${arg}" in
        # Option 1/2
        # Option verbose --verbose|-v variableType Boolean min 0 max 1 authorizedValues '' regexp ''
        --verbose | -v)
          verbose="1"
          if ((optionParsedCountVerbose >= 1)); then
            Log::displayError "Option ${arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ;;
        # Option 2/2
        # Option srcDirs --src-dirs|-s variableType StringArray min 0 max -1 authorizedValues '' regexp ''
        --src-dirs | -s)
          shift
          if (($# == 0)); then
            Log::displayError "Option ${arg} - a value needs to be specified"
            return 1
          fi
          srcDirs+=("$1")
          ;;
        -*)
          Log::displayError "Invalid option ${arg}"
          return 1
          ;;
        *)
          if ((0)); then
            # Technical if never reached
            :
          # Argument 1/2
          # Argument srcFile min 1 min 1 authorizedValues '' regexp ''
          elif ((parsedArgIndex >= 0 && parsedArgIndex < 1)); then
            if ((argParsedCountSrcFile >= 1)); then
              Log::displayError "Argument srcFile - Maximum number of argument occurrences reached(1)"
              return 1
            fi
            ((++argParsedCountSrcFile))
            srcFile="$1"
          # Argument 2/2
          # Argument destFiles min 1 min 3 authorizedValues '' regexp ''
          elif ((parsedArgIndex >= 1)); then
            if ((argParsedCountDestFiles >= 3)); then
              Log::displayError "Argument destFiles - Maximum number of argument occurrences reached(3)"
              return 1
            fi
            ((++argParsedCountDestFiles))
            destFiles+=("$1")
          fi
          ((++parsedArgIndex))
          ;;
      esac
      shift || true
    done
    export verbose
    export srcDirs
    if ((argParsedCountSrcFile < 1)); then
      Log::displayError "Argument 'srcFile' should be provided at least 1 time(s)"
      return 1
    fi
    export srcFile
    if ((argParsedCountDestFiles < 1)); then
      Log::displayError "Argument 'destFiles' should be provided at least 1 time(s)"
      return 1
    fi
    export destFiles
  elif [[ "${cmd}" = "help" ]]; then
    Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}Description:${__RESET_COLOR}" "super command"
    echo

    Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "${SCRIPT_NAME}" "[OPTIONS]" "[ARGUMENTS]"
    Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" \
      "${SCRIPT_NAME}" \
      "[--verbose|-v]" "[--src-dirs|-s <String>]"
    echo
    echo -e "${__HELP_TITLE_COLOR}OPTIONS:${__RESET_COLOR}"
    echo -n -e "  ${__HELP_OPTION_COLOR}"
    echo -n "--verbose, -v"
    echo -n -e "${__HELP_NORMAL}"
    echo -n -e ' (optional)'
    echo -n -e ' (at most 1 times)'
    echo
    echo '    verbose mode'
    echo -n -e "  ${__HELP_OPTION_COLOR}"
    echo -n "--src-dirs, -s"
    echo -n ' <String>'
    echo -n -e "${__HELP_NORMAL}"
    echo -n -e ' (optional)'
    echo
    echo '    provide the directory where to find the functions source code.'
    echo
    echo -e "${__HELP_TITLE_COLOR}ARGUMENTS:${__RESET_COLOR}"
    echo -e "  ${__HELP_OPTION_COLOR}srcFile${__HELP_NORMAL} {single} (mandatory)"
    echo '    No help available'
    echo -e "  ${__HELP_OPTION_COLOR}destFiles${__HELP_NORMAL} {list} (at least 1 times) (at most 3 times)"
    echo '    No help available'
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
