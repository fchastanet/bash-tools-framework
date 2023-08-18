#!/usr/bin/env bash

# @description check if argument respects this framework variable naming convention
# - if variable begins with an uppercase or underscore, following letters have to be uppercase or underscore
# - variable name can includes ':' or '_' or digits but not as first letter
# here valid variable name examples
#
# @arg $1 variableName:String
# @exitcode 1 if regexp not matches
# @see https://regex101.com/r/BUlPXS/1
Assert::validVariableName() {
  echo "$1" | LC_ALL=POSIX grep -E -q '(^[a-z][A-Za-z_0-9:]+$)|(^[A-Z_][A-Z_0-9:]+$)'
}
