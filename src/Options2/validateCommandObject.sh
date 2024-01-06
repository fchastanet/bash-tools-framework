#!/usr/bin/env bash

# @description Validates command properties created 
# using `Object::create`
#
# #### Example
#
# ```bash
# declare Object::create \
#   --function-name "commandFunction" \
#   --type "Option" \
#   --property-variableName "varName"
#
# Options2::validateCommandObject "${commandFunction}"
# ```
# #### Arg Structure
#
# - --function-name <String> (optional) the name of the function that will be generated
# - --type "Command"
# - --property-name <String> (optional) provides the name of the command (Default: name of current command file without path)
# - --property-shortDescription <String> (optional) provides command short description (Default: Empty string)
# - --property-longDescription <String> (optional) provides command long description (Default: Empty string)
# - --property-version <String> (optional) provides version section help. Section not generated if not provided. (Default: Empty string)
# - --property-author <String> (optional) provides author section help. Section not generated if not provided.
# - --property-license <String> (optional) provides License section. Section not generated if not provided.
# - --property-sourceFile <String> (optional) provides Source file section. Section not generated if not provided.
# - --property-copyright <String> (optional) provides copyright section. Section not generated if not provided.
#
# - --array-unknownOptionCallback <Function> (0 or more) the callback called when an option is unknown (Default: options parser display error message if option provided does not match any specified options).
# - --array-unknownArgumentCallback <Function> (0 or more) the callback called when an argument is unknown (Default: parser does not report any error).
# - --array-everyOptionCallback <Function> (0 or more) the callback called for every option.
# - --array-everyArgumentCallback <Function> (0 or more) the callback called for every argument.
# - --array-callback <Function> (0 or more) the callback called when all options and arguments have been parsed.
#
# - --array-element <Function> (1 or more) list of option/arguments objects
#
# Example:
# ```bash
# Object::create \
#   --function-name command" \
#   --type "Command" \
#   --array-callback "callback"
# Options2::validateCommandObject
#
# @exitcode 1 if mandatory parameter missing
# @exitcode 2 if invalid parameter provided
# @stderr diagnostics information is displayed
Options2::validateCommandObject() {
  if (( $# != 1 )); then
    Log::displayError "Options2::validateCommandObject - exactly one parameter has to be provided"
    return 1
  fi
  
  # shellcheck disable=SC2034
  local -n cmdInstanceObject=$1
  if [[ "$(Object::getProperty cmdInstanceObject --type)" != "Command" ]]; then
    Log::displayError "Options2::validateCommandObject - passed object is not a command"
    return 2
  fi

  # name
  local name
  if Object::memberExists cmdInstanceObject --property-name; then
    name="$(Object::getProperty cmdInstanceObject --property-name)"
    if ! Assert::validVariableName "${name}"; then
      Log::displayError "Options2::validateCommandObject - invalid command name ${name}"
      return 2
    fi
  fi

  # callback
  checkCallbacks() {
    local callbackType="$1"
    if Object::memberExists cmdInstanceObject "${callbackType}"; then
      local callbacks
      callbacks="$(Object::getArray cmdInstanceObject "${callbackType}")"
      local callback
      while IFS= read -r callback ; do 
        if [[ $(type -t "${callback}") != "function" ]]; then
          Log::displayError "Options2::validateCommandObject - only function can be passed as callback - invalid '${callback}'"
          return 2
        fi
      done <<< "${callbacks}"
    fi
  }
  checkCallbacks --array-unknownOptionCallback || return 2
  checkCallbacks --array-unknownArgumentCallback || return 2
  checkCallbacks --array-everyOptionCallback || return 2
  checkCallbacks --array-everyArgumentCallback || return 2
  checkCallbacks --array-callback || return 2

  # option/argument list
  if ! Object::memberExists cmdInstanceObject --array-element; then
    Log::displayError "Options2::validateCommandObject - at least one option or argument must be provided"
    return 1
  fi
  local -a argumentList=()
  local elements
  elements="$(Object::getArray cmdInstanceObject --array-element)" 
  local element
  while IFS= read -r element ; do 
    # check element type is Option or Arg
    if [[ ! "$(declare -p "${element}")" =~ declare\ -a ]]; then
      Log::displayError "Options2::validateCommandObject - only object can be passed as element - invalid '${element}'"
      return 2
    fi
    local elementType
    elementType="$(Object::getProperty element --type)"
    if Array::contains "${elementType}" "Option" "Arg"; then
      Log::displayError "Options2::validateOptionObject - Element ${elementType} is not a valid object type"
      return 2
    fi

    # check variable name is not used by another option/argument
    local variableName
    variableName="$(Object::getProperty element --property-variableName "strict")" || {
      Log::displayError "Options2::validateOptionObject - ${elementType} ${element} - command variableName failed"
      return 1
    }
    if Array::contains "${variableName}" "${variableNameList[@]}"; then
      Log::displayError "Options2::validateOptionObject - ${elementType} ${element} - variable name ${variableName} is already used by a previous option/argument"
      return 2
    fi
    variableNameList+=("${variableName}")

    # check alts not duplicated
    if [[ "${elementType}" = "Option" ]]; then
      local optionAlts
      optionAlts="$(Object::getArray element --array-alt)" || {
        Log::displayError "Options2::validateOptionObject - Option ${element} - command alt failed"
        return 1
      }
      local optionAlt
      while IFS= read -r optionAlt ; do 
        if Array::contains "${optionAlt}" "${altList[@]}"; then
          Log::displayError "Options2::validateOptionObject - Option ${element} - alt ${optionAlt} is already used by a previous Option"
          return 1
        fi
        altList+=("${optionAlt}")
      done <<< "${optionAlts}"
    elif [[ "${elementType}" = "Arg" ]]; then
      argumentList+=("${element}")
    fi
  done <<< "${elements}"

  # check min/max coherence
  
  # check arguments coherence
  local currentArg currentArgMin currentArgMax
  local optionalArg=""
  for currentArg in "${argumentList[@]}"; do
    currentArgMin="$(Object::getProperty currentArg --property-min "strict")" || {
      Log::displayError "Options2::validateOptionObject - Argument ${currentArg} - command min failed"
      return 1
    }
    if [[ ! "${currentArgMin}" =~ ^[0-9]+$ ]]; then
      Log::displayError "Options::generateArg - Option --property-min - should be an int >= 0"
      return 1
    fi
    currentArgMax="$(Object::getProperty currentArg --property-max "strict")" || {
      Log::displayError "Options2::validateOptionObject - Argument ${currentArg} - command max failed"
      return 1
    }
    if [[ ! "${currentArgMax}" =~ ^([0-9]+|-1)$ ]]; then
      Log::displayError "Options::generateArg - Option --property-max - should be an int >=0 or -1(infinite)"
      return 1
    fi
    if ((currentArgMin != currentArgMax)); then
      optionalArg="$("${currentArg}" variableName)"
    elif [[ -n "${optionalArg}" ]]; then
      Log::displayError "Options2::validateOptionObject - variable list argument $("${currentArg}" variableName) after an other variable list argument ${optionalArg}, it would not be possible to discriminate them"
      return 1
    fi
  done
}
