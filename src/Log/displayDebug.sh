#!/usr/bin/env bash

# Display message using debug color (grey)
# @param {String} $1 message
Log::displayDebug() {
  if ((BASH_FRAMEWORK_LOG_LEVEL > __LEVEL_DEBUG)); then
    echo -e "${__DEBUG_COLOR}DEBUG   - ${1}${__RESET_COLOR}" >&2
  fi
}
