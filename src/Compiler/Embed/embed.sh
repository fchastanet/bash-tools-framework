#!/usr/bin/env bash

# @description allow to embed selected resource providing the given name
# @arg $1 resource:string
# @arg $2 asName:string
# @env PERSISTENT_TMPDIR to avoid directory to be deleted by traps
# @env _COMPILE_ROOT_DIR
# @env _EMBED_COMPILE_ARGUMENTS allows to override default compile arguments
# @stderr diagnostics information is displayed
# @exitcode 1 if invalid asName
# @exitcode 2 if resource is neither a file, dir nor a bash framework function
# @see Compiler::Embed::embedBashFrameworkFunction to see why the use of _EMBED_COMPILE_ARGUMENTS and _COMPILE_ROOT_DIR
Compiler::Embed::embed() {
  local resource="$1"
  local asName="$2"

  if ! Assert::validVariableName "${asName}"; then
    Log::displayError "invalid embedded resource name format ${asName}"
    return 1
  fi
  if [[ -f "${resource}" ]]; then
    Compiler::Embed::embedFile "${resource}" "${asName}"
  elif [[ -d "${resource}" ]]; then
    Compiler::Embed::embedDir "${resource}" "${asName}"
  elif Assert::bashFrameworkFunction "${resource}"; then
    Compiler::Embed::embedFrameworkFunction "${resource}" "${asName}"
  else
    Log::displayError "invalid embedded resource ${resource}"
    return 2
  fi
}
