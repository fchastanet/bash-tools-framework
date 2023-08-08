#!/usr/bin/env bash

if [[ -t 1 || -t 2 ]]; then
  # check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
  export __ERROR_COLOR='\e[31m'      # Red
  export __INFO_COLOR='\e[44m'       # white on lightBlue
  export __SUCCESS_COLOR='\e[32m'    # Green
  export __WARNING_COLOR='\e[33m'    # Yellow
  export __TEST_COLOR='\e[100m'      # Light magenta
  export __TEST_ERROR_COLOR='\e[41m' # white on red
  export __SKIPPED_COLOR='\e[33m'    # Yellow
  export __HELP_COLOR='\e[7;49;33m'  # Black on Gold
  export __DEBUG_COLOR='\e[37m'      # Grey
  # Internal: reset color
  export __RESET_COLOR='\e[0m' # Reset Color
  # shellcheck disable=SC2155,SC2034
  export __HELP_EXAMPLE="$(echo -e "\e[1;30m")"
  # shellcheck disable=SC2155,SC2034
  export __HELP_TITLE="$(echo -e "\e[1;37m")"
  # shellcheck disable=SC2155,SC2034
  export __HELP_NORMAL="$(echo -e "\033[0m")"
else
  # check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
  export __ERROR_COLOR=''
  export __INFO_COLOR=''
  export __SUCCESS_COLOR=''
  export __WARNING_COLOR=''
  export __SKIPPED_COLOR=''
  export __HELP_COLOR=''
  export __TEST_COLOR=''
  export __TEST_ERROR_COLOR=''
  export __DEBUG_COLOR=''
  # Internal: reset color
  export __RESET_COLOR=''
  export __HELP_EXAMPLE=''
  export __HELP_TITLE=''
  export __HELP_NORMAL=''
fi
