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
  local -i firstLine=1
  shift || true
  (($# != 0)) || return 0

  local arg

  # convert multi-line arg to several args
  local -a allArgs=()
  for arg in "$@"; do
    local line
    local IFS=$'\n'
    arg="$(echo -e "${arg}")"
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
  local argNoAnsi
  local -i argNoAnsiLength=0

  while (($# > 0)); do
    argNoAnsi="$(echo "${arg%%*( )}" | Filters::removeAnsiCodes)"
    ((argNoAnsiLength = ${#argNoAnsi})) || true
    if (($# < 1 && argNoAnsiLength == 0)); then
      break
    fi
    if [[ "${arg}" = $'\n' ]]; then
      if [[ "${needEcho}" = "1" ]]; then
        needEcho="0"
      fi
      echo ""
      ((currentLineLength = 0)) || true
      ((glueLength = 0)) || true
      shift || return 0
      arg="$1"
    elif ((argNoAnsiLength < maxLineLength - currentLineLength - glueLength)); then
      # arg can be stored as a whole on current line
      if ((glueLength > 0)); then
        echo -e -n "${glue}"
        ((currentLineLength += glueLength))
      fi
      if ((currentLineLength == 0 && firstLine == 0)); then
        echo -n "${indentStr}"
      fi
      echo -e -n "${arg}" | sed 's/[\t ]*$//g'
      needEcho="1"
      ((currentLineLength += argNoAnsiLength))
      ((glueLength = ${#glue})) || true
      shift || return 0
      arg="$1"
    else
      if ((argNoAnsiLength >= (maxLineLength - indentNextLine))); then
        if ((currentLineLength == 0 && firstLine == 0)); then
          echo -n "${indentStr}"
          ((currentLineLength += indentNextLine))
        fi
        # arg can be stored on a whole line
        if ((glueLength > 0)); then
          echo -e -n "${glue}"
          ((currentLineLength += glueLength))
        fi
        local -i length
        ((length = maxLineLength - currentLineLength)) || true
        echo -e "${arg:0:${length}}" | sed 's/[\t ]*$//g'
        ((currentLineLength = 0)) || true
        ((glueLength = 0)) || true
        arg="${arg:${length}}"
        needEcho="0"
      else
        # arg cannot be stored on a whole line, so we add it on next line as a whole
        echo
        echo -e -n "${indentStr}${arg}" | sed 's/[\t ]*$//g'
        ((glueLength = ${#glue})) || true
        ((currentLineLength = argNoAnsiLength))
        arg="" # allows to go to next arg
        needEcho="1"
      fi
      if [[ -z "${arg}" ]]; then
        shift || return 0
        arg="$1"
      fi
    fi
    ((firstLine = 0)) || true
  done
  if [[ "${needEcho}" = "1" ]]; then
    echo
  fi
}

#set -x
#Array::wrap ":" 40 0 "Lorem ipsum dolor sit amet," "consectetur adipiscing elit." "Curabitur ac elit id massa" "condimentum finibus."
