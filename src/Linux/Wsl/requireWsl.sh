#!/usr/bin/env bash

# @description ensure linux runs under wsl
# @exitcode 1 if linux does not run under wsl
Linux::Wsl::requireWsl() {
  Assert::wsl || return 1
  local tempEnvDir
  tempEnvDir="${WSL_TMPDIR:-${PERSISTENT_TMPDIR:-/tmp}}"
  File::garbageCollect "${tempEnvDir}/bash_tools_wslpath_$(id -un)" "1"
  tempEnvDir="${WSL_TMPDIR:-${PERSISTENT_TMPDIR:-/tmp}}"
  File::garbageCollect "${tempEnvDir}/bash_tools_wslvar_$(id -un)" "1"
}
