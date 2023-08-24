#!/usr/bin/env bash

# @description generate option parse code
# @example
#   Options::generateOption \
#     --variable-name "srcDirs" \
#     --alt "-s" \
#     --alt "--src-dir" \
#     --type "StringArray" \
#     --required \
#     --help "provides the directory where to find the functions source code."
#
# @arg $@ args:StringArray
# @option --variable-name|--var <varName> (mandatory) provides the variable name that will be used to store the parsed options.
# @option --alt <option> (mandatory 1 time) option possibility
# @option --type <Boolean|String|StringArray> option type (default: Boolean)
# @option --mandatory (optional) indicates if option is mandatory (optional if not provided)
# @option --help <help> (optional)
# @option --command <commandVariableName> (optional) reference to the command
# Others options are passed to specific option handler:
# @option --authorized-values  <String> if String type, list of authorized values separated by |
# @option --regexp <String> if String type, regexp to use to validate the option value
# @exitcode 1 if error during option parsing
# @exitcode 2 if error during option type parsing
# @exitcode 3 if error during template rendering
# @stdout script file generated to parse the arguments following the rules provided
# @stderr diagnostics information is displayed
# @see Options::generateCommand
Options::generateOption() {
  # args default values
  local variableName=""
  local -a alts=()
  local type="Boolean"
  local typeOptionProvided=0
  local help=""
  local mandatory=0
  local commandVariableName=""
  local -a adapterOptions=()

  while (($# > 0)); do
    case "$1" in
      --var | --variable-name)
        shift || true
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
        shift || true
        if ! Options::assertAlt "$1"; then
          Log::displayError "Options::generateOption - invalid alt option value '$1'"
          return 1
        fi
        alts+=("$1")
        ;;
      --type)
        shift || true
        if [[ "${typeOptionProvided}" != "0" ]]; then
          Log::displayError "Options::generateOption - only one '--type' option can be provided"
          return 1
        fi
        typeOptionProvided=1
        local -a validTypes=("Boolean" "String" "StringArray")
        if ! Array::contains "$1" "${validTypes[@]}"; then
          Log::displayError "Options::generateOption - type '$1' invalid, should be one of ${validTypes[*]}"
          return 1
        fi
        type="$1"
        ;;
      --help)
        shift || true
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
      --command)
        shift || true
        if [[ -n "${commandVariableName}" ]]; then
          Log::displayError "Options::generateOption - only one '--command' option can be provided"
          return 1
        fi
        Assert::validVariableName "$1" || {
          Log::displayError "Options::generateOption - command parameter value '$1' should target a valid variable name"
          return 1
        }
        commandVariableName="$1"
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
    case "${type}" in
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
        Log::displayError "invalid option type: ${type}"
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
    export variableName
    export alts
    export type
    export help
    export mandatory
    export commandVariableName=
    export adapterOptions
    eval "${optionTypeExports}"
    export optionFunctionName

    # interpret the template
    local optionFunctionTmpFile
    optionFunctionTmpFile="${TMPDIR}/src/Options/${baseOptionFunctionName}"
    mkdir -p "$(dirname "${optionFunctionTmpFile}")" || return 3
    Options::bashTpl "${_COMPILE_ROOT_DIR}/src/Options/templates/parseOption.tpl" >"${optionFunctionTmpFile}" || return 3
    Log::displayDebug "Generated function for option ${variableName} in ${optionFunctionTmpFile}"

    # display the functionOption
    echo "${optionFunctionName}"
  ) || return $?
}

# # shellcheck source=src/Options/generateFunctionName.sh
# source "src/Options/generateFunctionName.sh"
# # shellcheck source=/src/Assert/validVariableName.sh
# source "src/Assert/validVariableName.sh"
# # shellcheck source=/src/Array/contains.sh
# source "src/Array/contains.sh"
# # shellcheck source=/src/Framework/createTempFile.sh
# source "src/Framework/createTempFile.sh"

# set -x
# set -o errexit
# set -o pipefail
# export TMPDIR="/tmp"
# export _COMPILE_ROOT_DIR="$(pwd)"
# echo "$@"
# Options::generateOption "$@"
