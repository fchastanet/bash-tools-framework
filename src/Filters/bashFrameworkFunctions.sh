#!/usr/bin/env bash

# @description allows to match a bash framework function based on the naming convention
# @warning this filter could extract bash framework functions that are actually commented in the source file
# @warning use FRAMEWORK_FUNCTIONS_IGNORE_REGEXP from .framework-config to filter unwanted functions
# @arg $@ files:String[] the files in which bash framework functions will be extracted
# @env PREFIX String an eventual prefix you would like to match
# @env FRAMEWORK_FUNCTIONS_IGNORE_REGEXP String this filter does not use this variable
# @exitcode 0 if match or no match
# @exitcode 2 if grep fails for other reasons
# @stdin you can alternatively provide content to filter via stdin
# @stdout the list of bash framework function detected
# @see [bash framework functions naming convention](/CompileCommand.md#bash_framework_functions_naming_convention)
# shellcheck disable=SC2120
Filters::bashFrameworkFunctions() {
  grep -Eo "${PREFIX:-}([A-Z]+[A-Za-z0-9_-]*::)+([a-zA-Z0-9_-]+)" "$@" || test $? = 1
}
