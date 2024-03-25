#!/usr/bin/env bash

FIRST_LOG_DATE="$(date '+%s%3N')"
LOG_LAST_LOG_DATE="${FIRST_LOG_DATE}"
LOG_LAST_LOG_DATE_INIT=1

# @description Display message using info color (bg light blue/fg white)
# @arg $1 message:String the message to display
# @env DISPLAY_DURATION int (default 0) if 1 display elapsed time information between 2 info logs
Log::displayInfo() {
  local type="${2:-INFO}"
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_INFO)); then
    local durationMsg=""
    if ((DISPLAY_DURATION == 1)); then
      local duration
      local -i currentLogDate
      currentLogDate="$(date '+%s%3N')"
      if ((LOG_LAST_LOG_DATE_INIT == 1)); then
        LOG_LAST_LOG_DATE_INIT=0
        duration="Ref"
      else
        duration="$(( (currentLogDate - FIRST_LOG_DATE) /1000 ))s/+$(( (currentLogDate - LOG_LAST_LOG_DATE) /1000 ))s"
      fi
      LOG_LAST_LOG_DATE="${currentLogDate}"
      durationMsg="$(date '+%H:%M:%S.%3N')(${duration}) - "
    fi
    echo -e "${__INFO_COLOR}${type}    - ${durationMsg}${1}${__RESET_COLOR}" >&2
  fi
  Log::logInfo "$1" "${type}"
}
