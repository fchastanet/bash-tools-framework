#!/bin/bash

Object::getArray() {
  local -n object_get_array_objectData=$1
  local arrayName="${2:-}"
  local strict="${3:-0}"

  local -i propertiesLength="${#object_get_array_objectData[@]}"
  local -i i=0 || true
  while ((i < propertiesLength)); do
    if [[ "${object_get_array_objectData[${i}]}" = "--array-${arrayName}" ]]; then
      ((++i))
      # eat next elements until finding terminator
      while ((i < propertiesLength)); do
        if [[ "${object_get_array_objectData[${i}]}" = "${OBJECT_TEMPLATE_ARRAY_TERMINATOR:---}" ]]; then
          return 0
        fi
        echo "${object_get_array_objectData[${i}]}"
        ((++i))
      done
      return 0
    fi
    ((++i))
  done

  if [[ "${strict}" = "1" ]]; then
    Log::displayError "unknown array ${arrayName}"
    return 1
  fi
}
