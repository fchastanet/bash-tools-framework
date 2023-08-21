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
Env::parseVerboseArg() {
  local envFile
  envFile="$(Framework::createTempFile "parseVerboseArgEnvFile")" || return 2

  (
    BASH_FRAMEWORK_ARGS_VERBOSE=${__VERBOSE_LEVEL_OFF}
    BASH_FRAMEWORK_DISPLAY_LEVEL=0
    local arg
    for arg in "${BASH_FRAMEWORK_ARGV[@]}"; do
      case "${arg}" in
        --verbose | -v)
          BASH_FRAMEWORK_ARGS_VERBOSE=${__VERBOSE_LEVEL_INFO}
          BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_INFO}
          ;;
        -vv)
          BASH_FRAMEWORK_ARGS_VERBOSE=${__VERBOSE_LEVEL_DEBUG}
          BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_DEBUG}
          ;;
        -vvv)
          BASH_FRAMEWORK_ARGS_VERBOSE=${__VERBOSE_LEVEL_TRACE}
          BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_DEBUG}
          ;;
        *)
          # ignore
          ;;
      esac
    done
    echo "BASH_FRAMEWORK_ARGS_VERBOSE=${BASH_FRAMEWORK_ARGS_VERBOSE}"
    if [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" != "0" ]]; then
      echo "BASH_FRAMEWORK_DISPLAY_LEVEL=${BASH_FRAMEWORK_DISPLAY_LEVEL}"
    fi
  ) >"${envFile}"
  echo "${envFile}"
}
