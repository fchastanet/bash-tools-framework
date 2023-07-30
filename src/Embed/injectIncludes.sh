#!/usr/bin/env bash

# finds all INCLUDE directives in the given script (stdin)
# and generates embedded script for each
# @param {array} injectIncludesEmbeddedNames $1 (passed by reference) list of names that have been embedded
# @param {array} injectIncludesEmbeddedResources $2 (passed by reference) list of resources that have been embedded
# @stdin pass the file in which the replacements will be done as stdin
# @stderr display list of skipped embed when importing the same asName twice
# @stderr if asName or resource is not correct
# @stderr if fail to embed resource
# @stdout embedded resources
# @return 1 on first include directive with invalid data
# @return 2 on first include directive embedding that fails
# @env _EMBED_COMPILE_ARGUMENTS allows to override default compile arguments
# @see Embed::includeBashFrameworkFunction
Embed::injectIncludes() {
  local -n injectIncludesEmbeddedNames=$1
  local -n injectIncludesEmbeddedResources=$2
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

  Embed::filterIncludes | {
    local line
    local resource
    local asName
    while IFS="" read -r line || [[ -n "${line}" ]]; do
      Embed::parseInclude "${line}" resource asName || return 1
      if Array::contains "${asName}" "${injectIncludesEmbeddedNames[@]}"; then
        Log::displaySkipped "Embed asName ${asName} has already been imported previously"
        continue
      fi
      if Array::contains "${resource}" "${injectIncludesEmbeddedResources[@]}"; then
        Log::displayWarning "Embed resource ${resource} has already been imported previously with a different name, ensure to deduplicate"
      fi
      if ! Embed::include "${resource}" "${asName}"; then
        Log::displayError "Failed to Embed ${asName} with resource ${resource}"
        return 2
      fi
      injectIncludesEmbeddedNames+=("${asName}")
      injectIncludesEmbeddedResources+=("${resource}")
    done
  }
}
