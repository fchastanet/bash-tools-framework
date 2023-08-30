#!/usr/bin/env bash

# @description generate argument parse code
# @example
#   Options::generateArg \
#     --variable-name "fileToCompile" \
#     --name "fileToCompile"
#     --help "provides the directory where to find the functions source code."
#
# @arg $@ args:StringArray
# @option --variable-name|--var <varName> (mandatory) provides the variable name that will be used to store the parsed arguments.
# @option --help <help> (optional) provides argument help description (Default: Empty string)
# @option --name (optional) provides the argument name that will be used to display the help. Default: variable name
# @option --min <int> Indicates the minimum number of args that will be parsed. (Default: 1)
# @option --max <int> Indicates the maximum number of args that will be parsed. (Default: 1)
# @option --authorized-values  <String> list of authorized values separated by |
# @option --regexp <String> regexp to use to validate the option value
# @option --callback <Function> the callback called if the arg is parsed successfully
# @exitcode 1 if error during argument parsing
# @exitcode 2 if error during template rendering
# @stdout script file generated to parse the arguments following the rules provided
# @stderr diagnostics information is displayed
# @see Options::generateCommand
# @see doc/guides/Options/generateArg.md
Options::generateArg() {
  # args default values
  local variableName=""
  # shellcheck disable=SC2034
  local -i variableNameCount=0

  local help=""
  # shellcheck disable=SC2034
  local -i helpCount=0

  local name=""
  # shellcheck disable=SC2034
  local -i nameCount=0

  local -i min=1
  # shellcheck disable=SC2034
  local -i minCount=0

  local -i max=1
  # shellcheck disable=SC2034
  local -i maxCount=0

  local authorizedValues=""
  # shellcheck disable=SC2034
  local -i authorizedValuesCount=0

  local regexp=""
  # shellcheck disable=SC2034
  local -i regexpCount=0

  local type="Argument"
  local variableType="StringArray"

  local callback=""
  # shellcheck disable=SC2034
  local -i callbackCount=0

  checkOption() {
    local option="$1"
    local -n argCount="$2"
    local argCountAfterShift="$3"

    ((++argCount))
    if ((argCountAfterShift == 0)); then
      Log::displayError "Options::generateArg - Option ${option} - a value needs to be specified"
      return 1
    fi
    if ((argCount > 1)); then
      Log::displayError "Options::generateArg - Option ${option} - can be provided once"
      return 1
    fi
  }

  while (($# > 0)); do
    local option="$1"
    case "${option}" in
      --var | --variable-name)
        shift
        checkOption "${option}" variableNameCount "$#" || return 1
        if ! Assert::validVariableName "$1"; then
          Log::displayError "Options::generateArg - invalid variable name $1"
          return 1
        fi
        variableName="$1"
        ;;
      --help)
        shift
        checkOption "${option}" helpCount "$#" || return 1
        help="$1"
        ;;
      --name)
        shift
        checkOption "${option}" nameCount "$#" "$1" || return 1
        name="$1"
        ;;
      --min)
        shift
        checkOption "${option}" minCount "$#" || return 1
        if [[ ! "$1" =~ ^[0-9]+$ ]]; then
          Log::displayError "Options::generateArg - Option ${option} - should be an int >= 0"
          return 1
        fi
        min=$1
        ;;
      --max)
        shift
        checkOption "${option}" maxCount "$#" || return 1
        if [[ ! "$1" =~ ^([0-9]+|-1)$ ]]; then
          Log::displayError "Options::generateArg - Option ${option} - should be an int >=0 or -1(infinite)"
          return 1
        fi
        max=$1
        ;;
      --authorized-values)
        shift
        checkOption "${option}" authorizedValuesCount "$#" || return 1
        # TODO check if valid regexp
        if [[ "$1" =~ [[:space:]] ]]; then
          Log::displayError "Options::generateArg - Option ${option} - invalid regexp '$1'"
          return 1
        fi
        authorizedValues="$1"
        ;;
      --regexp)
        shift
        checkOption "${option}" regexpCount "$#" || return 1
        # TODO check if valid regexp
        if [[ "$1" =~ [[:space:]] ]]; then
          Log::displayError "Options::generateArg - Option ${option} - invalid regexp '$1'"
          return 1
        fi
        regexp="$1"
        ;;
      --callback)
        shift
        checkOption "${option}" callbackCount "$#" || return 1
        if (($# == 0)); then
          Log::displayError "Options::generateArg - Option ${option} - a value needs to be specified"
          return 1
        fi
        if [[ "$(type -t "$1")" != "function" ]]; then
          Log::displayError "Options::generateArg - only function type are accepted as callback - invalid '$1'"
          return 1
        fi
        callback="$1"
        ;;
      *)
        Log::displayError "Options::generateArg - Option ${option} - invalid option provided"
        return 1
        ;;
    esac
    shift || true
  done
  if [[ -z "${variableName}" ]]; then
    Log::displayError "Options::generateArg - Option --variable-name is mandatory"
    return 1
  fi
  if [[ -z "${name}" ]]; then
    name="${variableName}"
  fi
  if ((max != -1 && min > max)); then
    Log::displayError "Options::generateArg - Option --min cannot be greater than --max option"
    return 1
  fi
  if ((max == 1 && min <= 1)); then
    variableType="String"
  fi

  (
    # generate a function name that will be the output of this script
    local baseArgFunctionName
    baseArgFunctionName=$(Options::generateFunctionName "arg${variableName^}" "") || return 3
    local argFunctionName="Options::${baseArgFunctionName}"

    # export current values
    export type
    export variableType
    export variableName
    export help
    export name
    export min
    export max
    export authorizedValues
    export regexp
    export argFunctionName
    export callback
    export tplDir="${_COMPILE_ROOT_DIR}/src/Options/templates"

    # interpret the template
    local argFunctionTmpFile
    argFunctionTmpFile="${TMPDIR}/src/Options/${baseArgFunctionName}.sh"
    mkdir -p "$(dirname "${argFunctionTmpFile}")" || return 3
    Options::bashTpl "${_COMPILE_ROOT_DIR}/src/Options/templates/arg.tpl" >"${argFunctionTmpFile}" || return 3
    Log::displayDebug "Generated function for arg ${variableName} in ${argFunctionTmpFile}"

    # display the functionOption
    echo "${argFunctionName}"
  ) || return $?
}
