#!/usr/bin/env bash
# BIN_FILE=${BIN_DIR}/meta
# META_SCRIPT=myScript

.INCLUDE "$(dynamicTemplateDir _meta.tpl)"

Args::defaultHelp "Help"

echo "${SCRIPT}"
