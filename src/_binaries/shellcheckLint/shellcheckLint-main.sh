#!/usr/bin/env bash

Softwares::installShellcheck "${PERSISTENT_TMPDIR}/shellcheck"

# shellcheck disable=SC2154
getFiles() {
  shellcheckrcFile="${FRAMEWORK_ROOT_DIR}/.shellcheckrc"
  if [[ -f "${PWD}/.shellcheckrc" ]]; then
    shellcheckrcFile="${PWD}/.shellcheckrc"
  fi
  File::detectBashFileInit
  # Use grep with LC_ALL to safely handle the exclude pattern
  #exclude="$(grep -E '^exclude=' "${shellcheckrcFile}" 2>/dev/null | head -1 | cut -d= -f2- || true)"
  exclude="$(sed -n -E 's/^exclude=(.+)$/\1/p' "${shellcheckrcFile}" 2>/dev/null || true)"

  (
    if [[ "${optionStaged}" = "1" ]]; then
      (
        if [[ "${optionTraceVerbose}" = "1" ]]; then
          set -x
        fi
        git --no-pager diff --name-only --cached --diff-filter=udbx
      )
    else
      (
        if [[ "${optionTraceVerbose}" = "1" ]]; then
          set -x
        fi
        git ls-files --exclude-standard -c -o -m
      )
    fi
  ) |
    (if [[ -n "${exclude}" ]]; then grep -E -v "${exclude}"; else cat; fi) |
    LC_ALL=C.UTF-8 xargs -r -P0 -n 10 bash -c 'File::detectBashFile "$@"' arg0
}

shellcheckFiles() {
  declare -a files
  # shellcheck disable=SC2154
  if ((${#argShellcheckFiles[@]} > 0)); then
    files=("${argShellcheckFiles[@]}")
  else
    readarray -t files < <(getFiles | sort | uniq)
  fi
  # shellcheck disable=SC2154
  Log::displayInfo "${#files[@]} files to check using ${optionFormat} format"

  if ((${#files[@]} > 0)); then
    shellcheckScript() {
      set -o errexit -o pipefail
      if (($# == 0)); then
        return 0
      fi
      if [[ "${optionTraceVerbose}" = "1" ]]; then
        set -x
      fi
      if [[ "${debug}" = "1" ]]; then
        echo 2>&1 "Running shellcheck on the following files: $*"
      fi

      file="$(md5sum <<<"$@")"
      declare shellcheckExit=0
      # shellcheck disable=SC2086,SC2154
      "${PERSISTENT_TMPDIR}/shellcheck" ${shellcheckArgsStr} "$@" >"${tmpDir}/${file%% *}" >&2 || shellcheckExit=$?
      if ((shellcheckExit != 0)); then
        echo "$@" >>"${failuresFile}"
      fi
    }
    export FRAMEWORK_VENDOR_BIN_DIR
    export -f Log::displayDebug Log::computeDuration Log::logDebug Log::logMessage
    export -f shellcheckScript

    local -a xargsArgs=(
      --no-run-if-empty
      --process-slot-var=slot
    )
    # shellcheck disable=SC2154
    if [[ "${optionXargs}" = "1" ]]; then
      xargsArgs+=(
        -r
        -P0
        -n 10
      )
    fi

    if [[ "${optionTraceVerbose}" = "1" ]]; then
      xargsArgs+=(-t)
    fi
    local debug=0
    if [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "${__LEVEL_DEBUG}" ]]; then
      debug=1
    fi
    # shellcheck disable=SC2016,SC2154
    echo "${files[@]}" |
      optionTraceVerbose="${optionTraceVerbose}" \
        shellcheckArgsStr="${shellcheckArgs[*]}" \
        tmpDir="${tmpDir}" \
        debug="${debug}" \
        failuresFile="${failuresFile}" \
        xargs "${xargsArgs[@]}" \
        bash -c 'shellcheckScript "$@" || true' bash || true

    if [[ "${optionFormat}" = "checkstyle" ]]; then
      (
        echo "<?xml version='1.0' encoding='UTF-8'?>"
        echo "<checkstyle version='4.3'>"
        awk '/<checkstyle/{flag=1; next} /<\/checkstyle>/{flag=0} flag' "${tmpDir}/"*
        echo "</checkstyle>"
      )
    elif [[ "${optionFormat}" = "json" ]]; then
      (
        jq '.[]' "${tmpDir}/"* | jq -s '.'
      )
    elif [[ "${optionFormat}" = "json1" ]]; then
      jq -s 'map(.comments[])' "${tmpDir}/"* | jq '{"comments": .}'
    fi
  else
    Log::displayWarning "no file provided"
  fi
}

declare tmpDir
tmpDir="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bash-tools-shellcheck-XXXXXX)"
export tmpDir
declare failuresFile
failuresFile="${tmpDir}/.failures"
export failuresFile

shellcheckFiles

# Check if any shellcheck calls failed
if [[ -f "${failuresFile}" ]]; then
  cat "${failuresFile}" >&2
  return 1
else
  Log::displaySuccess "All files passed shellcheck with ${optionFormat} format"
fi
