#!/usr/bin/env bash

# @description filters and parses the FACADE directive of given file
# and constructs the facade script file from the facade template
# @arg $1 scriptFile:String the file to parse
# @arg $2 defaultFacadeTemplate:String the default facade template to use when no template is provided in FACADE directive
# @exitcode 1 if more that one FACADE directive is used
# @exitcode 2 if the FACADE directive failed to be parsed
# @exitcode 3 if an error occurred during filtering directives
# @stdout the file path that needs to be compiled (it can be the scriptFile itself if no facade has been found)
# @stderr diagnostics information is displayed
Compiler::Facade::facade() {
  local scriptFile="$1"
  local defaultFacadeTemplate="${2:-${TEMPLATE_DIR}/_includes/facadeDefault/facadeDefault.tpl}"

  local facadeDirectives
  facadeDirectives="$(Compiler::Facade::filter "${scriptFile}")" || return 3
  local -a facadeDirectivesArray

  readarray -t facadeDirectivesArray <<<"${facadeDirectives}"
  # if empty string, there will be one element
  if ((${#facadeDirectivesArray[@]} == 0)) || [[ -z "${facadeDirectives}" ]]; then
    Log::displaySkipped "no facade found in ${scriptFile}"
    return 0
  elif ((${#facadeDirectivesArray[@]} > 1)); then
    Log::displayError "A script file can only use one FACADE directive"
    return 1
  fi

  local facadeTemplate=""
  Compiler::Facade::parse "${facadeDirectivesArray[0]}" facadeTemplate || {
    # already logged
    return 2
  }
  if [[ -z "${facadeTemplate}" ]]; then
    facadeTemplate="${defaultFacadeTemplate}"
  fi

  Compiler::Facade::generateFacadeScript "${scriptFile}" "${facadeTemplate}"
}
