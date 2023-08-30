#!/usr/bin/env bash

Options::command() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "parse" ]]; then
    quiet="0"
    local -i options_parse_optionParsedCountQuiet
    ((options_parse_optionParsedCountQuiet = 0)) || true
    verbose="0"
    local -i options_parse_optionParsedCountVerbose
    ((options_parse_optionParsedCountVerbose = 0)) || true
    help="0"
    local -i options_parse_optionParsedCountHelp
    ((options_parse_optionParsedCountHelp = 0)) || true
    local -i options_parse_argParsedCountSrcFile
    ((options_parse_argParsedCountSrcFile = 0)) || true
    local -i options_parse_argParsedCountDestFiles
    ((options_parse_argParsedCountDestFiles = 0)) || true
    local -i options_parse_parsedArgIndex=0
    while (($# > 0)); do
      local options_parse_arg="$1"
      case "${options_parse_arg}" in
        # Option 1/4
        # Option quiet --quiet|-q variableType Boolean min 0 max 1 authorizedValues '' regexp ''
        --quiet | -q)
          quiet="1"
          if ((options_parse_optionParsedCountQuiet >= 1)); then
            Log::displayError "Option ${options_parse_arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ;;
        # Option 2/4
        # Option verbose --verbose|-v variableType Boolean min 0 max 1 authorizedValues '' regexp ''
        --verbose | -v)
          verbose="1"
          if ((options_parse_optionParsedCountVerbose >= 1)); then
            Log::displayError "Option ${options_parse_arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ;;
        # Option 3/4
        # Option help --help|-h variableType Boolean min 0 max 1 authorizedValues '' regexp ''
        --help | -h)
          help="1"
          if ((options_parse_optionParsedCountHelp >= 1)); then
            Log::displayError "Option ${options_parse_arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          helpCallback "${help}"
          ;;
        # Option 4/4
        # Option srcDirs --src-dirs|-s variableType StringArray min 0 max -1 authorizedValues '' regexp ''
        --src-dirs | -s)
          shift
          if (($# == 0)); then
            Log::displayError "Option ${options_parse_arg} - a value needs to be specified"
            return 1
          fi
          srcDirs+=("$1")
          ;;
        -*)
          Log::displayError "Invalid option ${options_parse_arg}"
          return 1
          ;;
        *)
          if ((0)); then
            # Technical if never reached
            :
          # Argument 1/2
          # Argument srcFile min 1 min 1 authorizedValues '' regexp ''
          elif ((options_parse_parsedArgIndex >= 0 && options_parse_parsedArgIndex < 1)); then
            if ((options_parse_argParsedCountSrcFile >= 1)); then
              Log::displayError "Argument srcFile - Maximum number of argument occurrences reached(1)"
              return 1
            fi
            ((++options_parse_argParsedCountSrcFile))
            srcFile="${options_parse_arg}"
            srcFileCallback "${srcFile}"
          # Argument 2/2
          # Argument destFiles min 1 min 3 authorizedValues '' regexp ''
          elif ((options_parse_parsedArgIndex >= 1)); then
            if ((options_parse_argParsedCountDestFiles >= 3)); then
              Log::displayError "Argument destFiles - Maximum number of argument occurrences reached(3)"
              return 1
            fi
            ((++options_parse_argParsedCountDestFiles))
            destFiles+=("${options_parse_arg}")
            destFilesCallback "${destFiles[@]}"
          fi
          ((++options_parse_parsedArgIndex))
          ;;
      esac
      shift || true
    done
    export quiet
    export verbose
    export help
    export srcDirs
    if ((options_parse_argParsedCountSrcFile < 1)); then
      Log::displayError "Argument 'srcFile' should be provided at least 1 time(s)"
      return 1
    fi
    export srcFile
    if ((options_parse_argParsedCountDestFiles < 1)); then
      Log::displayError "Argument 'destFiles' should be provided at least 1 time(s)"
      return 1
    fi
    export destFiles
  elif [[ "${options_parse_cmd}" = "help" ]]; then
    echo -e "$(Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}Description:${__RESET_COLOR}" "super command")"
    echo

    echo -e "$(Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "${SCRIPT_NAME}" "[OPTIONS]" "[ARGUMENTS]")"
    echo -e "$(Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" \
      "${SCRIPT_NAME}" \
      "[--quiet|-q]" "[--verbose|-v]" "[--help|-h]" "[--src-dirs|-s <String>]")"
    echo
    echo -e "${__HELP_TITLE_COLOR}ARGUMENTS:${__RESET_COLOR}"
    echo -e "  ${__HELP_OPTION_COLOR}srcFile${__HELP_NORMAL} {single} (mandatory)"
    echo '    No help available'
    echo -e "  ${__HELP_OPTION_COLOR}destFiles${__HELP_NORMAL} {list} (at least 1 times) (at most 3 times)"
    echo '    No help available'
    echo
    echo -e "${__HELP_TITLE_COLOR}Command global options${__RESET_COLOR}"
    echo "The Console component adds some predefined options to all commands:"
    echo -n -e "  ${__HELP_OPTION_COLOR}"
    echo -n "--quiet, -q"
    echo -n -e "${__HELP_NORMAL}"
    echo -n -e ' (optional)'
    echo -n -e ' (at most 1 times)'
    echo
    echo '    quiet mode'
    echo -n -e "  ${__HELP_OPTION_COLOR}"
    echo -n "--verbose, -v"
    echo -n -e "${__HELP_NORMAL}"
    echo -n -e ' (optional)'
    echo -n -e ' (at most 1 times)'
    echo
    echo '    verbose mode'
    echo -e "${__HELP_TITLE_COLOR}OPTIONS:${__RESET_COLOR}"
    echo -n -e "  ${__HELP_OPTION_COLOR}"
    echo -n "--help, -h"
    echo -n -e "${__HELP_NORMAL}"
    echo -n -e ' (optional)'
    echo -n -e ' (at most 1 times)'
    echo
    echo '    help'
    echo -n -e "  ${__HELP_OPTION_COLOR}"
    echo -n "--src-dirs, -s"
    echo -n ' <String>'
    echo -n -e "${__HELP_NORMAL}"
    echo -n -e ' (optional)'
    echo
    echo '    provide the directory where to find the functions source code.'
  else
    Log::displayError "Option command invalid: '${options_parse_cmd}'"
    return 1
  fi
}
