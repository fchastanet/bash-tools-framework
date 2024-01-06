#!/usr/bin/env bash

# @description check if param is valid resource embeddable
# the resource can be a bash framework function, a file or a directory
# @arg $1 resource:String the resource to embed
# @exitcode 1 on invalid file or directory
# @exitcode 2 on invalid bash framework function
# @env _EMBED_COMPILE_ARGUMENTS allows to override default compile arguments
# @stderr diagnostics information is displayed
# @see Compiler::Embed::embedBashFrameworkFunction
Compiler::Embed::assertResource() {
  local resource="$1"
  local -a srcDirs

  if Assert::bashFrameworkFunction "${resource}"; then
    # shellcheck disable=SC2030
    Compiler::Embed::getSrcDirsFromOptions "${_EMBED_COMPILE_ARGUMENTS[@]}" | readarray -t srcDirs
    # shellcheck disable=SC2031
    if ! Compiler::findFunctionInSrcDirs "${resource}" "${srcDirs[@]}" >/dev/null; then
      Log::displayError "Invalid embed resource '${resource}'. The bash framework function is not found in src dirs: ${srcDirs[*]}"
      return 2
    fi
  elif [[ ! -f "${resource}" && ! -d "${resource}" ]]; then
    Log::displayError "Invalid embed resource '${resource}'. The resource is neither a file, directory nor bash framework function"
    return 1
  fi
}
