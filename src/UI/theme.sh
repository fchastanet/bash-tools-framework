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
# shellcheck disable=SC2034
UI::theme() {
  local theme="${1-default}"
  if [[ ! "${theme}" =~ -force$ ]] && ! Assert::tty; then
    theme="noColor"
  fi
  case "${theme}" in
    default | default-force)
      theme="default"
      ;;
    noColor) ;;
    *)
      Log::fatal "invalid theme provided"
      ;;
  esac
  if [[ "${theme}" = "default" ]]; then
    BASH_FRAMEWORK_THEME="default"
    # check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
    __ERROR_COLOR='\e[31m'         # Red
    __INFO_COLOR='\e[44m'          # white on lightBlue
    __SUCCESS_COLOR='\e[32m'       # Green
    __WARNING_COLOR='\e[33m'       # Yellow
    __SKIPPED_COLOR='\e[33m'       # Yellow
    __DEBUG_COLOR='\e[37m'         # Gray
    __HELP_COLOR='\e[7;49;33m'     # Black on Gold
    __TEST_COLOR='\e[100m'         # Light magenta
    __TEST_ERROR_COLOR='\e[41m'    # white on red
    __HELP_TITLE_COLOR="\e[1;37m"  # Bold
    __HELP_OPTION_COLOR="\e[1;34m" # Blue
    # Internal: reset color
    __RESET_COLOR='\e[0m' # Reset Color
    # shellcheck disable=SC2155,SC2034
    __HELP_EXAMPLE="$(echo -e "\e[2;97m")"
    # shellcheck disable=SC2155,SC2034
    __HELP_TITLE="$(echo -e "\e[1;37m")"
    # shellcheck disable=SC2155,SC2034
    __HELP_NORMAL="$(echo -e "\033[0m")"
  else
    BASH_FRAMEWORK_THEME="noColor"
    # check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
    __ERROR_COLOR=''
    __INFO_COLOR=''
    __SUCCESS_COLOR=''
    __WARNING_COLOR=''
    __SKIPPED_COLOR=''
    __DEBUG_COLOR=''
    __HELP_COLOR=''
    __TEST_COLOR=''
    __TEST_ERROR_COLOR=''
    __HELP_TITLE_COLOR=''
    __HELP_OPTION_COLOR=''
    # Internal: reset color
    __RESET_COLOR=''
    __HELP_EXAMPLE=''
    __HELP_TITLE=''
    __HELP_NORMAL=''
  fi
}
