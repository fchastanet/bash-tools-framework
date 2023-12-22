#!/usr/bin/env bash

# @description Generates a function that allows to manipulate a group of options.
# function generated allows group options using `--group` option when
# using `Options::generateOption`
#
# #### Output on stdout
#
# By default the name of the random generated function name
# is displayed as output of this function.
# By providing the option `--function-name`, the output of this
# function will be the generated function itself with the chosen name.
#
# #### Syntax
#
# ```text
# Usage:  Options2::validateGroupObject [OPTIONS]
#
# OPTIONS:
#   --title <String|Function>
#   [--help <String|Function>]
#   [--function-name <String>]
# ```
#
# #### Example
#
# ```bash
# declare optionGroup="$(
#   Options2::validateGroupObject \
#     --title "Command global options" \
#     --help "The Console component adds some predefined options to all commands:"
# )"
# Options::sourceFunction "${optionGroup}"
# "${optionGroup}" help
# ```
#
# @option --title <String|Function> (mandatory) provides group title
# @option --help <String|Function> (optional) provides command description help
# @option --function-name <String> (optional) the name of the function that will be generated
# @exitcode 1 if error during option parsing
# @exitcode 1 if bash-tpl error during template rendering
# @exitcode 2 if file generation error (only if functionName argument empty)
# @stderr diagnostics information is displayed
# @see [generateCommand function](#/doc/guides/Options/generateCommand)
# @see [generateOption function](#/doc/guides/Options/generateOption)
# @see [group function](#/doc/guides/Options/functionGroup)
Options2::validateGroupObject() {
  if (( $# != 1 )); then
    Log::displayError "Options2::validateGroupObject - exactly one parameter has to be provided"
    return 1
  fi
  
  local groupInstanceObject=$1
  if [[ "$("${groupInstanceObject}" type 2>/dev/null || echo '')" != "Group" ]]; then
    Log::displayError "Options2::validateGroupObject - passed object is not a group"
    return 2
  fi
  if ! "${groupInstanceObject}" get title &>/dev/null; then
    Log::displayError "Options2::validateGroupObject - title is mandatory"
    return 3
  fi
}
