#!/usr/bin/env bash

# global variables used by Framework::run
declare -gx bash_framework_status
declare -gix bash_framework_duration
declare -gx bash_framework_output

# @description run command and store data in global variables
# - bash_framework_status
# - bash_framework_duration
# - bash_framework_output
# redirecting error output to stdout is not supported, you can instead redirect stderr to a file if needed
#
# @arg $@ command:String[] command with arguments to execute
#
# @set bash_framework_status the exit status of the command
# @set bash_framework_duration the duration of the command
# @set bash_framework_output the output of the command
#
# @see Command::captureOutputAndExitCode as an alternative
Framework::run() {
  # 'bash_framework_status', 'bash_framework_duration' are global variables
  local -i start end
  start=$(date +%s)
  bash_framework_status=0
  bash_framework_output=""

  local origFlags="$-"
  set +eET
  local origIFS="${IFS}"

  # execute command
  # shellcheck disable=SC2034
  bash_framework_output="$("$@")"
  # shellcheck disable=SC2034
  bash_framework_status="$?"
  IFS="${origIFS}"
  set "-${origFlags}"

  # calculate duration
  end=$(date +%s)
  # shellcheck disable=SC2034
  bash_framework_duration=$((end - start))
}
