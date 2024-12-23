#!/usr/bin/env bash

declare -g FIRST_LOG_DATE LOG_LAST_LOG_DATE LOG_LAST_LOG_DATE_INIT LOG_LAST_DURATION_STR
FIRST_LOG_DATE="${EPOCHREALTIME/[^0-9]/}"
LOG_LAST_LOG_DATE="${FIRST_LOG_DATE}"
LOG_LAST_LOG_DATE_INIT=1
LOG_LAST_DURATION_STR=""

# @description compute duration since last call to this function
# the result is set in following env variables.
# in ss.sss (seconds followed by milliseconds precision 3 decimals)
# @noargs
# @env DISPLAY_DURATION int (default 0) if 1 display elapsed time information between 2 info logs
# @set LOG_LAST_LOG_DATE_INIT int (default 1) set to 0 at first call, allows to detect reference log
# @set LOG_LAST_DURATION_STR String the last duration displayed
# @set LOG_LAST_LOG_DATE String the last log date that will be used to compute next diff
Log::computeDuration() {
  if ((${DISPLAY_DURATION:-0} == 1)); then
    local -i duration=0
    local -i delta=0
    local durationStr deltaStr
    local -i currentLogDate
    currentLogDate="${EPOCHREALTIME/[^0-9]/}"
    if ((LOG_LAST_LOG_DATE_INIT == 1)); then
      LOG_LAST_LOG_DATE_INIT=0
      LOG_LAST_DURATION_STR="Ref"
    else
      duration=$(((currentLogDate - FIRST_LOG_DATE) / 1000000))
      delta=$(((currentLogDate - LOG_LAST_LOG_DATE) / 1000000))
      if ((duration > 59)); then
        durationStr=$(date -ud "@${duration}" +'%H:%M:%S')
      else
        durationStr="${duration}s"
      fi
      if ((delta > 59)); then
        deltaStr=$(date -ud "@${delta}" +'%H:%M:%S')
      else
        deltaStr="${delta}s"
      fi
      LOG_LAST_DURATION_STR="${durationStr}/+${deltaStr}"
    fi
    LOG_LAST_LOG_DATE="${currentLogDate}"
    # shellcheck disable=SC2034
    local microSeconds="${EPOCHREALTIME#*.}"
    LOG_LAST_DURATION_STR="$(printf '%(%T)T.%03.0f\n' "${EPOCHSECONDS}" "${microSeconds:0:3}")(${LOG_LAST_DURATION_STR}) - "
  else
    # shellcheck disable=SC2034
    LOG_LAST_DURATION_STR=""
  fi
}
