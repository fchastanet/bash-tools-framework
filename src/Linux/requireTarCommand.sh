#!/usr/bin/env bash

# @description ensure command tar is available
# @exitcode 1 if tar command not available
# @stderr diagnostics information is displayed
Linux::requireTarCommand() {
  Assert::commandExists tar
}
