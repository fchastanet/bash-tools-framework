#!/bin/bash

Object::create() {
  createTemplateFunction() {
    local type="$1"
    local functionName="$2"
    shift 2 || true
    local -a properties=("$@")
    local propertiesLength="${#properties[@]}"
      
    local -a allMembers=()
    ((i=0)) || true
    mapfile -t allMembers < <(
      while ((i < propertiesLength)); do
        echo "${properties[${i}]}" | sed -E 's/--(property|array)-//'
        ((i=i+2))
      done | sort -u
    )
    echo "${functionName}() {"
    # shellcheck disable=SC2016
    echo '  local command="$1"'
    echo "  local strict='${strict}'"
    echo -n '  '; declare -p properties
    # shellcheck disable=SC2016
    echo '  if [[ "${command}" = "type" ]]; then'
    echo "    echo '${type}'"
    # shellcheck disable=SC2016
    echo '  elif [[ "${command}" = "functionName" ]]; then'
    echo "   echo '${functionName}'"
    # shellcheck disable=SC2016
    echo '  elif [[ "${command}" = "strict" ]]; then'
    echo "   echo '${strict}'"
    # shellcheck disable=SC2016
    echo '  elif [[ "${command}" = "get" ]]; then'
      echo '    local i=0 || true'
      # shellcheck disable=SC2016
      echo '    local propertyName="$2"'
      # shellcheck disable=SC2016
      echo '    local propertyFound="0"'
      echo "    while ((i < ${propertiesLength})); do"
      # shellcheck disable=SC2016
      echo '      if [[ "${properties[${i}]}" =~ ^--property- && "${properties[${i}]#--property-}" = "${propertyName}" ]]; then'
      # shellcheck disable=SC2016
      echo '        echo "${properties[$((i+1))]}"'
      echo '        return 0'
      # shellcheck disable=SC2016
      echo '      elif [[ "${properties[${i}]}" =~ ^--array- && "${properties[${i}]#--array-}" = "${propertyName}" ]]; then'
      echo '        propertyFound="1"'
      # shellcheck disable=SC2016
      echo '        echo "${properties[$((i+1))]}"'
      echo '      fi'
      echo '      ((i=i+2))'
      echo '    done'
      # shellcheck disable=SC2016
      echo '    if [[ "${strict}" = "1" && "${propertyFound}" = "0" ]]; then'
      # shellcheck disable=SC2016
      echo '      Log::displayError "unknown property ${propertyName}"'
      echo '      return 2'
      echo '    fi'
    # shellcheck disable=SC2016
    echo '  elif [[ "${command}" = "getMembers" ]]; then'
      # shellcheck disable=SC2028
      echo "    printf '%s\n' ${allMembers[*]}"
    echo '  else'
    # shellcheck disable=SC2016
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
    --function-name)
      shift || true
      functionName="$1"
      ;;
    --strict)
      # strict means that property non existence is failing with error
      shift || true
      strict="$1"
      ;;
    --property-*)
      if Array::contains "$1" "${properties[@]}"; then
        Log::displayError "property ${1#--property-} is provided more than one time"
        return 6
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
    return 2
  fi
  if ! Assert::posixFunctionName "${type}"; then
    Log::displayError "invalid object type ${type}"
    return 5
  fi
  if [[ -z "${functionName}" ]]; then
    Log::displayError "missing object function name"
    return 3
  fi
  if ! Assert::posixFunctionName "${functionName}"; then
    Log::displayError "invalid object function name ${functionName}"
    return 4
  fi

  eval "$(createTemplateFunction "${type}" "${functionName}" "${properties[@]}")"
}
