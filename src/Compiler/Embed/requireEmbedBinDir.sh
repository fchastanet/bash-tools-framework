#!/usr/bin/env bash

# @description ensure tmpdir/bin exists and
# is added to PATH to make embed being executed automatically
# @noargs
# @exitcode 1 if cannot create tmp bin directory
# @set PATH string add tmp bin directory where to find embed binaries
# @stderr diagnostics information is displayed
Compiler::Embed::requireEmbedBinDir() {
  local tempDir="${TMPDIR:-/tmp}/bin"
  if [[ ! -d "${tempDir}" ]]; then
    if ! mkdir -p "${tempDir}"; then
      Log::displayError "unable to create directory ${TMPDIR:-/tmp}/bin"
      return 1
    fi
  fi
  Env::pathPrepend "${tempDir}"
}
