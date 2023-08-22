#!/usr/bin/env bash

# @description remove verbose args from BASH_FRAMEWORK_ARGV
# @noargs
# @set BASH_FRAMEWORK_ARGV String[] remove args -v --verbose -vv -vvv
Env::requireRemoveVerboseArg() {
  # remove verbose args from BASH_FRAMEWORK_ARGV
  Array::remove BASH_FRAMEWORK_ARGV -v --verbose -vv -vvv
}
