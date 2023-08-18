#!/usr/bin/env bash

# @description ensure linux runs under wsl
# @exitcode 1 if linux does not run under wsl
Linux::Wsl::requireWsl() {
  Assert::wsl
}
