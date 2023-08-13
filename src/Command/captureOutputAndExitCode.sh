#!/usr/bin/env bash

# @description ability to call a command capturing output and exit code
# but displaying it also to error output to follow command's progress
# command output is sent to COMMAND_OUTPUT and stderr as well in realtime using tee
# @arg * command:String[] the command to execute
# @set COMMAND_OUTPUT String stdout of the command is returned in global variable COMMAND_OUTPUT
# @stderr command output
# @exitcode * exit code of the command
Command::captureOutputAndExitCode() {

  # reset COMMAND_OUTPUT before launching the command
  unset COMMAND_OUTPUT

  # trick, we capture stdout in variable COMMAND_OUTPUT
  # and we copy also (via tee) stdout to stderr to be able to follow progress of the command
  # shellcheck disable=SC2034
  COMMAND_OUTPUT=$(bash -c "$*" | tee /dev/stderr) || return $?
}
