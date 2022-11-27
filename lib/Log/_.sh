#!/usr/bin/env bash

# check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
export readonly __ERROR_COLOR='\e[31m'   # Red
export readonly __INFO_COLOR='\e[44m'    # white on lightBlue
export readonly __SUCCESS_COLOR='\e[32m' # Green
export readonly __WARNING_COLOR='\e[33m' # Yellow
export readonly __SKIPPED_COLOR='\e[93m' # Light Yellow
# shellcheck disable=SC2034
export readonly __TEST_COLOR='\e[100m' # Light magenta
# shellcheck disable=SC2034
export readonly __TEST_ERROR_COLOR='\e[41m' # white on red
# shellcheck disable=SC2034
export readonly __SKIPPED_COLOR='\e[33m' # Yellow
export readonly __DEBUG_COLOR='\e[37m'   # Grey
# Internal: reset color
export readonly __RESET_COLOR='\e[0m' # Reset Color
# shellcheck disable=SC2155,SC2034
export readonly __HELP_TITLE="$(echo -e "\e[1;37m")"
# shellcheck disable=SC2155,SC2034
export readonly __HELP_NORMAL="$(echo -e "\033[0m")"
