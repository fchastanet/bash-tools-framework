#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/shellcheckLint
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options/command.shellcheckLint.tpl)"

shellcheckLintCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

# shellcheck disable=SC2154
run() {
  getFiles() {
    exclude="$(sed -n -E 's/^exclude=(.+)$/\1/p' "${FRAMEWORK_ROOT_DIR}/.shellcheckrc" 2>/dev/null || true)"
    if [[ -z "${exclude}" ]]; then
      exclude='^$'
    fi
    export -f File::detectBashFile
    export -f Assert::bashFile

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
      (grep -E -v "${exclude}" || true) |
      LC_ALL=C.UTF-8 xargs -r -L 1 -n 1 -I@ bash -c "File::detectBashFile '@'"
  }

  declare -a files
  # shellcheck disable=SC2154
  if ((${#shellcheckFiles[@]} > 0)); then
    files=("${shellcheckFiles[@]}")
  else
    readarray -t files < <(getFiles | sort | uniq)
  fi
  Log::displayInfo "${#files[@]} files to check using ${optionFormat} format"

  if ((${#files[@]} > 0)); then
    (
      export FRAMEWORK_VENDOR_BIN_DIR
      # shellcheck disable=SC2317
      shellcheckFunction() {
        if (($# == 0)); then
          return 0
        fi
        if [[ "${optionTraceVerbose}" = "1" ]]; then
          set -x
        fi
        # shellcheck disable=SC2086
        "${FRAMEWORK_VENDOR_BIN_DIR}/shellcheck" ${shellcheckArgsStr} "$@"
      }
      export -f shellcheckFunction

      local -a xargsArgs=(
        --no-run-if-empty
        --process-slot-var=slot
      )
      if [[ "${optionXargs}" = "1" ]]; then
        xargsArgs+=(
          -P "$(nproc --ignore=1)"
          -n 10
        )
      fi

      if [[ "${optionTraceVerbose}" = "1" ]]; then
        xargsArgs+=(-t)
      fi
      local tmpDir
      tmpDir="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bash-tools-shellcheck-XXXXXX)"
      export tmpDir
      # shellcheck disable=SC2016
      echo "${files[@]}" |
        optionTraceVerbose="${optionTraceVerbose}" \
          shellcheckArgsStr="${shellcheckArgs[*]}" \
          xargs "${xargsArgs[@]}" \
          bash -c 'echo >&2 "linting $* ..."; file="$(md5sum <<<"$@")"; shellcheckFunction $@ | tee "${tmpDir}/${file%% *}" >&2; echo >&2 "linted $*"' bash
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
      else
        cat "${tmpDir}/"*
      fi
    )
  else
    Log::displayWarning "no file provided"
  fi
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
