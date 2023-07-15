#!/usr/bin/env bash
# BIN_FILE=${BIN_DIR}/meta
# META_SCRIPT=myScript
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

.INCLUDE "$(dynamicTemplateDir _meta.tpl)"

Args::defaultHelp "Help"

echo "${SCRIPT}"
