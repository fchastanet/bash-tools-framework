#!/usr/bin/env bash

# @description Validates options properties created 
# using `Object::create`
#
# #### Example
#
# ```bash
# declare Object::create \
#   --function-name "optionFunction" \
#   --type "Option" \
#   --property-variableName "varName"
#
# Options2::validateArgObject "${optionFunction}"
# ```
# #### Arg Structure
#
# - --function-name <String> (optional) the name of the function that will be generated
# - --type "Arg"
# - --property-variableType <String|StringArray> automatically computed based on min/max
# - --property-variableName <varName> (mandatory) provides the variable name that will be used to store the parsed options.
# - --property-name <name> (optional) provides the name of the argument (default: variableName)
# - --property-mandatory (optional) as its name indicates, by default an option is optional. But using `--mandatory` you can make the option mandatory. An error will be generated if the option is not found during parsing arguments.
# - --property-help <help> (optional) provides option help description (Default: Empty string)
# - --array-callback <Function> (0 or several times) the callback called if the option is parsed successfully. The option value will be passed as parameter (several parameters if type StringArray).
# - --property-regexp <value> (optional) regexp to use to validate the option value
# - --property-authorizedValues <value> (optional) Indicates the possible value list separated by | character (Default: "" means no check)
# - --property-helpValueName <valueName> (optional) Indicates the name of value of the option to display in help (Default: "String")
# - --property-mandatory <value> (optional) if 1 then will set min value to 1 (except if min is already set) (Default: "0")
# - --property-min <value> (optional) minimum number of options to provide (Defaults to 0 or 1 if mandatory).
# - --property-max <value> (optional) maximum number of options to provide (Default "" means no limit)
#
# Example:
# ```bash
# Object::create \
#   --function-name "optionFunction" \
#   --type "Option" \
#   --property-variableType "Boolean" \
#   --property-variableName "varName" \
#   --array-alt "--help" \
#   --array-alt "-h" \
#   --array-callback "callback"
# ```
#
# @exitcode 1 if mandatory parameter missing
# @exitcode 2 if invalid parameter provided
# @stderr diagnostics information is displayed
Options2::validateArgObject() {
  if (( $# != 1 )); then
    Log::displayError "Options2::validateArgObject - exactly one parameter has to be provided"
    return 1
  fi
  
  # shellcheck disable=SC2034
  local -n validateArgObject=$1
  if [[ "$(Object::getProperty validateArgObject --type)" != "Arg" ]]; then
    Log::displayError "Options2::validateArgObject - passed object is not an argument"
    return 2
  fi

  # variable name
  if ! Object::memberExists validateArgObject --property-variableName; then
    Log::displayError "Options2::validateArgObject - variableName is mandatory"
    return 1
  fi
  local variableName
  variableName="$(Object::getProperty validateArgObject --property-variableName)"
  if ! Assert::validVariableName "${variableName}"; then
    Log::displayError "Options2::validateArgObject - invalid variableName ${variableName}"
    return 2
  fi

  # name
  if ! Object::memberExists validateArgObject --property-name; then
    Log::displayError "Options2::validateArgObject - name is mandatory"
    return 1
  fi
  local name
  name="$(Object::getProperty validateArgObject --property-name)" 
  if ! Assert::validVariableName "${name}"; then
    Log::displayError "Options2::validateArgObject - invalid name ${name}"
    return 2
  fi

  # callback
  if Object::memberExists validateArgObject --array-callback; then
    local callbacks
    callbacks="$(Object::getArray validateArgObject --array-callback)"
    if [[ -n "${callbacks}" ]]; then
      local callback
      while IFS= read -r callback ; do 
        if ! declare -F "${callback}" &>/dev/null; then
          Log::displayError "Options2::validateArgObject - callback '${callback}' - function does not exists"
          return 2
        fi
      done <<< "${callbacks}"
    fi
  fi

  local authorizedValues
  authorizedValues="$(Object::getProperty validateArgObject --property-authorizedValues "strict")" || authorizedValues=""
  if [[ "${authorizedValues}" =~ [[:space:]] ]]; then
    Log::displayError "Options2::validateArgObject - authorizedValues invalid regexp '${authorizedValues}'"
    return 2
  fi

  local regexp
  regexp="$(Object::getProperty validateArgObject --property-regexp)"
  if [[ "${regexp}" =~ [[:space:]] ]]; then
    Log::displayError "Options2::validateArgObject - regexp invalid regexp '${regexp}'"
    return 2
  fi

  local helpValueName
  helpValueName="$(Object::getProperty validateArgObject --property-helpValueName)"
  if [[ -n "${helpValueName}" && ! "${helpValueName}" =~ ^[A-Za-z0-9_-]+$ ]]; then
    Log::displayError "Options2::validateArgObject - helpValueName should be a single word '${helpValueName}'"
    return 2
  fi

  local min
  min="$(Object::getProperty validateArgObject --property-min "strict")" || min="0"
  if [[ ! "${min}" =~ ^[0-9]+$ ]]; then
    Log::displayError "Options2::validateArgObject - min value should be an integer greater than or equal to 0"
    return 2
  fi

  local max
  max="$(Object::getProperty validateArgObject --property-max "strict")" || max="-1"
  if [[ -n "${max}" && ! "${max}" =~ ^([1-9][0-9]*|-1)$ ]]; then
    Log::displayError "Options2::validateArgObject - max value should be an integer greater than 0 or -1"
    return 2
  fi

  if ((max != -1 && min > max)); then
    Log::displayError "Options2::validateArgObject - max value should be greater than min value"
    return 2
  fi
}
