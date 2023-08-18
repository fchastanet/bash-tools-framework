#!/usr/bin/env bash

# @description check if param is valid template file
# @arg $1 facadeTemplate:String the facade template file
# @env _COMPILE_FILE_ARGUMENTS allows to override default compile arguments
# @exitcode 1 on template file not found or non readable file
# @stderr diagnostics information is displayed
Compiler::Facade::assertFacadeTemplate() {
  local facadeTemplate="$1"
  if [[ ! -f "${facadeTemplate}" || ! -r "${facadeTemplate}" ]]; then
    Log::displayError "Facade template '${facadeTemplate}' is not readable"
    return 1
  fi
}
