#!/usr/bin/env bash

# ability to call a command capturing output and exit code
# but displaying it also to error output to follow command's progress
# @global COMMAND_OUTPUT stdout of the command is returned in global variable COMMAND_OUTPUT
# @errorOutput command output
# @return exit code of the command
Command::captureOutputAndExitCode() {
  local command, logMessage, returnCode
  command=$1
  logMessage="$2"
  returnCode=1

  Log::displayInfo "Start - ${logMessage}"
  Log::displayDebug "execute command ${command}"

  # trick, we capture stdout in variable COMMAND_OUTPUT
  # and we copy also (via tee) stdout to stderr to be able to follow progress of the command
  # shellcheck disable=SC2034
  if COMMAND_OUTPUT=$(bash -c "${command}" | tee /dev/stderr); then
    returnCode=0
  fi

  return "${returnCode}"
}
