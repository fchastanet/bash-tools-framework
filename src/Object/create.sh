#!/bin/bash

# @description create a simili object based on function generation
# @exitcode 1 invalid command or invalid parameter
# @warning this function is using eval feature which can be dangerous 
# with unchecked data
Object::create() {
  local -n objectCreateVariable=$1
  shift || true
  # shellcheck disable=SC2016
  createTemplateFunction() {
    local type="$1"
    local functionName="$2"
    shift 2 || true
    local -a properties=("$@")
  
    echo "${functionName}() {"
    echo '  local command="$1"'
    echo "  local strict='${strict}'"
    echo -n '  '; declare -p properties
    echo '  local -i propertiesLength="${#properties[@]}"'
    echo '  if [[ "${command}" = "type" ]]; then'
    echo "    echo '${type}'"
    echo '  elif [[ "${command}" = "functionName" ]]; then'
    echo "   echo '${functionName}'"
    echo '  elif [[ "${command}" = "strict" ]]; then'
    echo "   echo '${strict}'"
    echo '  elif [[ "${command}" = "getProperty" ]]; then'
    echo '    local -i i=0 || true'
    echo '    local propertyName="$2"'
    echo '    local propertyFound="0"'
    echo '    while ((i < propertiesLength)); do'
    echo '      if [[ "${properties[${i}]}" = "--property-${propertyName}" ]]; then'
    echo '        echo "${properties[$((i+1))]}"'
    echo '        return 0'
    echo '      fi'
    echo '      ((i=i+2))'
    echo '    done'
    echo '    if [[ "${strict}" = "1" && "${propertyFound}" = "0" ]]; then'
    echo '      Log::displayError "unknown property ${propertyName}"'
    echo '      return 2'
    echo '    fi'
    echo '  elif [[ "${command}" = "setProperty" ]]; then'
    echo '    local i=0 || true'
    echo '    local propertyName="$2"'
    echo '    local propertyValue="$3"'
    echo '    local -a newProperties=()'
    echo '    local propertyFound="0"'
    echo '    while ((i < propertiesLength)); do'
    echo '      if [[ "${properties[${i}]}" = "--property-${propertyName}" ]]; then'
    echo '        propertyFound="1"'
    echo '        newProperties+=("${properties[${i}]}" "${propertyValue}" "${properties[@]:i+2}")'
    echo '        if ((i < propertiesLength-2)); then'
    echo '          newProperties+=("${properties[${i}]}" "${properties[$((i + 1))]}")'
    echo '        fi'
    echo '        break'
    echo '      fi'
    echo '      newProperties+=("${properties[${i}]}" "${properties[$((i + 1))]}")'
    echo '      ((i=i+2))'
    echo '    done'
    echo '    if [[ "${propertyFound}" = "0" ]]; then'
    echo '      newProperties+=("--property-${propertyName}" "${propertyValue}")'
    echo '    fi'
    echo "    eval \"\$(createTemplateFunction \"${type}\" \"${functionName}\" \"\${newProperties[@]}\")\""
    echo '  elif [[ "${command}" = "getArray" ]]; then'
    echo '    local -i i=0 || true'
    echo '    local propertyName="$2"'
    echo '    local propertyFound="0"'
    echo '    while ((i < propertiesLength)); do'
    echo '      if [[ "${properties[${i}]}" = "--array-${propertyName}" ]]; then'
    echo '        propertyFound="1"'
    echo '        echo "${properties[$((i+1))]}"'
    echo '      fi'
    echo '      ((i=i+2))'
    echo '    done'
    echo '    if [[ "${strict}" = "1" && "${propertyFound}" = "0" ]]; then'
    echo '      Log::displayError "unknown array ${propertyName}"'
    echo '      return 2'
    echo '    fi'
    echo '  elif [[ "${command}" = "setArray" ]]; then'
    echo '    local -i i=0 || true'
    echo '    local arrayName="$2"'
    echo '    local -a arrayValues=("$@")'
    echo '    local -a newProperties=()'
    echo '    local propertyFound="0"'
    echo '    while ((i < propertiesLength)); do'
    echo '      if [[ "${properties[${i}]}" = "--array-${propertyName}" ]]; then'
    echo '        propertyFound="1"'
    echo '        newProperties+=("${properties[${i}]}" "${propertyValue}")'
    echo '        if ((i < propertiesLength-2)); then'
    echo '          newProperties+=("${properties[@]:i+2}");'
    echo '        fi'
    echo '        break'
    echo '      fi'
    echo '      newProperties+=("${properties[${i}]}" "${properties[$((i + 1))]}")'
    echo '      ((i=i+2))'
    echo '    done'
    echo '    if [[ "${propertyFound}" = "0" ]]; then'
    echo '      newProperties+=("--property-${propertyName}" "${propertyValue}")'
    echo '    fi'
    echo "    eval \"\$(createTemplateFunction \"${type}\" \"${functionName}\" \"\${newProperties[@]}\")\""
    echo '  elif [[ "${command}" = "getMembers" ]]; then'
    echo '    while ((i < propertiesLength)); do'
    echo '      echo "${properties[${i}]}" | sed -E "s/--(property|array)-//"'
    echo '      ((i=i+2))'
    echo '    done | sort -u'
    echo '  else'
    echo '    Log::displayError "invalid command ${command}"'
    echo '    return 1'
    echo '  fi'
    echo '}'
  }
  
  local type functionName
  local strict="1"
  local -a properties=()
  while (($#>0)); do
    case "$1" in
    --type)
      shift || true
      type="$1"
      ;;
    --strict)
      # strict means that property non existence is failing with error
      shift || true
      strict="$1"
      ;;
    --property-*)
      if Array::contains "$1" "${properties[@]}"; then
        Log::displayError "property ${1#--property-} is provided more than one time"
        return 1
      fi
      properties+=("$1" "$2")
      shift || true
      ;;
    --array-*)
      properties+=("$1" "$2")
      shift || true
      ;;
    *)
      Log::displayError "invalid object property $1"
      return 1
    esac
    shift || true
  done
  
  if [[ -z "${type}" ]]; then
    Log::displayError "missing object type"
    return 1
  fi
  if ! Assert::posixFunctionName "${type}"; then
    Log::displayError "invalid object type ${type}"
    return 1
  fi
  functionName="$(Crypto::uuidV4)"
  functionName="${functionName//-/}"
  
  eval "$(createTemplateFunction "${type}" "${functionName}" "${properties[@]}")"
  # shellcheck disable=SC2034
  objectCreateVariable=${functionName}
}
