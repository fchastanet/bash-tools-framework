#!/usr/bin/env bash

# Retry a command 5 times with a delay of 15 seconds between each attempt
# @param          $@ the command to run
# @return 0 on success, 1 if max retries count reached
Retry::default() {
  Retry::parameterized 5 15 "" "$@"
}
