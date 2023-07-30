#!/usr/bin/env bash
# BIN_FILE=${BIN_DIR}/var
# VAR_SCRIPT=myScript

.INCLUDE "$(dynamicTemplateDir _var.tpl)"

Args::defaultHelp "Help"

echo "${SCRIPT}"
