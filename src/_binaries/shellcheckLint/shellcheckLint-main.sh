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
      echo >&2 -n "."
      declare shellcheckExit=0
      # shellcheck disable=SC2086,SC2154
      "${PERSISTENT_TMPDIR}/shellcheck" ${shellcheckArgsStr} "$@" \
        >&2 >"${tmpDir}/${file%% *}" || shellcheckExit=$?
      if ((shellcheckExit != 0)); then
        echo "$@" >>"${failuresFile}"
      fi
      echo >&2 -n "."
    }
    export FRAMEWORK_VENDOR_BIN_DIR
    export -f Log::displayDebug Log::displayInfo Log::computeDuration \
      Log::logInfo Log::logDebug Log::logMessage
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

    echo >&2
    ((errorCount = 0)) || true
    if [[ "${optionFormat}" = "checkstyle" ]]; then
      (
        echo "<?xml version='1.0' encoding='UTF-8'?>"
        echo "<checkstyle version='4.3'>"
        awk '/<checkstyle/{flag=1; next} /<\/checkstyle>/{flag=0; next} flag' "${tmpDir}/"*
        echo "</checkstyle>"
      )
      errorCount=$(awk -F 'errors="' '/<file/{if ($2 > 0) {count += $2}} END{print count}' "${tmpDir}/"*)
    elif [[ "${optionFormat}" = "json" ]]; then
      # format: [
      # {"file":"file.sh","line":129,"endLine":129,"column":20,"endColumn":78,
      #  "level":"style","code":2126,"message":"...","fix":null}
      # ...]
      jq -s '.[] | select(length > 0) | add' "${tmpDir}/"* | jq -s '.'
      errorCount=$(jq -s 'map(length) | add' "${tmpDir}/"*)
    elif [[ "${optionFormat}" = "json1" ]]; then
      # format: {"comments":[
      # {"file":"file.sh","line":125,"endLine":125,"column":20,"endColumn":78,
      #  "level":"style","code":2126,"message":"...","fix":null}
      # ...]}
      jq -s 'map(.comments[])' "${tmpDir}/"* | jq '{"comments": .}'
      errorCount=$(jq -s 'map(length) | add' "${tmpDir}/"*)
    else
      cat "${tmpDir}/"*
      # shellcheck disable=SC2126 # grep -c not possible - we want to count the number of lines across all files
      errorCount=$(grep -E "^In " "${failuresFile}" "${tmpDir}/"* 2>/dev/null | wc -l || true)
    fi
    if ((errorCount > 0)); then
      Log::displayError "${errorCount} error(s) found by shellcheck"
      return 1
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
  Log::fatal "Some files failed shellcheck"
  return 1
else
  Log::displaySuccess "All files passed shellcheck with ${optionFormat} format"
fi
