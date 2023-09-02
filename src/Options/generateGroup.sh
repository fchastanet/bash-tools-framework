#!/usr/bin/env bash

# @description generate command parse function
# By default the name of the random generated function name
# is displayed as output of this function.
# By providing the option --function-name, the output of this
# function will be the generated function itself with the chosen name.
# @example
#   declare optionGroup=<% Options::generateGroup \
#     --title "Command global options" \
#     --help "The Console component adds some predefined options to all commands:"
#
# @arg $@ args:StringArray list of options/arguments variables references, allowing to link the options/arguments with this command
# @option --title <String|Function> (optional) provides group title
# @option --help <String|Function> provides command description help
# @option --function-name <String> the name of the function that will be generated
# @exitcode 1 if error during option parsing
# @stdout script file generated to group options and to be associated to options using --group option
# @stderr diagnostics information is displayed
# @see Options::generateOption
# @see doc/guides/Options/generateOption.md
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
        if
          ! Assert::posixFunctionName "${functionName}" &&
            ! Assert::bashFrameworkFunction "${functionName}"
        then
          Log::displayError "Options::generateOption - Option ${option} - only posix or bash framework function name are accepted - invalid '$1'"
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
