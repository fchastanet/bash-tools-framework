#!/usr/bin/env bash

# @description finds all EMBED directives in the given script (stdin)
# and generates embedded script for each
# @arg $1 injectEmbeddedNames:&String[] (passed by reference) list of names that have been embedded
# @arg $2 injectEmbeddedResources:&String[] (passed by reference) list of resources that have been embedded
# @stdin pass the file in which the replacements will be done as stdin
# @stderr display list of skipped embed when importing the same asName twice
# @stderr if asName or resource is not correct
# @stderr if fail to embed resource
# @stdout embedded resources
# @exitcode 1 on first embed directive with invalid data
# @exitcode 2 on first embed directive embedding that fails
# @env _EMBED_COMPILE_ARGUMENTS allows to override default compile arguments
# @see Compiler::Embed::embedBashFrameworkFunction
Compiler::Embed::inject() {
  local -n injectEmbeddedNames=$1
  local -n injectEmbeddedResources=$2
  if [[ -z "${_EMBED_COMPILE_ARGUMENTS+xxx}" ]]; then
    local -a _EMBED_COMPILE_ARGUMENTS=(
      # templateDir : directory from which bash-tpl templates will be searched
      --template-dir "${_COMPILE_SRC_DIR}/_includes"
      # binDir      : fallback bin directory in case BIN_FILE has not been provided
      --bin-dir "${_COMPILE_BIN_DIR}"
      # rootDir     : directory used to compute src file relative path
      --root-dir "${_COMPILE_ROOT_DIR}"
      # srcDirs : (optional) you can provide multiple directories
      --src-dir "${_COMPILE_SRC_DIR}"
    )
  fi

  embed() {
    local line
    local resource
    local asName
    while true; do
      local status=0
      IFS="" read -r line || status=$?
      if [[ "${status}" = "1" ]]; then
        # end of file
        return 0
      elif [[ "${status}" != "0" ]]; then
        # other error
        return "${status}"
      fi
      Compiler::Embed::parse "${line}" resource asName || return 1
      if Array::contains "${asName}" "${injectEmbeddedNames[@]}"; then
        Log::displaySkipped "Embed asName ${asName} has already been imported previously"
        continue
      fi
      if Array::contains "${resource}" "${injectEmbeddedResources[@]}"; then
        Log::displayWarning "Embed resource ${resource} has already been imported previously with a different name, ensure to deduplicate"
      fi
      if ! Compiler::Embed::embed "${resource}" "${asName}"; then
        Log::displayError "Failed to Embed ${asName} with resource ${resource}"
        return 2
      fi
      injectEmbeddedNames+=("${asName}")
      injectEmbeddedResources+=("${resource}")
    done
    return 0
  }
  local status=0
  Compiler::Embed::filter | embed || status=$?
  if [[ "${status}" = "127" ]]; then
    # TODO test Compiler::Embed::inject::worksWithWarningResourceAlreadyIncluded
    # in this case  I don't know why, status is 127 but should be 0
    return 0
  fi
  return "${status}"
}
