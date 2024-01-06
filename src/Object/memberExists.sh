#!/bin/bash

Object::memberExists() {
  local -n object_member_exists_objectData=$1
  local propertyName="${2:-}"

  local -i propertiesLength="${#object_member_exists_objectData[@]}"
  local -i i=0 || true
  while ((i < propertiesLength)); do
    if [[ "${object_member_exists_objectData[${i}]}" = "${propertyName}" ]]; then
      return 0
    fi
    ((i = i + 1))
  done
  return 1
}
