#!/usr/bin/env bash

# @description load color theme
# @noargs
# @env BASH_FRAMEWORK_THEME String theme to use
# @env LOAD_THEME int 0 to avoid loading theme
# @exitcode 0 always successful
UI::requireTheme() {
  if [[ "${LOAD_THEME:-1}" = "1" ]]; then
    UI::theme "${BASH_FRAMEWORK_THEME-default}"
  fi
}
