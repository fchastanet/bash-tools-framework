#!/bin/bash

# @description ignore exit code 141 from simple command pipes
# @example use with:
#   local resultingStatus=0
#   local -a originalPipeStatus=()
#   cmd1 | cmd2 || Bash::handlePipelineFailure resultingStatus originalPipeStatus || true
#   [[ "${resultingStatus}" = "0" ]]
# @arg $1 resultingStatusCode:&int (passed by reference) (optional) resulting status code
# @arg $2 originalStatus:int[] (passed by reference) (optional) copy of original PIPESTATUS array
# @env PIPESTATUS assuming that this function is called like in the example provided
# @see https://unix.stackexchange.com/a/709880/582856
# @see https://gitlab.alpinelinux.org/alpine/aports/-/issues/11152
# @warning alpine does not support PIPESTATUS very well as execution order of piped process is
# not guaranteed
Bash::handlePipelineFailure() {
  local -a pipeStatusBackup=("${PIPESTATUS[@]}")
  local -n handlePipelineFailure_resultingStatusCode=$1
  local -n handlePipelineFailure_originalStatus=$2
  # shellcheck disable=SC2034
  handlePipelineFailure_originalStatus=("${pipeStatusBackup[@]}")
  handlePipelineFailure_resultingStatusCode=0
  local statusCode
  for statusCode in "${pipeStatusBackup[@]}"; do
    if ((statusCode == 141)); then
      return 0
    elif ((statusCode > 0)); then
      # shellcheck disable=SC2034
      handlePipelineFailure_resultingStatusCode="${statusCode}"
      break
    fi
  done
  return "${handlePipelineFailure_resultingStatusCode}"
}
