#!/usr/bin/env bash

# @description generate option parse code
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
  local -a alts=()
  local variableType="Boolean"
  local variableTypeOptionProvided=0
  local help=""
  local mandatory=0
  local group=""
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
        if [[ "$(type -t "$1")" != "function" ]]; then
          Log::displayError "Options::generateOption - only function type are accepted as group - invalid '$1'"
          return 1
        fi
        group="$1"
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

    # generate a function name that will be the output of this script
    local baseOptionFunctionName
    baseOptionFunctionName=$(Options::generateFunctionName "option${variableName^}" "") || return 3
    local optionFunctionName="Options::${baseOptionFunctionName}"

    # export current values
    export type="Option"
    export variableName
    export variableType
    export alts
    export help
    export group
    export mandatory
    export adapterOptions
    eval "${optionTypeExports}"
    export optionFunctionName
    export tplDir="${_COMPILE_ROOT_DIR}/src/Options/templates"

    # interpret the template
    local optionFunctionTmpFile
    optionFunctionTmpFile="${TMPDIR}/src/Options/${baseOptionFunctionName}.sh"
    mkdir -p "$(dirname "${optionFunctionTmpFile}")" || return 3
    Options::bashTpl "${_COMPILE_ROOT_DIR}/src/Options/templates/option.tpl" >"${optionFunctionTmpFile}" || return 3
    Log::displayDebug "Generated function for option ${variableName} in ${optionFunctionTmpFile}"

    # display the functionOption
    echo "${optionFunctionName}"
  ) || return $?
}
