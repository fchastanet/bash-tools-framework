#!/bin/bash

Object::initFromTemplate() {
  local -n object_init_from_template_template=$1
  local -n object_init_from_template_object=$2
  shift 2 || true
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
      if ((i < propertiesLength - 2)); then
        newProperties+=("${object_set_property_objectData[@]:i+2}")
      fi
      break
    fi
    newProperties+=("${object_set_property_objectData[${i}]}")
    ((i = i + 1))
  done
  if [[ "${propertyFound}" = "0" ]]; then
    newProperties+=("--property-${propertyName}" "${propertyValue}")
  fi
  object_set_property_objectData=("${newProperties[@]}")
}
