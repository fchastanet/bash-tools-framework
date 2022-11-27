#!/usr/bin/env bash

# Public: determine if the script is executed under WSL
#
# @return 1 on error
Assert::wsl() {
  if grep -qEi "(Microsoft|WSL)" /proc/version &>/dev/null; then
    return 0
  else
    return 1
  fi
}
