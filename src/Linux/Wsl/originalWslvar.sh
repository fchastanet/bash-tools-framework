#!/usr/bin/env bash

# @description call simply original wslvar command
# @arg $@ args:String[] args to pass to wslvar
# @exitcode * wslvar exit code
# @stdout wslvar stdout
# @require Linux::Wsl::requireWsl
Linux::Wsl::originalWslvar() {
  wslvar "$@" | sed -z '$ s/[\r\n]$//'
}
