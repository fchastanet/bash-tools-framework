#!/usr/bin/env bash

# @description create a temp file using default TMPDIR variable
# initialized in src/_includes/_header.tpl
# @env TMPDIR String (default value /tmp)
# @arg $1 templateName:String template name to use(optional)
Framework::createTempFile() {
  mktemp -p "${TMPDIR:-/tmp}" -t "${1:-}.XXXXXXXXXXXX"
}
