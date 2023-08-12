#!/usr/bin/env bash

# @description create a temp file using default TMPDIR variable
# initialized in src/_includes/_header.tpl
#
# @arg $1 {templateName:String} template name to use(optional)
Framework::createTempFile() {
  mktemp -p "${TMPDIR:-/tmp}" -t "$1.XXXXXXXXXXXX"
}
