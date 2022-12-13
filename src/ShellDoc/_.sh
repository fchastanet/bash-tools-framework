#!/usr/bin/env bash

# shellcheck disable=SC2034
BASH_FRAMEWORK_TOMDOC_INSTALLED=$(mktemp -p "${TMPDIR:-/tmp}" -t tomdocInstalled.XXXX)
