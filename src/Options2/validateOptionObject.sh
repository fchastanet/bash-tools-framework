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
# Options2::validateOptionObject "${optionFunction}"
# ```
# #### Option Common Structure
#
# - --function-name <String> (optional) the name of the function that will be generated
# - --type "Option"
# - --property-variableType <Boolean|String|StringArray> (optional) option type (default: Boolean)
# - --property-variableName | --var <varName> (mandatory) provides the variable name that will be used to store the parsed options.
# - --property-mandatory (optional) as its name indicates, by default an option is optional. But using `--mandatory` you can make the option mandatory. An error will be generated if the option is not found during parsing arguments.
# - --property-help <help> (optional) provides option help description (Default: Empty string)
# - --property-group <Function> (optional) the group to which the option will be attached. Grouped option will be displayed under that group. (Default: no group)
# - --array-alt <optionName> (mandatory at least one) option name possibility, the string allowing to discriminate the option.
# - --array-callback <Function> (0 or several times) the callback called if the option is parsed successfully. The option value will be passed as parameter (several parameters if type StringArray).
# - --* (optional) Others options are passed to specific option handler depending on variable type
#
# #### Option Boolean
#
# Structure:
#
# - --property-offValue <value> (optional) value set by default on the variable (Default: 0)
# - --property-onValue <value> (optional) value set on the variable if option provided (Default: 1)
# 
# #### Option String/StringArray
#
# Common Structure to String/StringArray:
#
# - --property-authorizedValues <value> (optional) Indicates the possible value list separated by | character (Default: "" means no check)
# - --property-helpValueName <valueName> (optional) Indicates the name of value of the option to display in help (Default: "String")
# - --property-mandatory <value> (optional) if 1 then will set min value to 1 (except if min is already set) (Default: "0")
# 
# Structure specific to String only
# 
# - --property-defaultValue <value> (optional) value set by default on the variable (Default: "")
# 
# Structure specific to StringArray only
# 
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
Options2::validateOptionObject() {
  if (( $# != 1 )); then
    Log::displayError "Options2::validateOptionObject - exactly one parameter has to be provided"
    return 1
  fi
  
  # shellcheck disable=SC2034
  local -n validateOptionObject=$1
  if [[ "$(Object::getProperty validateOptionObject --type)" != "Option" ]]; then
    Log::displayError "Options2::validateOptionObject - passed object is not an option"
    return 2
  fi

  # variable name
  if ! Object::memberExists validateOptionObject --property-variableName; then
    Log::displayError "Options2::validateOptionObject - variableName is mandatory"
    return 1
  fi
  local variableName
  variableName="$(Object::getProperty validateOptionObject --property-variableName)"
  if ! Assert::validVariableName "${variableName}"; then
    Log::displayError "Options2::validateOptionObject - invalid variableName ${variableName}"
    return 2
  fi

  # variable type
  if ! Object::memberExists validateOptionObject --property-variableType; then
    Log::displayError "Options2::validateOptionObject - variableType is mandatory"
    return 1
  fi
  local variableType
  variableType="$(Object::getProperty validateOptionObject --property-variableType)"
  if ! Array::contains "${variableType}" "Boolean" "String" "StringArray"; then
    Log::displayError "Options2::validateOptionObject - invalid variableType ${variableType}"
    return 2
  fi

  # group
  local groupObject
  groupObject="$(Object::getProperty validateOptionObject --property-group)"
  if [[ -n "${groupObject}" ]]; then
    if [[ "$(Object::getProperty "${groupObject}" --type)" != "Group" ]]; then
      Log::displayError "Options2::validateOptionObject - Group ${groupObject} is not a valid group object"
      return 2
    fi
  fi

  # alts
  if ! Object::memberExists validateOptionObject --array-alt; then
    Log::displayError "Options2::validateOptionObject - you must provide at least one alt option"
    return 1
  fi
  local alts
  alts="$(Object::getArray validateOptionObject --array-alt)"
  local alt
  while IFS= read -r alt ; do 
    if ! Options::assertAlt "${alt}"; then
      Log::displayError "Options2::validateOptionObject - invalid alt option value '${alt}'"
      return 2
    fi
  done <<< "${alts}"
  
  # callback
  if Object::memberExists validateOptionObject --array-callback; then
    local callbacks
    callbacks="$(Object::getProperty validateOptionObject --array-callback)"
    local callback
    while IFS= read -r callback ; do 
      if ! declare -F "${callback}" &>/dev/null; then
        Log::displayError "Options2::validateOptionObject - callback '${callback}' - function does not exists"
        return 2
      fi
    done <<< "${callbacks}"
  fi

  if [[ "${variableType}" = "Boolean" ]]; then
    local onValue
    onValue="$(Object::getProperty validateOptionObject --property-onValue "strict")" || onValue="1"
    if [[ -z "${onValue}" ]]; then
      Log::displayError "Options2::validateOptionObject - onValue cannot be empty"
      return 2
    fi
    local offValue
    offValue="$(Object::getProperty validateOptionObject --property-offValue "strict")" || offValue="0"
    if [[ -z "${offValue}" ]]; then
      Log::displayError "Options2::validateOptionObject - offValue cannot be empty"
      return 2
    fi
    if [[ "${onValue}" = "${offValue}" ]]; then
      Log::displayError "Options2::validateOptionObject - onValue and offValue cannot be equal"
      return 2
    fi
  elif [[ "${variableType}" = "String" || "${variableType}" = "StringArray" ]]; then
    local authorizedValues
    authorizedValues="$(Object::getProperty validateOptionObject --property-authorizedValues "strict")" || authorizedValues=""
    if [[ "${authorizedValues}" =~ [[:space:]] ]]; then
      Log::displayError "Options2::validateOptionObject - authorizedValues invalid regexp '${authorizedValues}'"
      return 2
    fi

    local helpValueName
    helpValueName="$(Object::getProperty validateOptionObject --property-helpValueName "strict")" || helpValueName=""
    if [[ -n "${helpValueName}" && ! "${helpValueName}" =~ ^[A-Za-z0-9_-]+$ ]]; then
      Log::displayError "Options2::validateOptionObject - helpValueName should be a single word '${helpValueName}'"
      return 2
    fi

    if [[ "${variableType}" = "StringArray" ]]; then

      local min
      min="$(Object::getProperty validateOptionObject --property-min "strict")" || min="0"
      if [[ ! "${min}" =~ ^[0-9]+$ ]]; then
        Log::displayError "Options2::validateOptionObject - min value should be an integer greater than or equal to 0"
        return 2
      fi

      local max
      max="$(Object::getProperty validateOptionObject --property-max "strict")" || max="-1"
      if [[ -n "${max}" && ! "${max}" =~ ^([1-9][0-9]*|-1)$ ]]; then
        Log::displayError "Options2::validateOptionObject - max value should be an integer greater than 0 or -1"
        return 2
      fi

      if ((max != -1 && min > max)); then
        Log::displayError "Options2::validateOptionObject - max value should be greater than min value"
        return 2
      fi
    fi
  
  fi
}
