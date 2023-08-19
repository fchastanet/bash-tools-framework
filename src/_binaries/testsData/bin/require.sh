#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_BIN_DIR}/require

.INCLUDE "$(dynamicTemplateDir _header.tpl)"

# @require UI::requireColors
myFunction() {
  :
}

Args::defaultHelp "Help"
myFunction
