#!/usr/bin/env bash

# @description Generates a function that allows to manipulate a command
# constituted with options, group and arguments.
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
# Usage:  Options::generateCommand [OPTIONS]
# [optionsVariablesReferences] [argVariablesReferences]
#
# USAGE: Options::generateCommand [OPTIONS] [ARGS]
#
# OPTIONS:
#   [--help|--short-description <String|Function>]
#   [--long-description <String|Function>]
#   [--command-name <String|Function>]
#   [--version <String|Function>]
#   [--author <String|Function>]
#   [--License <String|Function>]
#   [--copyright <String|Function>]
#   [--help-template <String>]
#   [--unknown-option-callback]
#   [--unknown-arg-callback]
#
# ARGS: list of option/arg functions
# ```
#
# #### Example
#
# ```bash
# declare commandForm="$(Options::generateCommand \
#   --help "Command help" \
#   --version "version 1.0" \
#   --author "author is me" \
#   --command-name "myCommand" \
#   --license "MIT License" \
#   --copyright "Copyright" \
#   --help-template "path/to/template.tpl"
# )"
# Options::sourceFunction "${commandForm}"
# "${commandForm}" parse "$@"
# ```
#
# #### --callback option
# you can set several callbacks
# callback is called without any parameter.
#
# #### --unknown-option-callback/--unknown-arg-callback option
# You can set several callbacks.
# Callback is called with the option/argument that is invalid.
# An invalid option is a string that begin with `-`
# and that does not match any option configured.
# An invalid argument is an argument that does not
# match any configured argument.
#
# @arg $@ args:StringArray (mandatory, at least one) list of options/arguments functions, allowing to link the options/arguments with this command
# @option --help | --summary | --short-description <String|Function> (optional) provides command short description help
# @option --long-description <String|Function> (optional) provides command long description help
# @option --command-name <String|Function> (optional) provides the command name. (Default: name of current command file without path)
# @option --version <String|Function> (optional) provides version section help. Section not generated if not provided.
# @option --author <String|Function> (optional) provides author section help. Section not generated if not provided.
# @option --license <String|Function> (optional) provides License section. Section not generated if not provided.
# @option --source-file <String|Function> (optional) provides Source file section. Section not generated if not provided.
# @option --copyright <String|Function> (optional) provides copyright section. Section not generated if not provided.
# @option --help-template <String|Function> (optional) if you want to override the default template used to generate the help
# @option --function-name <String> the name of the function that will be generated
# @option --unknown-option-callback <Function> (0 or more) the callback called when an option is unknown (Default: options parser display error message if option provided does not match any specified options).
# @option --unknown-argument-callback <Function> (0 or more) the callback called when an argument is unknown (Default: parser does not report any error).
# @option --callback <Function> (0 or more) the callback called when all options and arguments have been parsed.
# @warning arguments function list has to be provided in correct order
# @warning argument/option variable names have to be unique. Best practice is to scope the variable name to avoid variable name conflicts.
# @exitcode 1 if error during option/argument parsing
# @exitcode 2 if error during option/argument type parsing
# @exitcode 3 if error during template rendering
# @stderr diagnostics information is displayed
# @see [generateOption function](#/doc/guides/Options/generateOption)
# @see [generateArg function](#/doc/guides/Options/generateArg)
# @see [generateGroup function](#/doc/guides/Options/generateGroup)
# @see [command function](#/doc/guides/Options/functionCommand)
Options::generateCommand() {
  # args default values
  local help=""
  local longDescription=""
  local version=""
  local author=""
  local commandName=""
  local license=""
  local sourceFile=""
  local copyright=""
  local helpTemplate=""
  local functionName=""
  local -a unknownOptionCallbacks=()
  local -a unknownArgumentCallbacks=()
  local -a commandCallbacks=()
  local -a optionListUnordered=()
  local -a argumentList=()
  local -a variableNameList=()
  local -a altList=()

  setArg() {
    local option="$1"
    local -n argToSet="$2"
    local argCountAfterShift="$3"
    local value="$4"

    if ((argCountAfterShift == 0)); then
      Log::displayError "Options::generateCommand - Option ${option} - a value needs to be specified"
      return 1
    fi
    if [[ -n "${argToSet}" ]]; then
      Log::displayError "Options::generateCommand - only one ${option} option can be provided"
      return 1
    fi
    argToSet="${value}"
  }

  while (($# > 0)); do
    local option="$1"
    case "${option}" in
      --help | --summary | --short-description)
        shift
        setArg "${option}" help "$#" "$1" || return 1
        ;;
      --long-description)
        shift
        setArg "${option}" longDescription "$#" "$1" || return 1
        ;;
      --version)
        shift
        setArg "${option}" version "$#" "$1" || return 1
        ;;
      --author)
        shift
        setArg "${option}" author "$#" "$1" || return 1
        ;;
      --command-name)
        shift
        setArg "${option}" commandName "$#" "$1" || return 1
        ;;
      --license)
        shift
        setArg "${option}" license "$#" "$1" || return 1
        ;;
      --source-file)
        shift
        setArg "${option}" sourceFile "$#" "$1" || return 1
        ;;
      --copyright)
        shift
        setArg "${option}" copyright "$#" "$1" || return 1
        ;;
      --help-template)
        shift
        setArg "${option}" helpTemplate "$#" "$1" || return 1
        # TODO check if valid template file
        ;;
      --callback | --unknown-option-callback | --unknown-argument-callback)
        shift
        if (($# == 0)); then
          Log::displayError "Options::generateCommand - Option ${option} - a value needs to be specified"
          return 1
        fi
        if
          ! Assert::posixFunctionName "$1" &&
            ! Assert::bashFrameworkFunction "$1"
        then
          Log::displayError "Options::generateCommand - Option ${option} - only posix or bash framework function name are accepted - invalid '$1'"
          return 1
        fi
        case "${option}" in
          --callback) commandCallbacks+=("$1") ;;
          --unknown-option-callback) unknownOptionCallbacks+=("$1") ;;
          --unknown-argument-callback) unknownArgumentCallbacks+=("$1") ;;
          *) ;;
        esac
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
        if [[ "${option}" =~ ^-- ]]; then
          Log::displayError "Options::generateCommand - invalid option provided '$1'"
          return 1
        fi
        if [[ "$(type -t "$1")" != "function" ]]; then
          Log::displayError "Options::generateCommand - only function type are accepted as positional argument - invalid '$1'"
          return 1
        fi

        # check option/argument type
        local optionType
        optionType="$("${option}" type)" || {
          Log::displayError "Options::generateCommand - option/argument ${option} - command type failed"
          return 1
        }
        if ! Array::contains "${optionType}" "Option" "Argument"; then
          Log::displayError "Options::generateCommand - option/argument ${option} - type '${optionType}' invalid"
          return 1
        fi
        if [[ "${optionType}" = "Option" ]]; then
          optionListUnordered+=("${option}")
        else
          argumentList+=("${option}")
        fi

        # check variable name is not used by another option/argument
        local variableName
        variableName="$("${option}" variableName)" || {
          Log::displayError "Options::generateCommand - ${optionType} ${option} - command variableName failed"
          return 1
        }
        if Array::contains "${variableName}" variableNameList; then
          Log::displayError "Options::generateCommand - ${optionType} ${option} - variable name ${variableName} is already used by a previous option/argument"
          return 1
        fi
        variableNameList+=("${variableName}")

        # check alts not duplicated
        if [[ "${optionType}" = "Option" ]]; then
          local -a optionAlts
          optionAlts=("$("${option}" alts)") || {
            Log::displayError "Options::generateCommand - Option ${option} - command alts failed"
            return 1
          }
          local optionAlt
          for optionAlt in "${optionAlts[@]}"; do
            if Array::contains "${optionAlt}" "${altList[@]}"; then
              Log::displayError "Options::generateCommand - Option ${option} - alt ${optionAlt} is already used by a previous Option"
              return 1
            fi
            altList+=("${optionAlt}")
          done
        fi
        ;;
    esac
    shift || true
  done
  if [[ -z "${helpTemplate}" ]]; then
    helpTemplate="${_COMPILE_ROOT_DIR}/src/Options/templates/commandHelp.tpl"
  fi
  if ((${#optionListUnordered} == 0 && ${#argumentList} == 0)); then
    Log::displayError "Options::generateCommand - at least one option or argument must be provided as positional argument"
    return 1
  fi
  if [[ -z "${commandName}" ]]; then
    # shellcheck disable=SC2016
    commandName='${SCRIPT_NAME}'
  fi

  # check arguments coherence
  local currentArg currentArgMin currentArgMax
  local optionalArg=""
  for currentArg in "${argumentList[@]}"; do
    currentArgMin="$("${currentArg}" min)" || {
      Log::displayError "Options::generateCommand - Argument ${currentArg} - command min failed"
      return 1
    }
    currentArgMax="$("${currentArg}" max)" || {
      Log::displayError "Options::generateCommand - Argument ${currentArg} - command max failed"
      return 1
    }
    if ((currentArgMin != currentArgMax)); then
      optionalArg="$("${currentArg}" variableName)"
    elif [[ -n "${optionalArg}" ]]; then
      Log::displayError "Options::generateCommand - variable list argument $("${currentArg}" variableName) after an other variable list argument ${optionalArg}, it would not be possible to discriminate them"
      return 1
    fi
  done

  # sort options
  local -a optionList
  local optionListToSort
  optionListToSort="$(
    (
      local -i i
      local currentOpt
      for ((i = 0; i < ${#optionListUnordered[@]}; ++i)); do
        currentOpt="${optionListUnordered[i]}"
        echo "${currentOpt} ${i} $("${currentOpt}" groupId)"
      done
    ) | sort -k3,3 -k2,2 | awk '{ print $1 }'
  )"
  optionList=()
  if [[ -n "${optionListToSort}" ]]; then
    readarray -t optionList <<<"${optionListToSort}"
  fi

  (
    # export current values
    export help
    export longDescription
    export version
    export author
    export commandName
    export license
    export copyright
    export helpTemplate
    export optionList
    export argumentList
    export functionName
    export sourceFile
    export commandCallbacks
    export unknownOptionCallbacks
    export unknownArgumentCallbacks

    Options::generateFunction "${functionName}" "command" || return 3
  ) || return $?
}
