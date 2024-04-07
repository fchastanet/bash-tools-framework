#!/usr/bin/env bash

# @description generate facade script from original script file
# and facade template provided
# @arg $1 scriptFile:String the file from which a facade will be generated
# @arg $2 facadeTemplate:String the facade template file
# @env _COMPILE_FILE_ARGUMENTS allows to override default compile arguments
# @exitcode 1 on generateFacadeHeaders failure
# @exitcode 2 on generateFacadeContent failure
# @exitcode 3 on generateFacadeChoiceScript failure
# @exitcode 4 on generateMainFunctionName failure
# @exitcode 5 if temp file cannot be created
# @stderr diagnostics information is displayed
Compiler::Facade::generateFacadeScript() {
  local scriptFile="$1"
  local facadeTemplate="$2"

  local facadeChoiceScriptTmpFile
  facadeChoiceScriptTmpFile="$(Framework::createTempFile "facadeChoiceScriptTmpFile")" || return 5
  local status=0
  Compiler::Facade::generateFacadeChoiceScript "${scriptFile}" >"${facadeChoiceScriptTmpFile}" || status=$?
  if [[ "${status}" = "2" ]]; then
    echo >"${facadeChoiceScriptTmpFile}"
  elif [[ "${status}" != "0" ]]; then
    return 3
  fi

  local facadeHeadersTmpFile
  facadeHeadersTmpFile="$(Framework::createTempFile "facadeHeadersTmpFile")" || return 5
  Compiler::Facade::generateFacadeHeaders "${scriptFile}" >"${facadeHeadersTmpFile}" || return 1

  local facadeContentTmpFile
  facadeContentTmpFile="$(Framework::createTempFile "facadeContentTmpFile")" || return 5
  Compiler::Facade::generateFacadeContent "${scriptFile}" >"${facadeContentTmpFile}" || return 2

  local mainFunctionName
  local scriptName="${scriptFile##*/}"
  mainFunctionName="facade_main_${scriptName//[^A-Za-z0-9]/}"

  echo "export FACADE_HEADERS_FILE='${facadeHeadersTmpFile}'"
  echo "export FACADE_CONTENT_FILE='${facadeContentTmpFile}'"
  echo "export FACADE_CHOICE_SCRIPT_FILE='${facadeChoiceScriptTmpFile}'"
  echo "export MAIN_FUNCTION_NAME='${mainFunctionName}'"
  echo "export file='${facadeTemplate}'"
}
