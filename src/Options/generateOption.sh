#!/usr/bin/env bash

# @description generate option parse code
# By default the name of the random generated function name
# is displayed as output of this function.
# By providing the option --function-name, the output of this
# function will be the generated function itself with the chosen name.
# @example
#   Options::generateOption \
#     --variable-name "srcDirs" \
#     --alt "-s" \
#     --alt "--src-dir" \
#     --variable-type "StringArray" \
#     --required \
#     --help "provides the directory where to find the functions source code."
#
# @arg $@ args:StringArray
# @option --variable-name|--var <varName> (mandatory) provides the variable name that will be used to store the parsed options.
# @option --alt <option> (mandatory 1 time) option possibility
# @option --variable-type <Boolean|String|StringArray> option type (default: Boolean)
# @option --mandatory (optional) indicates if option is mandatory (optional if not provided)
# @option --help <help> (optional)
# Others options are passed to specific option handler:
# @option --authorized-values  <String> if String type, list of authorized values separated by |
# @option --regexp <String> if String type, regexp to use to validate the option value
# @option --group <Function> the group to which the option will be attached
# @option --callback <Function> the callback called if the option is parsed successfully
# @option --function-name <String> the name of the function that will be generated
# @exitcode 1 if error during option parsing
# @exitcode 2 if error during option type parsing
# @exitcode 3 if error during template rendering
# @stdout script file generated to parse the options following the rules provided
# @stderr diagnostics information is displayed
# @see Options::generateCommand
# @see doc/guides/Options/generateOption.md
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
  local callback=""
  local -a adapterOptions=()

  while (($# > 0)); do
    local arg="$1"
    case "${arg}" in
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
      --mandatory)
        mandatory=1
        adapterOptions+=("$1")
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
        callback="$1"
        ;;
      --function-name)
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
        functionName="$1"
        ;;
      *)
        adapterOptions+=("$1")
        ;;
    esac
    shift || true
  done
  if [[ -z "${callback}" && -z "${variableName}" ]]; then
    Log::displayError "Options::generateOption - --variable-name option is mandatory if no callback provided"
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
        Options::generateOptionString "${adapterOptions[@]}" >"${adapterOptionsTmpFile}" || return 2
        ;;
      StringArray)
        Options::generateOptionStringArray "${adapterOptions[@]}" >"${adapterOptionsTmpFile}" || return 2
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
    export callback
    export mandatory
    export adapterOptions
    eval "${optionTypeExports}"
    export functionName
    export tplDir="${_COMPILE_ROOT_DIR}/src/Options/templates"

    Options::generateFunction "${functionName}" "option" || return 3
  ) || return $?
}
