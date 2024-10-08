#!/usr/bin/env bash

# @description fix markdown TOC generated by Markdown all in one vscode extension
# to make TOC compatible with docsify
# @arg $1 file:String file to fix
# @exitcode 1 if awk fails
# @see https://regex101.com/r/DJJf2I/1
ShellDoc::fixMarkdownToc() {
  local file="$1"

  # @embed "${FRAMEWORK_ROOT_DIR}/src/ShellDoc/fixMarkdownToc.awk" AS fixMarkdownTocScript
  # shellcheck disable=SC2154
  awk -i inplace -f "${embed_file_fixMarkdownTocScript}" "${file}"
}
