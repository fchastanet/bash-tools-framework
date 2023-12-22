#!/bin/bash

Object::setProperty() {
  local -n object_set_property_objectData=$1
  local propertyName="${2:-}"
  local propertyValue="${3:-}"
  
  local i=0 || true
  local -i propertiesLength="${#object_set_property_objectData[@]}"
  local -a newProperties=()
  local propertyFound="0"
  while ((i < propertiesLength)); do
    if [[ "${object_set_property_objectData[${i}]}" = "--property-${propertyName}" ]]; then
      propertyFound="1"
      newProperties+=(
        "${object_set_property_objectData[${i}]}" "${propertyValue}" 
      )
      if ((i < propertiesLength-2)); then
        newProperties+=("${object_set_property_objectData[@]:i+2}")
      fi
      break
    fi
    newProperties+=("${object_set_property_objectData[@]:i:2}")
    ((i=i+2))
  done
  if [[ "${propertyFound}" = "0" ]]; then
    newProperties+=("--property-${propertyName}" "${propertyValue}")
  fi
  object_set_property_objectData=("${newProperties[@]}")
}