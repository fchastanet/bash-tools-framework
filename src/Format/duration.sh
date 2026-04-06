#!/usr/bin/env bash

# @description format a duration in seconds to a human readable format
# @arg $1 duration:int in seconds
# @stdout formatted duration
Format::duration() {
  local duration=$1

  local -a unit=(
    31536000
    8640000
    2592000
    604800
    86400
    3600
    60
    1
  )
  local -a unitLabels=(
    'year'
    'quarter'
    'month'
    'week'
    'day'
    'hour'
    'minute'
    'second'
  )

  if ((duration < 0)); then
    echo >&2 "Invalid duration: ${duration}"
    return 1
  fi

  if ((duration == 0)); then
    echo "0 second"
    return
  fi

  local unit
  local result=""
  for unitIndex in "${!unit[@]}"; do
    unit="${unit[${unitIndex}]}"
    unitLabel="${unitLabels[${unitIndex}]}"
    if ((duration < unit)); then
      continue
    fi
    local durationForUnit=$((duration / unit))
    local remainder=$((duration % unit))
    duration=${remainder}
    local unitPlural="${unitLabel}"
    if ((durationForUnit > 1)); then
      unitPlural="${unitPlural}s"
    fi
    result+="${result:+, }${durationForUnit} ${unitPlural}"
  done
  echo "${result}"
}
