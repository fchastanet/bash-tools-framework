#!/usr/bin/env bash

# @description load colors theme constants
# @warning if tty not opened, noColor theme will be chosen
# @arg $1 theme:String the theme to use (default, noColor)
# @arg $@ args:String[]
# @set __ERROR_COLOR String indicate error status
# @set __INFO_COLOR String indicate info status
# @set __SUCCESS_COLOR String indicate success status
# @set __WARNING_COLOR String indicate warning status
# @set __SKIPPED_COLOR String indicate skipped status
# @set __DEBUG_COLOR String indicate debug status
# @set __HELP_COLOR String indicate help status
# @set __TEST_COLOR String not used
# @set __TEST_ERROR_COLOR String not used
# @set __HELP_TITLE_COLOR String used to display help title in help strings
# @set __HELP_OPTION_COLOR String used to display highlight options in help strings
#
# @set __RESET_COLOR String reset default color
#
# @set __HELP_EXAMPLE String to remove
# @set __HELP_TITLE String to remove
# @set __HELP_NORMAL String to remove
UI::theme() {
  local theme="${1-default}"
  if ! Assert::tty; then
    theme="noColor"
  fi
  if [[ "${theme}" = "default" ]]; then
    export BASH_FRAMEWORK_THEME="default"
    # check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
    export __ERROR_COLOR='\e[31m'         # Red
    export __INFO_COLOR='\e[44m'          # white on lightBlue
    export __SUCCESS_COLOR='\e[32m'       # Green
    export __WARNING_COLOR='\e[33m'       # Yellow
    export __SKIPPED_COLOR='\e[33m'       # Yellow
    export __DEBUG_COLOR='\e[37m'         # Grey
    export __HELP_COLOR='\e[7;49;33m'     # Black on Gold
    export __TEST_COLOR='\e[100m'         # Light magenta
    export __TEST_ERROR_COLOR='\e[41m'    # white on red
    export __HELP_TITLE_COLOR="\e[1;37m"  # Bold
    export __HELP_OPTION_COLOR="\e[1;34m" # Blue
    # Internal: reset color
    export __RESET_COLOR='\e[0m' # Reset Color
    # shellcheck disable=SC2155,SC2034
    export __HELP_EXAMPLE="$(echo -e "\e[1;30m")"
    # shellcheck disable=SC2155,SC2034
    export __HELP_TITLE="$(echo -e "\e[1;37m")"
    # shellcheck disable=SC2155,SC2034
    export __HELP_NORMAL="$(echo -e "\033[0m")"
  else
    export BASH_FRAMEWORK_THEME="noColor"
    # check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
    export __ERROR_COLOR=''
    export __INFO_COLOR=''
    export __SUCCESS_COLOR=''
    export __WARNING_COLOR=''
    export __SKIPPED_COLOR=''
    export __DEBUG_COLOR=''
    export __HELP_COLOR=''
    export __TEST_COLOR=''
    export __TEST_ERROR_COLOR=''
    export __HELP_TITLE_COLOR=''
    export __HELP_OPTION_COLOR=''
    # Internal: reset color
    export __RESET_COLOR=''
    export __HELP_EXAMPLE=''
    export __HELP_TITLE=''
    export __HELP_NORMAL=''
  fi
}
