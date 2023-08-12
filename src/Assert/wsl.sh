#!/usr/bin/env bash

# @description determine if the script is executed under WSL
#
# @exitcode 1 on error
Assert::wsl() {
  grep -qEi "(Microsoft|WSL)" /proc/version &>/dev/null || return 1
}
