#!/usr/bin/env bash

# @description merge and load conf files specified as argument
# - files are cleaned from ay comment
# - missing quotes after property = sign are added automatically
# - automatic remove of all whitespace before and after declarations
# - bash arrays are not supported
# - if a variable is declared in first file and overridden later on
#   in the same file or in subsequent files, those overloads will be
#   ignored
# @warning if an error occurs while loading one of the config file, exit code 3 but environment could be partially loaded
# @arg $@ args:String[] list of configuration files to load in order
# @set envVars String will set in environment all the variables that have been declared in the config files
# @env envVars String the env variables of the current script could be used to interpret variables during config files parsing
# @exitcode 0 if no config files provided or load completed successfully
# @exitcode 1 if error occurred during parsing the config files (file not found, grep, awk or sed error)
# @exitcode 2 if temporary file cannot be created
# @exitcode 3 if an error occurred during config file sourcing
# @stderr diagnostics information is displayed
# @see largely inspired but modified from https://opensource.com/article/21/5/processing-configuration-files-shell
Env::mergeConfFiles() {
  local -a configFileList=("$@")

  if ((${#configFileList[@]} == 0)); then
    return 0
  fi

  local combinedConfigFile
  combinedConfigFile="$(Framework::createTempFile "mergeConfFiles")" || return 2
  (
    # removes any trailing whitespace from each file, if any
    # this is absolutely required when importing into ConfigMaps
    # put quotes around values
    sed -E -e $'s/\s*$// ; /^$/d ; /^#.*$/d ; s/=([^"\'].*)$/="\\1"/' "${configFileList[@]}" |
      # remove all comment lines
      Filters::commentLines |
      # iterates over each file and prints (default awk behavior)
      # each unique line; only takes first value and ignores duplicates
      awk -F= '!line[$1]++'
  ) >"${combinedConfigFile}" || return 1

  # have to export everything, and source it twice:
  # 1) first source is to realize variables
  # 2) second time is to realize references
  set -o allexport
  # shellcheck source=.framework-config
  source "${combinedConfigFile}" || return 3
  # shellcheck source=.framework-config
  source "${combinedConfigFile}" || return 3
  set +o allexport
}
