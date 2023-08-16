#!/usr/bin/env bash

# @description check if param is valid interface
# @arg $1 interface:String the interface function
# @env _EMBED_COMPILE_ARGUMENTS allows to override default compile arguments
# @exitcode 1 on invalid function name
# @exitcode 2 on function not found
# @exitcode 3 on error during call to interface
# @exitcode 4 on invalid interface (no output or invalid list)
# @exitcode 5 on invalid interface (list of invalid function names)
# @stderr diagnostics information is displayed
# @see Compiler::Implement::interfaceFunctions
Compiler::Implement::assertInterface() {
  local interface="$1"

  Compiler::Implement::interfaceFunctions "${interface}" >/dev/null
}
