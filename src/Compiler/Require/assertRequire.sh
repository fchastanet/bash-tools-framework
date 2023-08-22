#!/usr/bin/env bash

# @description check if param is valid bash framework function
# @arg $1 requireFunctionName:String the require function
# @env _COMPILE_FILE_ARGUMENTS allows to override default compile arguments
# @exitcode 1 on invalid function name
# @exitcode 2 on function name not using require format
# @exitcode 3 on function not found
# @stderr diagnostics information is displayed
# @see Assert::
Compiler::Require::assertRequire() {
  local requireFunctionName="$1"

  Assert::bashFrameworkFunction "${requireFunctionName}" || {
    Log::displayError "Requirement '${requireFunctionName}' is not a valid bash framework function name"
    return 1
  }
  [[ "${requireFunctionName##*::}" =~ ^require[A-Z] ]] || {
    Log::displayError "Requirement '${requireFunctionName}' is not a valid require function name"
    return 2
  }

  # check if function exists
  local -a srcDirs
  readarray -t srcDirs < <(Compiler::Embed::getSrcDirsFromOptions "${_COMPILE_FILE_ARGUMENTS[@]}")

  Compiler::findFunctionInSrcDirs "${requireFunctionName}" "${srcDirs[@]}" >/dev/null || {
    Log::displayError "Require function '${requireFunctionName}' cannot be found in any src dirs: ${srcDirs[*]}"
    return 3
  }
}
