#!/usr/bin/env bash
# BIN_FILE=${BIN_DIR}/embedBinary
# EMBED "<%% dynamicSrcFile embedDir/embedFile1 %>" as embedFile1
# EMBED "<%% dynamicSrcDir embedDir %>" as embedDir
# EMBED UI::displayLine as embedUIDisplayLine

.INCLUDE "$(dynamicTemplateDir _header.tpl)"

embedUIDisplayLine "-" 100
#shellcheck disable=SC2154
cat "${embed_file_embedFile1}"
#shellcheck disable=SC2154
ls -A "${embed_dir_embedDir}"
