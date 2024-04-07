#!/usr/bin/env bash

# @description get property value from file
# if not present compute it using propertyNotFoundCallback (if provided) and store it in property file
# @arg $1 propertyFile:String the file in which the property will be searched
# @arg $2 key:String the property key to search in property file
# @arg $3 propertyNotFoundCallback:Function (optional) a callback to call if property key is not found in property file
# @arg $@ args:String[] (optional) the arguments to pass to the propertyNotFoundCallback
# @exitcode 1 if value is not found
# @exitcode * if propertyNotFoundCallback fails
# @stdout the property value given by property file or by the propertyNotFoundCallback
Cache::getPropertyValue2() {
  local propertyFile="$1"
  local -n propertiesMap=$2
  local -n getPropertyValue2_val=$3
  local key="$4"
  local propertyNotFoundCallback=$5
  shift 5 || true
  local -a args=("$@")

  if [[ "${#propertiesMap[@]}" = "0" && -s "${propertyFile}" ]]; then
    local line
    while IFS="" read -r line; do
      if [[ "${line}" =~ ^([^=]+)=(.+)$ ]]; then
        propertiesMap["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
      fi
    done <"${propertyFile}"
  fi

  if [[ -n "${propertiesMap[${key}]+abc}" ]]; then
    getPropertyValue2_val="${propertiesMap[${key}]}"
    return 0
  elif [[ "$(type -t "${propertyNotFoundCallback}")" = "function" ]]; then
    getPropertyValue2_val="$("${propertyNotFoundCallback}" "${args[@]}")" || return $?
    propertiesMap["${key}"]="${getPropertyValue2_val}"
    echo "${key}=${getPropertyValue2_val}" >>"${propertyFile}"
    return 0
  fi
  return 1
}
