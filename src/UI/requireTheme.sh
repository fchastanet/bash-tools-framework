#!/usr/bin/env bash

# @description load color theme
# @noargs
# @env BASH_FRAMEWORK_THEME String theme to use
# @exitcode 0 always successful
UI::requireTheme() {
  UI::theme "${BASH_FRAMEWORK_THEME-default}"
}
