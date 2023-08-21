#!/usr/bin/env bash

# @description ensure COMMAND_BIN_DIR env var is set
# and PATH correctly prepared
# @noargs
# @set COMMAND_BIN_DIR string the directory where to find this command
# @set PATH string add directory where to find this command binary
Compiler::Facade::requireCommandBinDir() {
  COMMAND_BIN_DIR="${CURRENT_DIR}"
  Env::pathPrepend "${COMMAND_BIN_DIR}"
}
