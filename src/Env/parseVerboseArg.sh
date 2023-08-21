#!/usr/bin/env bash

# @description verbose level off
export __VERBOSE_LEVEL_OFF=0
# @description verbose level info
export __VERBOSE_LEVEL_INFO=1
# @description verbose level info
export __VERBOSE_LEVEL_DEBUG=2
# @description verbose level info
export __VERBOSE_LEVEL_TRACE=3

# @description if --verbose|-v option is parsed in arguments
# generates a conf file that will be loaded via Env::requireLoad
# @option -v verbose level short option (verbose level = info,  display level = info)
# @option --verbose verbose level long option (verbose level = info,  display level = info)
# @option -vv more verbose logs option (verbose level = debug, display level = debug)
# @option -vvv trace level logs option (verbose level = trace, display level = debug)
# @env BASH_FRAMEWORK_ARGV String[] list of arguments passed to the command (provided by _mandatoryHeaders.sh file)
# @set BASH_FRAMEWORK_ARGS_VERBOSE int 1 if -v, 2 if -vv, 3 if -vvv
# @set BASH_FRAMEWORK_DISPLAY_LEVEL int 3 if --verbose|-v, 4 if -vv or -vvv
# @require Env::requireRemoveVerboseArg
Env::parseVerboseArg() {
  local envFile
  envFile="$(Framework::createTempFile "parseVerboseArgEnvFile")" || return 2

  (
    local verbose=${__VERBOSE_LEVEL_OFF}
    local displayLevel=0
    local arg
    for arg in "${BASH_FRAMEWORK_ARGV[@]}"; do
      case "${arg}" in
        --verbose | -v)
          verbose=${__VERBOSE_LEVEL_INFO}
          displayLevel=${__LEVEL_INFO}
          ;;
        -vv)
          verbose=${__VERBOSE_LEVEL_DEBUG}
          displayLevel=${__LEVEL_DEBUG}
          ;;
        -vvv)
          verbose=${__VERBOSE_LEVEL_TRACE}
          displayLevel=${__LEVEL_DEBUG}
          ;;
        *)
          # ignore
          ;;
      esac
    done
    # compute resulting option
    local verboseOption=""
    case ${verbose} in
      "${__VERBOSE_LEVEL_INFO}")
        verboseOption="--verbose"
        ;;
      "${__VERBOSE_LEVEL_DEBUG}")
        verboseOption="-vv"
        ;;
      "${__VERBOSE_LEVEL_TRACE}")
        verboseOption="-vvv"
        ;;
      *) ;;
    esac

    echo "BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='${verboseOption}'"
    echo "BASH_FRAMEWORK_ARGS_VERBOSE=${verbose}"
    if [[ "${displayLevel}" != "0" ]]; then
      echo "BASH_FRAMEWORK_DISPLAY_LEVEL=${displayLevel}"
    fi
  ) >"${envFile}"
  echo "${envFile}"
}
