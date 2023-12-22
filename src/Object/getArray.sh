#!/bin/bash

Object::getArray() {
  local -n object_get_array_objectData=$1
  local arrayName="${2:-}"
  local strict="${3:-0}"
  
  local -i propertiesLength="${#object_get_array_objectData[@]}"
  local -i i=0 || true
  local arrayFound="0"
  while ((i < propertiesLength)); do
    if [[ "${object_get_array_objectData[${i}]}" = "--array-${arrayName}" ]]; then
      arrayFound="1"
      echo "${object_get_array_objectData[$((i+1))]}"
    fi
    ((i=i+2))
  done
  if [[ "${strict}" = "1" && "${arrayFound}" = "0" ]]; then
    Log::displayError "unknown array ${arrayName}"
    return 1
  fi
}