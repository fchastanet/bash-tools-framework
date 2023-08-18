#!/usr/bin/env bash

# @description generate facade content from original script file
# @arg $1 scriptFile:String the file from which a facade will be generated
# @exitcode 1 on script file not found or non readable file
# @stderr diagnostics information is displayed
Compiler::Facade::generateFacadeContent() {
  local scriptFile="$1"

  Filters::directive "${FILTER_DIRECTIVE_REMOVE_HEADERS}" "${scriptFile}" | sed -E '{/^#!/d;}'
}
