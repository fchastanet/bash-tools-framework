#!/usr/bin/env bash

Profiles::deps() {
  dependency="${SCRIPTS_DIR}/$1/dependencies"
  # shellcheck disable=SC2154
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
