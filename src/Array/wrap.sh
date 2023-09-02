#!/usr/bin/env bash

# @description concat each element of an array with a separator
# but wrapping text when line length is more than provided argument
# The algorithm will try not to cut the array element if can
#
# @arg $1 glue:String
# @arg $2 maxLineLength:int
# @arg $3 indentNextLine:int
# @arg $@ array:String[]
Array::wrap() {
  local glue="${1-}"
  local -i glueLength=0
  shift || true
  local -i maxLineLength=$1
  shift || true
  local -i indentNextLine=$1
  local indentStr=""
  if ((indentNextLine > 0)); then
    indentStr="$(head -c "${indentNextLine}" </dev/zero | tr '\0' " ")"
  fi
  shift || true
  (($# != 0)) || return 0

  local arg

  # convert multi-line arg to several args
  local -a allArgs=()
  for arg in "$@"; do
    local line
    local IFS=$'\n'
    while read -r line; do
      if [[ -z "${line}" ]]; then
        allArgs+=($'\n')
      else
        allArgs+=("${line}")
      fi
    done <<<"${arg}"
  done
  set -- "${allArgs[@]}"

  local -i currentLineLength=0
  local needEcho="0"
  local arg="$1"
  while (($# > 0 || ${#arg} > 0)); do
    if [[ "${arg}" = $'\n' ]]; then
      printf $'\n\n'
      ((currentLineLength = 0)) || true
      ((glueLength = 0)) || true
      shift || return 0
      arg="$1"
    elif ((${#arg} < maxLineLength - currentLineLength - glueLength)); then
      # arg can be stored as a whole on current line
      if ((glueLength > 0)); then
        echo -n "${glue}"
        ((currentLineLength += glueLength))
      fi
      echo -n "${arg}"
      needEcho="1"
      ((currentLineLength += ${#arg}))
      ((glueLength = ${#glue})) || true
      shift || return 0
      arg="$1"
    else
      if ((${#arg} >= (maxLineLength - indentNextLine))); then
        # arg can be stored on a whole line
        if ((glueLength > 0)); then
          echo -n "${glue}"
          ((currentLineLength += glueLength))
        fi
        local -i length
        ((length = maxLineLength - currentLineLength)) || true
        echo "${arg:0:${length}}"
        ((currentLineLength = 0)) || true
        ((glueLength = 0)) || true
        arg="${indentStr}${arg:${length}}"
        needEcho="0"
      else
        # arg cannot be stored on a whole line, so we add it on next line as a whole
        echo
        echo -n "${indentStr}${arg}"
        ((glueLength = ${#glue})) || true
        ((currentLineLength = ${#arg}))
        arg="" # allows to go to next arg
        needEcho="1"
      fi
      if [[ -z "${arg}" ]]; then
        shift || return 0
        arg="$1"
      fi
    fi
  done
  if [[ "${needEcho}" = "1" ]]; then
    echo
  fi
}

#set -x
#Array::wrap ":" 40 0 "Lorem ipsum dolor sit amet," "consectetur adipiscing elit." "Curabitur ac elit id massa" "condimentum finibus."
