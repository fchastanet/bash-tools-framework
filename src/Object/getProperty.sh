#!/bin/bash

# @description get property value from object
# @arg $1 object_get_property_objectData:&String[] the object
# @arg $2 propertyName:String the name of the property to search (eg: --property)
# @arg $3 strict:Boolean if !0 then return code 1 if property not found
# @stdout the property value if property found
# @exitcode 1 if property not found
Object::getProperty() {
  local -n object_get_property_objectData=$1
  local propertyName="${2:-}"
  local strict="${3:-0}"

  local -i propertiesLength="${#object_get_property_objectData[@]}"
  local -i i=0 || true
  local propertyFound="0"
  while ((i < propertiesLength)); do
    if [[ "${object_get_property_objectData[${i}]}" = "${propertyName}" ]]; then
      echo "${object_get_property_objectData[$((i + 1))]}"
      return 0
    fi
    ((i = i + 1))
  done
  if [[ "${strict}" != "0" && "${propertyFound}" = "0" ]]; then
    return 1
  fi
}
