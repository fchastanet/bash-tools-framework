#!/usr/bin/env bash

# Public: determine if the script is executed under WSL
#
# @return 1 on error
Assert::wsl() {
  grep -qEi "(Microsoft|WSL)" /proc/version &>/dev/null || return 1
}
