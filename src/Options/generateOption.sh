#!/usr/bin/env bash

# @description Generates a function that allows to manipulate an option.
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
# Usage:  Options::generateOption [OPTIONS] [TYPE_OPTIONS]
#
# Options::generateOption[OPTIONS]
#
# OPTIONS:
#   --alt <optionName>
#   --variable-name | --var <optionVariableName>
#   [--variable-type <String|Function>]
#   [--mandatory]
#   [--help <String|Function>]
#   [--group <Function>]
#   [--callback <Function>]
#   [--function-name <String>]
#
# TYPE_OPTIONS: see Boolean/String/StringArray option documentation
# ```
#
# #### Example
#
# ```bash
# declare myOption="$(
#   Options::generateOption \
#     --variable-name "srcDirs" \
#     --alt "-s" \
#     --alt "--src-dir" \
#     --variable-type "StringArray" \
#     --required \
#     --help "provides the directory where to find the functions source code."
# )"
# Options::sourceFunction "${myOption}"
# "${myOption}" parse "$@"
# ```
#
# #### Callback
#
# the callback will be called with the following arguments:
#
# * if type String Array, list of arguments collected so far
# * else the Boolean or String argument collected
# * a `--` separator.
# * the rest of arguments not parsed yet
#
# @option --alt <optionName> (mandatory at least one) option name possibility, the string allowing to discriminate the option.
# @option --variable-name | --var <varName> (mandatory) provides the variable name that will be used to store the parsed options.
# @option --variable-type <Boolean|String|StringArray> (optional) option type (default: Boolean)
# @option --mandatory (optional) as its name indicates, by default an option is optional. But using `--mandatory` you can make the option mandatory. An error will be generated if the option is not found during parsing arguments.
# @option --help <help> (optional) provides option help description (Default: Empty string)
# @option --group <Function> (optional) the group to which the option will be attached. Grouped option will be displayed under that group. (Default: no group)
# @option --callback <Function> (0 or several times) the callback called if the option is parsed successfully. The option value will be passed as parameter (several parameters if type StringArray).
# @option --function-name <String> (optional) the name of the function that will be generated
# @option --* (optional) Others options are passed to specific option handler depending on variable type
# @exitcode 1 if error during option parsing
# @exitcode 2 if error during option type parsing
# @exitcode 3 if error during template rendering
# @stderr diagnostics information is displayed
# @see [generateCommand function](#/doc/guides/Options/generateCommand)
# @see [option function](#/doc/guides/Options/functionOption)
Options::generateOption() {
  # args default values
  local variableName=""
  local functionName=""
  local -a alts=()
  local variableType="Boolean"
  local variableTypeOptionProvided=0
  local help=""
  local mandatory=0
  local group=""
  local -a callbacks=()
  local -a adapterOptions=()

  while (($# > 0)); do
    local arg="$1"
    case "${arg}" in
      --alt)
        shift
        if (($# == 0)); then
          Log::displayError "Options::generateOption - Option ${arg} - a value needs to be specified"
          return 1
        fi
        if ! Options::assertAlt "$1"; then
          Log::displayError "Options::generateOption - invalid alt option value '$1'"
          return 1
        fi
        alts+=("$1")
        ;;
      --var | --variable-name)
        shift
        if (($# == 0)); then
          Log::displayError "Options::generateOption - Option ${arg} - a value needs to be specified"
          return 1
        fi
        if [[ -n "${variableName}" ]]; then
          Log::displayError "Options::generateOption - only one --var option can be provided"
          return 1
        fi
        if ! Assert::validVariableName "$1"; then
          Log::displayError "Options::generateOption - invalid variable name $1"
          return 1
        fi
        variableName="$1"
        ;;
      --variable-type)
        shift
        if (($# == 0)); then
          Log::displayError "Options::generateOption - Option ${arg} - a value needs to be specified"
          return 1
        fi
        if [[ "${variableTypeOptionProvided}" != "0" ]]; then
          Log::displayError "Options::generateOption - only one '--variable-type' option can be provided"
          return 1
        fi
        variableTypeOptionProvided=1
        local -a validVariableTypes=("Boolean" "String" "StringArray")
        if ! Array::contains "$1" "${validVariableTypes[@]}"; then
          Log::displayError "Options::generateOption - variable type '$1' invalid, should be one of ${validVariableTypes[*]}"
          return 1
        fi
        variableType="$1"
        ;;
      --mandatory)
        mandatory=1
        adapterOptions+=("$1")
        ;;
      --help)
        shift
        if (($# == 0)); then
          Log::displayError "Options::generateOption - Option ${arg} - a value needs to be specified"
          return 1
        fi
        if [[ -n "${help}" ]]; then
          Log::displayError "Options::generateOption - only one --help option can be provided"
          return 1
        fi
        help="$1"
        ;;
      --group)
        shift
        if (($# == 0)); then
          Log::displayError "Options::generateOption - Option ${arg} - a value needs to be specified"
          return 1
        fi
        if
          ! Assert::posixFunctionName "$1" &&
            ! Assert::bashFrameworkFunction "$1"
        then
          Log::displayError "Options::generateOption - Option ${arg} - only posix or bash framework function name are accepted - invalid '$1'"
          return 1
        fi
        group="$1"
        ;;
      --callback)
        shift
        if (($# == 0)); then
          Log::displayError "Options::generateOption - Option ${arg} - a value needs to be specified"
          return 1
        fi
        if
          ! Assert::posixFunctionName "$1" &&
            ! Assert::bashFrameworkFunction "$1"
        then
          Log::displayError "Options::generateOption - Option ${arg} - only posix or bash framework function name are accepted - invalid '$1'"
          return 1
        fi
        callbacks+=("$1")
        ;;
      --function-name)
        shift
        if (($# == 0)); then
          Log::displayError "Options::generateOption - Option ${arg} - a value needs to be specified"
          return 1
        fi
        if ! Assert::posixFunctionName "$1"; then
          Log::displayError "Options::generateOption - Option ${arg} - only posix name is accepted - invalid '$1'"
          return 1
        fi
        functionName="$1"
        ;;
      *)
        adapterOptions+=("$1")
        ;;
    esac
    shift || true
  done
  if [[ -z "${variableName}" ]]; then
    Log::displayError "Options::generateOption - --variable-name option is mandatory"
    return 1
  fi
  if (("${#alts[@]}" == 0)); then
    Log::displayError "Options::generateOption - you must provide at least one --alt option"
    return 1
  fi

  (
    # generate specific type options values
    local adapterOptionsTmpFile
    adapterOptionsTmpFile="$(Framework::createTempFile "optionTypeExports")"
    case "${variableType}" in
      Boolean)
        Options::generateOptionBoolean "${adapterOptions[@]}" >"${adapterOptionsTmpFile}" || return 2
        ;;
      String)
        Options::generateOptionCommonStringOrStringArray "Options::generateOptionString" \
          "${adapterOptions[@]}" >"${adapterOptionsTmpFile}" || return 2
        Options::generateOptionString \
          "${adapterOptions[@]}" >>"${adapterOptionsTmpFile}" || return 2
        ;;
      StringArray)
        Options::generateOptionCommonStringOrStringArray "Options::generateOptionStringArray" \
          "${adapterOptions[@]}" >"${adapterOptionsTmpFile}" || return 2
        Options::generateOptionStringArray "${adapterOptions[@]}" >>"${adapterOptionsTmpFile}" || return 2
        ;;
      *)
        Log::displayError "invalid option --variable-type: ${variableType}"
        return 1
        ;;
    esac
    local optionTypeExports
    optionTypeExports="$(cat "${adapterOptionsTmpFile}")"

    # export current values
    export type="Option"
    export variableName
    export variableType
    export alts
    export help
    export group
    export callbacks
    export mandatory
    export adapterOptions
    eval "${optionTypeExports}"
    export functionName
    export tplDir="${_COMPILE_ROOT_DIR}/src/Options/templates"

    Options::generateFunction "${functionName}" "option" || return 3
  ) || return $?
}
