#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Format/duration.sh
source "${srcDir}/Format/duration.sh"

function Format::duration::zero { #@test
  run Format::duration 0 >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output "0 second"
}

function Format::duration::seconds { #@test
  run Format::duration 45 >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output "45 seconds"
}

function Format::duration::minutes { #@test
  run Format::duration 120 >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output "2 minutes"
}

function Format::duration::hours { #@test
  run Format::duration 7200 >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output "2 hours"
}

function Format::duration::days { #@test
  run Format::duration 172800 >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output "2 days"
}

function Format::duration::weeks { #@test
  run Format::duration 1209600 >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output "2 weeks"
}

function Format::duration::months { #@test
  run Format::duration 5184000 >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output "2 months"
}

function Format::duration::years { #@test
  run Format::duration 630720000 >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output "20 years"
}

function Format::duration::mixed { #@test
  local duration="$((20 * 31536000 + 1 * 60 + 45))"
  run Format::duration "${duration}" >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output "20 years, 1 minute, 45 seconds"
}

function Format::duration::mixedYearsMonthsDaysMinutes { #@test
  local duration="$((20 * 31536000 + 2 * 2592000 + 3 * 86400 + 5 * 60))"
  run Format::duration "${duration}" >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output "20 years, 2 months, 3 days, 5 minutes"
}

function Format::duration::fullMixWithYearQuarterMonthWeekDayHourMinuteSecond { #@test
  local duration="$((1 * 31536000 + 1 * 8640000 + 1 * 2592000 + 1 * 604800 + 1 * 86400 + 1 * 3600 + 1 * 60 + 1))"
  run Format::duration "${duration}" >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output "1 year, 1 quarter, 1 month, 1 week, 1 day, 1 hour, 1 minute, 1 second"
}

function Format::duration::fullMixWithYearsQuartersMonthsWeeksDaysHoursMinutesSeconds { #@test
  local duration="$((21 * 31536000 + 1 * 8640000 + 2 * 2592000 + 3 * 604800 + 4 * 86400 + 5 * 3600 + 6 * 60 + 45))"
  run Format::duration "${duration}" >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output "21 years, 1 quarter, 2 months, 3 weeks, 4 days, 5 hours, 6 minutes, 45 seconds"
}

function Format::duration::fullMixWithYearsQuartersMonthsWeeksDaysHoursMinutes0Second { #@test
  local duration="$((21 * 31536000 + 1 * 8640000 + 2 * 2592000 + 3 * 604800 + 4 * 86400 + 5 * 3600 + 6 * 60 + 0))"
  run Format::duration "${duration}" >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output "21 years, 1 quarter, 2 months, 3 weeks, 4 days, 5 hours, 6 minutes"
}
