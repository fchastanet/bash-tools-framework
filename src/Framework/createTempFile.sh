#!/usr/bin/env bash

# Public: create a temp file using default TMPDIR variable
# initialized in src/_includes/_header.tpl
#
# **Arguments**:
# @param $1 {String} template (optional)
Framework::createTempFile() {
  mktemp -p "${TMPDIR:-/tmp}" -t "$1.XXXXXXXXXXXX"
}
