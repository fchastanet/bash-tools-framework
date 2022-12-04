#!/usr/bin/env bash

Profiles::deps() {
  local dep="$1"
  local -an allDepsResultSeen=$2
  dependency="${SCRIPTS_DIR}/${dep}/dependencies"
  if [[ "${allDepsResultSeen["$1"]}" = 'stored' ]]; then
    # avoid dead loop
    return 0
  fi
  if [[ -f "${dependency}" ]]; then
    # add single new line at the end of the file if not exist
    [[ -n "$(tail -c1 "${dependency}")" ]] && echo >>"${dependency}"
    grep -v '^#' "${dependency}"
  fi
}
