#!/usr/bin/env bash

# @description ensure tmpdir/bin exists and
# is added to PATH to make embed being executed automatically
# @noargs
# @exitcode 1 if cannot create tmp bin directory
# @set PATH string add tmp bin directory where to find embed binaries
# @stderr diagnostics information is displayed
Compiler::Embed::requireEmbedBinDir() {
  mkdir -p "${TMPDIR:-/tmp}/bin" || {
    Log::displayError "unable to create directory ${TMPDIR:-/tmp}/bin"
    return 1
  }
  Env::pathPrepend "${TMPDIR:-/tmp}/bin"
}
