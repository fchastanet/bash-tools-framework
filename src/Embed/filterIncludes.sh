#!/usr/bin/env bash

# Find all INCLUDE directives
Embed::filterIncludes() {
  grep -E -e "^# INCLUDE (.+) (AS|as|As) (.+)$" "$@" || test $? = 1
}
