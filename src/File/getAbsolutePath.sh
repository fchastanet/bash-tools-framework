#!/usr/bin/env bash

# @description get absolute file from relative path
#
# @arg $1 file:String relative file path
#
# @stdout absolute path (can be $1 if $1 begins with /)
File::getAbsolutePath() {
  # http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
  realpath -e "$1"
}
