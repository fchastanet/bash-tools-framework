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
Cache::getPropertyValue() {
  local value
  local propertyFile="$1"
  shift || true
  local key
  key="$(echo -E "$1" | sed -E 's#\\#/#g')"
  shift || true
  local propertyNotFoundCallback=$1
  shift || true

  if grep -E "^${key}=.*" "${propertyFile}" &>/dev/null; then
    grep -E "^${key}=" "${propertyFile}" | cut -d'=' -f2
    return 0
  elif [[ "$(type -t "${propertyNotFoundCallback}")" = "function" ]]; then
    value="$(${propertyNotFoundCallback} "$@")" || return $?
    if [[ -n "${value}" ]]; then
      echo -E "${key}=${value}" >>"${propertyFile}"
    fi
    echo -E "${value}"
    return 0
  fi
  return 1
}
