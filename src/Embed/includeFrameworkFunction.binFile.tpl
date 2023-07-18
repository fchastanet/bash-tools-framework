#!/usr/bin/env bash
# BIN_FILE=${BIN_FILE}

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"

# shellcheck disable=SC2154
${functionToCall} "$@"
