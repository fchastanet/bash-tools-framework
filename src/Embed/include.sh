#!/usr/bin/env bash

# allow to embed selected resource providing the given name
# @param {string} resource $1
# @param {string} asName $2
# @env PERSISTENT_TMPDIR to avoid directory to be deleted by traps
# @env _COMPILE_ROOT_DIR
# @env _EMBED_COMPILE_ARGUMENTS allows to override default compile arguments
# @see Embed::includeBashFrameworkFunction to see why the use of
#      _EMBED_COMPILE_ARGUMENTS and _COMPILE_ROOT_DIR
Embed::include() {
  local resource="$1"
  local asName="$2"

  if ! Assert::validVariableName "${asName}"; then
    Log::displayError "invalid include name format ${asName}"
    return 1
  fi
  if [[ -f "${resource}" ]]; then
    Embed::includeFile "${resource}" "${asName}"
  elif [[ -d "${resource}" ]]; then
    Embed::includeDir "${resource}" "${asName}"
  elif Assert::bashFrameworkFunction "${resource}"; then
    Embed::includeFrameworkFunction "${resource}" "${asName}"
  else
    Log::displayError "invalid include ${resource}"
    return 1
  fi
}
