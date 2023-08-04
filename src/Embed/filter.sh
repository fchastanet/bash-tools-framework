#!/usr/bin/env bash

# Find all EMBED directives
Embed::filter() {
  grep -E -e "^# EMBED (.+) (AS|as|As) (.+)$" "$@" || test $? = 1
}
