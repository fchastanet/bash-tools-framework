#!/bin/bash

Object::getProperty() {
  local -n object_get_property_objectData=$1
  local propertyName="${2:-}"
  local strict="${3:-0}"

  local -i propertiesLength="${#object_get_property_objectData[@]}"
  local -i i=0 || true
  local propertyFound="0"
  while ((i < propertiesLength)); do
    if [[ "${object_get_property_objectData[${i}]}" = "--property-${propertyName}" ]]; then
      echo "${object_get_property_objectData[$((i + 1))]}"
      return 0
    fi
    ((i = i + 1))
  done
  if [[ "${strict}" = "1" && "${propertyFound}" = "0" ]]; then
    Log::displayError "unknown property ${propertyName}"
    return 1
  fi
}
