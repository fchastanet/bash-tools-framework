#!/usr/bin/env bash
# BIN_FILE=${BIN_FILE}

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"
.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_load.tpl"

# shellcheck disable=SC2154,SC2016
functionToCall='<%% echo "${functionToCall}" %>'
"${functionToCall}" "$@"
