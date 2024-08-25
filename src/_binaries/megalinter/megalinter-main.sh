#!/usr/bin/env bash

declare -a megalinterOptions=(
  -e CLEAR_REPORT_FOLDER=true
  --workdir /tmp/lint
)

# shellcheck disable=SC2154
if [[ "${optionIncremental}" = "1" ]]; then
  declare -a updatedFiles
  IFS=$'\n' read -r -d '' -a updatedFiles < <(git --no-pager diff --name-only --cached || true) || true
  if ((${#updatedFiles[@]} == 0)); then
    Log::displayError "No files to lint in incremental mode"
    exit 1
  fi

  megalinterOptions+=(-e MEGALINTER_FILES_TO_LINT="$(Array::join "," "${updatedFiles[@]}")")
fi
checkIfMegalinterImageExists() {
  (
    # shellcheck disable=SC2154
    if [[ "${optionTraceVerbose}" = "1" ]]; then
      set -x
    fi
    # shellcheck disable=SC2154
    docker image ls -q "${optionMegalinterImage}"
  )
}
if [[ -z "$(checkIfMegalinterImageExists)" ]]; then
  (
    if [[ "${optionTraceVerbose}" = "1" ]]; then
      set -x
    fi
    docker pull "${optionMegalinterImage}"
  )
fi

if tty -s; then
  megalinterOptions+=("-it")
fi

if [[ -d "vendor/bash-tools-framework" ]]; then
  megalinterOptions+=(
    -v "$(cd vendor/bash-tools-framework && pwd -P):/tmp/lint/vendor/bash-tools-framework"
  )
fi

declare cmd=(
  docker run --rm --name=megalinter
  -e HOST_USER_ID="${HOST_USER_ID:-$(id -u)}"
  -e HOST_GROUP_ID="${HOST_GROUP_ID:-$(id -g)}"
  -e MEGALINTER_CONFIG="${optionMegalinterConfigFile}"
  "${megalinterOptions[@]}"
  -v /var/run/docker.sock:/var/run/docker.sock:rw
  -v .:/tmp/lint:rw
  "${optionMegalinterImage}"
)
Log::displayWarning "Running ${cmd[*]}"
(
  if [[ "${optionTraceVerbose}" = "1" ]]; then
    set -x
  fi
  "${cmd[@]}"
)
