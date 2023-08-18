#!/usr/bin/env bash

# @description checks if function name provided exists
# @arg $1 functionName:String
# @exitcode 1 if function name doesn't exist
Assert::functionExists() {
  declare -F "$1" >/dev/null
}
