#!/usr/bin/env bash
# BIN_FILE=${BIN_FILE}
# FACADE

# shellcheck disable=SC2154,SC2016
functionToCall='<% ${functionToCall} %>'
"${functionToCall}" "$@"
