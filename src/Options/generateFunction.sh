#!/usr/bin/env bash

# @description generate function using the bash-tpl
# template provided
# if functionName argument is empty, a random
# functionName will be generated automatically
# if functionName argument is provided, the function
# will be directly outputted
# @arg $1 functionName:String the functionName (if empty string a function name will be generated)
# @arg $2 templateName:String the template to use without .tpl extension available in tplDir directory
# @arg $3 tplDir:String (optional) default value: ${_COMPILE_ROOT_DIR}/src/Options/templates
# @env _COMPILE_ROOT_DIR String the root dir provided by the compiler
# @exitcode 1 if bash-tpl error during template rendering
# @exitcode 2 if file generation error (only if functionName argument empty)
# @stdout random function name generated if functionName argument empty, else the generated function
# @stderr diagnostics information is displayed
Options::generateFunction() {
  local functionName="$1"
  local templateName="$2"
  local tplDir="${3:-${_COMPILE_ROOT_DIR}/src/Options/templates}"
  export tplDir
  interpretTemplate() {
    Options::bashTpl "${tplDir}/${templateName}.tpl" |
      sed -E -e 's/[\t ]+$//' || return 1
  }
  export functionName
  if [[ -z "${functionName}" ]]; then
    # generate a function name that will be the output of this script
    local baseFunctionName
    baseFunctionName=$(Options::generateFunctionName "${templateName}" "") || return 1
    functionName="Options::${baseFunctionName}"

    # interpret the template
    local functionTmpFile
    functionTmpFile="${TMPDIR}/src/Options/${baseFunctionName}.sh"
    mkdir -p "$(dirname "${functionTmpFile}")" || return 2
    interpretTemplate >"${functionTmpFile}" || return 1
    Log::displayDebug "Generated function in ${functionTmpFile}"

    # display the generated function name
    echo "${functionName}"
  else
    # display the generated function
    interpretTemplate || return 1
  fi
}
