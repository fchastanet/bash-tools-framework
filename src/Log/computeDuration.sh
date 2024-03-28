#!/usr/bin/env bash

declare -g FIRST_LOG_DATE LOG_LAST_LOG_DATE LOG_LAST_LOG_DATE_INIT LOG_LAST_DURATION_STR
FIRST_LOG_DATE="$(date '+%s%3N')"
LOG_LAST_LOG_DATE="${FIRST_LOG_DATE}"
LOG_LAST_LOG_DATE_INIT=1
LOG_LAST_DURATION_STR=""

# @description Display message using info color (bg light blue/fg white)
# @arg $1 message:String the message to display
# @env DISPLAY_DURATION int (default 0) if 1 display elapsed time information between 2 info logs
Log::computeDuration() {
  if ((DISPLAY_DURATION == 1)); then
    local -i duration=0
    local -i delta=0
    local -i currentLogDate
    currentLogDate="$(date '+%s%3N')"
    if ((LOG_LAST_LOG_DATE_INIT == 1)); then
      LOG_LAST_LOG_DATE_INIT=0
      LOG_LAST_DURATION_STR="Ref"
    else
      duration=$(((currentLogDate - FIRST_LOG_DATE) / 1000))
      delta=$(((currentLogDate - LOG_LAST_LOG_DATE) / 1000))
      LOG_LAST_DURATION_STR="${duration}s/+${delta}s"
    fi
    LOG_LAST_LOG_DATE="${currentLogDate}"
    # shellcheck disable=SC2034
    LOG_LAST_DURATION_STR="$(date '+%H:%M:%S.%3N')(${LOG_LAST_DURATION_STR}) - "
  else
    # shellcheck disable=SC2034
    LOG_LAST_DURATION_STR=""
  fi
}
