#!/bin/bash

Object::setArray() {
  local -n object_set_array_objectData=$1
  local arrayName="${2:-}"
  shift 2 || true
  local -a arrayValues=("$@")
  
  local -i propertiesLength="${#object_set_array_objectData[@]}"
  local -a newProperties=()
  
  # remove all array element
  while ((i < propertiesLength)); do
    if [[ "${object_set_array_objectData[${i}]}" != "--array-${arrayName}" ]]; then
      newProperties+=("${object_set_array_objectData[@]:i:2}")
    fi
    ((i=i+2))
  done
  
  # add all new values
  local arrayValue
  for arrayValue in "${arrayValues[@]}"; do
    newProperties+=("--array-${arrayName}" "${arrayValue}")
  done
  object_set_array_objectData=("${newProperties[@]}")
}