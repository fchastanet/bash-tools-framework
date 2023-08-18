#!/usr/bin/env bash

# @description Retry a command 5 times with a delay of 15 seconds between each attempt
# @arg $@ command:String[] the command to run
# @exitcode 0 on success
# @exitcode 1 if max retries count reached
Retry::default() {
  Retry::parameterized 5 15 "" "$@"
}
