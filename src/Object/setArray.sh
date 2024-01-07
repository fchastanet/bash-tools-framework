#!/bin/bash

# @description create or overwrite array property on object
# @arg $1 object_set_array_objectData:&String[] the object
# @arg $2 arrayName:String the name of the array property to search (eg: --array-property)
# @arg $@ arrayValues:String[] array values to set
Object::setArray() {
  local -n object_set_array_objectData=$1
  local arrayName="${2:-}"
  shift 2 || true
  local -a arrayValues=("$@")

  local -i propertiesLength="${#object_set_array_objectData[@]}"
  local -a newProperties=()

  while ((i < propertiesLength)); do
    if [[ "${object_set_array_objectData[${i}]}" = "${arrayName}" ]]; then
      ((++i))
      # eat next elements until finding terminator
      while ((i < propertiesLength)); do
        if [[ "${object_set_array_objectData[${i}]}" = "${OBJECT_TEMPLATE_ARRAY_TERMINATOR:---}" ]]; then
          ((++i))
          break
        fi
        ((++i))
      done
      break
    fi
    newProperties+=("${object_set_array_objectData[${i}]}")
    ((++i))
  done

  # copy rest of the properties if any
  while ((i < propertiesLength)); do
    newProperties+=("${object_set_array_objectData[${i}]}")
    ((++i))
  done

  # finally set the array
  newProperties+=("${arrayName}" "${arrayValues[@]}" "${OBJECT_TEMPLATE_ARRAY_TERMINATOR:---}")
  object_set_array_objectData=("${newProperties[@]}")
}
