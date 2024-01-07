#!/bin/bash

# @description check if member(property or array property) exists on given object
# @arg $1 object_member_exists_objectData:&String[] the object
# @arg $2 memberName:String the name of the member to search (eg: --property)
# @exitcode 1 if member not found
Object::memberExists() {
  local -n object_member_exists_objectData=$1
  local memberName="${2:-}"

  local -i propertiesLength="${#object_member_exists_objectData[@]}"
  local -i i=0 || true
  while ((i < propertiesLength)); do
    if [[ "${object_member_exists_objectData[${i}]}" = "${memberName}" ]]; then
      return 0
    fi
    ((i = i + 1))
  done
  return 1
}
