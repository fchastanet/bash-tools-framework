#!/usr/bin/env bash

# @description call simply original wslpath command
# @arg $@ args:String[] args to pass to wslpath
# @exitcode * wslpath exit code
# @stdout wslpath stdout
# @require Linux::Wsl::requireWsl
Linux::Wsl::originalWslpath() {
  wslpath "$@"
}
