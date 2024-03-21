#!/usr/bin/env bash

# @description ensure linux runs under wsl
# @env WSL_GARBAGE_COLLECT int 0 to disable garbage collect of cache files
# @exitcode 1 if linux does not run under wsl
Linux::Wsl::requireWsl() {
  Assert::wsl || return 1
  if [[ "${WSL_GARBAGE_COLLECT:-1}" = "1" ]]; then
    local tempEnvDir
    tempEnvDir="${WSL_TMPDIR:-${PERSISTENT_TMPDIR:-/tmp}}"
    File::garbageCollect "${tempEnvDir}/bash_tools_wslpath_$(id -un)" "1"
    tempEnvDir="${WSL_TMPDIR:-${PERSISTENT_TMPDIR:-/tmp}}"
    File::garbageCollect "${tempEnvDir}/bash_tools_wslvar_$(id -un)" "1"
  fi
}
