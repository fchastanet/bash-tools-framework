#!/usr/bin/env bash

# @description ensure command git is available
# @exitcode 1 if git command not available
# @stderr diagnostics information is displayed
Git::requireGitCommand() {
  Assert::commandExists git
}
