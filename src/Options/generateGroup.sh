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
# Usage:  Options::generateGroup [OPTIONS]
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
#   Options::generateGroup \
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
Options::generateGroup() {
  # args default values
  local title=""
  local help=""
  local functionName=""

  setArg() {
    local option="$1"
    local -n argToSet="$2"
    local argCountAfterShift="$3"
    local value="$4"

    if ((argCountAfterShift == 0)); then
      Log::displayError "Options::generateGroup - Option ${option} - a value needs to be specified"
      return 1
    fi
    if [[ -n "${argToSet}" ]]; then
      Log::displayError "Options::generateGroup - only one ${option} option can be provided"
      return 1
    fi
    argToSet="${value}"
  }

  while (($# > 0)); do
    local option="$1"
    case "${option}" in
      --title)
        shift
        setArg "${option}" title "$#" "$1" || return 1
        ;;
      --help)
        shift
        setArg "${option}" help "$#" "$1" || return 1
        ;;
      --function-name)
        shift
        setArg "${option}" functionName "$#" "$1" || return 1
        if ! Assert::posixFunctionName "$1"; then
          Log::displayError "Options::generateOption - Option ${option} - only posix name is accepted - invalid '$1'"
          return 1
        fi
        ;;
      *)
        Log::displayError "Options::generateGroup - invalid option ${option}"
        return 1
        ;;
    esac
    shift || true
  done
  if [[ -z "${title}" ]]; then
    Log::displayError "Options::generateGroup - option --title is mandatory"
    return 1
  fi

  (
    # export current values
    export title
    export help
    export functionName
    export tplDir="${_COMPILE_ROOT_DIR}/src/Options/templates"

    Options::generateFunction "${functionName}" "group" || return 3
  ) || return $?
}
