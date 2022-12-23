#!/usr/bin/env bash

# get property value from file,
# if not present compute it using callback
# and store it in property file
Cache::getPropertyValue() {
  local propertyFile key callback value
  propertyFile="$1"
  shift || true
  key="$(echo -E "$1" | sed -E 's#\\#/#g')"
  shift || true
  callback=$1
  shift || true

  if grep -E "^${key}=.*" "${propertyFile}" &>/dev/null; then
    grep -E "^${key}=" "${propertyFile}" | cut -d'=' -f2
  elif [[ "$(type -t "${callback}")" = "function" ]]; then
    value="$(${callback} "$@")" || return $?
    if [[ -n "${value}" ]]; then
      echo -E "${key}=${value}" >>"${propertyFile}"
    fi
    echo -E "${value}"
  fi
}
