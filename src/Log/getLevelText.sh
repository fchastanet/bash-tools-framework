#!/usr/bin/env bash

# @description Get the text representation of a log level
# @arg $1 level:String the log level to convert
# @exitcode 1 if the level is invalid
Log::getLevelText() {
  local level="$1"
  case "${level}" in
    "${__LEVEL_OFF}")
      echo OFF
      ;;
    "${__LEVEL_ERROR}")
      echo ERROR
      ;;
    "${__LEVEL_WARNING}")
      echo WARNING
      ;;
    "${__LEVEL_INFO}")
      echo INFO
      ;;
    "${__LEVEL_DEBUG}")
      echo DEBUG
      ;;
    *)
      Log::displayError "Command ${SCRIPT_NAME} - Invalid level ${level}"
      return 1
      ;;
  esac
}
