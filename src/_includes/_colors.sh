#!/usr/bin/env bash

if [[ -t 1 || -t 2 ]]; then
  # check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
  readonly __ERROR_COLOR='\e[31m'      # Red
  readonly __INFO_COLOR='\e[44m'       # white on lightBlue
  readonly __SUCCESS_COLOR='\e[32m'    # Green
  readonly __WARNING_COLOR='\e[33m'    # Yellow
  readonly __TEST_COLOR='\e[100m'      # Light magenta
  readonly __TEST_ERROR_COLOR='\e[41m' # white on red
  readonly __SKIPPED_COLOR='\e[33m'    # Yellow
  readonly __HELP_COLOR='\e[7;49;33m'  # Black on Gold
  readonly __DEBUG_COLOR='\e[37m'      # Grey
  # Internal: reset color
  readonly __RESET_COLOR='\e[0m' # Reset Color
  # shellcheck disable=SC2155,SC2034
  readonly __HELP_EXAMPLE="$(echo -e "\e[1;30m")"
  # shellcheck disable=SC2155,SC2034
  readonly __HELP_TITLE="$(echo -e "\e[1;37m")"
  # shellcheck disable=SC2155,SC2034
  readonly __HELP_NORMAL="$(echo -e "\033[0m")"
else
  # check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
  readonly __ERROR_COLOR=''
  readonly __INFO_COLOR=''
  readonly __SUCCESS_COLOR=''
  readonly __WARNING_COLOR=''
  readonly __SKIPPED_COLOR=''
  readonly __HELP_COLOR=''
  readonly __TEST_COLOR=''
  readonly __TEST_ERROR_COLOR=''
  readonly __DEBUG_COLOR=''
  # Internal: reset color
  readonly __RESET_COLOR=''
  readonly __HELP_EXAMPLE=''
  readonly __HELP_TITLE=''
  readonly __HELP_NORMAL=''
fi
export __ERROR_COLOR
export __INFO_COLOR
export __SUCCESS_COLOR
export __WARNING_COLOR
export __SKIPPED_COLOR
export __TEST_COLOR
export __TEST_ERROR_COLOR
export __SKIPPED_COLOR
export __HELP_COLOR
export __DEBUG_COLOR
export __RESET_COLOR
export __HELP_EXAMPLE
export __HELP_TITLE
export __HELP_NORMAL
