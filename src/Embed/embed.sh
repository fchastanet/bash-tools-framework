#!/usr/bin/env bash

# allow to embed selected resource providing the given name
# @arg $1 resource:string
# @arg $2 asName:string
# @env PERSISTENT_TMPDIR to avoid directory to be deleted by traps
# @env _COMPILE_ROOT_DIR
# @env _EMBED_COMPILE_ARGUMENTS allows to override default compile arguments
# @see Embed::embedBashFrameworkFunction to see why the use of
#      _EMBED_COMPILE_ARGUMENTS and _COMPILE_ROOT_DIR
Embed::embed() {
  local resource="$1"
  local asName="$2"

  if ! Assert::validVariableName "${asName}"; then
    Log::displayError "invalid embedded resource name format ${asName}"
    return 1
  fi
  if [[ -f "${resource}" ]]; then
    Embed::embedFile "${resource}" "${asName}"
  elif [[ -d "${resource}" ]]; then
    Embed::embedDir "${resource}" "${asName}"
  elif Assert::bashFrameworkFunction "${resource}"; then
    Embed::embedFrameworkFunction "${resource}" "${asName}"
  else
    Log::displayError "invalid embedded resource ${resource}"
    return 1
  fi
}
