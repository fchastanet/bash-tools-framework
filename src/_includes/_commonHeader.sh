#!/usr/bin/env bash

################################################
# Temp dir management
################################################

KEEP_TEMP_FILES="${KEEP_TEMP_FILES:-0}"
export KEEP_TEMP_FILES

# PERSISTENT_TMPDIR is not deleted by traps
PERSISTENT_TMPDIR="${TMPDIR:-/tmp}/bash-framework"
export PERSISTENT_TMPDIR
if [[ ! -d "${PERSISTENT_TMPDIR}" ]]; then
  mkdir -p "${PERSISTENT_TMPDIR}"
fi

# shellcheck disable=SC2034
TMPDIR="$(mktemp -d -p "${PERSISTENT_TMPDIR:-/tmp}" -t bash-framework-$$-XXXXXX)"
export TMPDIR

# temp dir cleaning
# shellcheck disable=SC2317
cleanOnExit() {
  local rc=$?
  if [[ "${KEEP_TEMP_FILES:-0}" = "1" ]]; then
    Log::displayInfo "KEEP_TEMP_FILES=1 temp files kept here '${TMPDIR}'"
  elif [[ -n "${TMPDIR+xxx}" ]]; then
    Log::displayDebug "KEEP_TEMP_FILES=0 removing temp files '${TMPDIR}'"
    rm -Rf "${TMPDIR:-/tmp/fake}" >/dev/null 2>&1
  fi
  exit "${rc}"
}
trap cleanOnExit EXIT HUP QUIT ABRT TERM
