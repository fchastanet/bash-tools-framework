#!/usr/bin/env bash

# @description Create an output directory, using a default if the provided path is empty
# @arg $1 outputDir:String the output directory path (can be empty)
# @arg $2 defaultOutputDir:String the default directory to use if outputDir is empty
# @set outputDir the resolved output directory path
# @exitcode 0 success - directory created or already exists
# @exitcode 1 failure - failed to create directory
# @stdout none
# @example
#   File::createOutputDir "${optionOutputDir}" "${optionDefaultOutputDir}" || return 1
File::createOutputDir() {
  local outputDir="$1"
  local defaultOutputDir="$2"

  # Use default if output directory is empty
  if [[ -z "${outputDir}" ]]; then
    outputDir="${defaultOutputDir}"
  fi

  # Create directory if it doesn't exist
  if [[ ! -d "${outputDir}" ]]; then
    if ! mkdir -p "${outputDir}"; then
      Log::displayError "Failed to create output directory '${outputDir}'"
      return 1
    fi
  fi

  # Export the resolved directory for use by caller
  printf '%s\n' "${outputDir}"
  return 0
}
