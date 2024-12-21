#!/usr/bin/env bash

# @description asserts that first argument is link to a file
# that exists
# @arg $1 link:String expected link
# @env SUDO String allows to use custom sudo prefix command
# @exitcode 1 if missing link
# @exitcode 2 if not a link
# @exitcode 3 if broken link (missing linked file)
# @stderr diagnostics information is displayed
Assert::symLinkValid() {
  local link="$1"
  Log::displayInfo "Check ${link} is a valid symlink"
  if ! ${SUDO:-} test -L "${link}" &>/dev/null; then
    if ! ${SUDO:-} test -e "${link}" &>/dev/null; then
      Log::displayError "${link} is not existing"
      exit 1
    fi
    Log::displayError "${link} exists but is not a link"
    return 2
  fi
  if ! ${SUDO:-} test -e "$(readlink "${link}")" &>/dev/null; then
    Log::displayError "Broken link ${link}"
    return 3
  fi
}
