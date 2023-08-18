#!/usr/bin/env bash
# BIN_FILE=${BIN_FILE}
# VAR_DEPRECATED_LOAD=1
# FACADE

# shellcheck disable=SC2154,SC2016
functionToCall='<% ${functionToCall} %>'
"${functionToCall}" "$@"
