#!/usr/bin/env bash

# @description concatenate each element of an array with a separator
# but wrapping text when line length is more than provided argument
# The algorithm will try not to cut the array element if it can.
# - if an arg can be placed on current line it will be,
#   otherwise current line is printed and arg is added to the new
#   current line
# - Empty arg is interpreted as a new line.
# - Add \r to arg in order to force break line and avoid following
#   arg to be concatenated with current arg.
#
# @arg $1 glue:String
# @arg $2 maxLineLength:int
# @arg $3 indentNextLine:int
# @arg $@ array:String[]
Array::wrap2() {
  local glue="${1-}"
  local -i glueLength="${#glue}"
  shift || true
  local -i maxLineLength=$1
  shift || true
  local -i indentNextLine=$1
  shift || true
  local indentStr=""
  if ((indentNextLine > 0)); then
    indentStr="$(head -c "${indentNextLine}" </dev/zero | tr '\0' " ")"
  fi
  if (($# == 0)); then
    return 0
  fi

  printCurrentLine() {
    if ((isNewline == 0)) || ((previousLineEmpty == 1)); then
      echo
    fi
    ((isNewline = 1))
    echo -en "${indentStr}"
    ((currentLineLength = indentNextLine)) || true
  }
  appendToCurrentLine() {
    local text="$1"
    local -i length=$2
    ((currentLineLength += length)) || true
    ((isNewline = 0)) || true
    if [[ "${text: -1}" = $'\r' ]]; then
      text="${text:0:-1}"
      echo -en "${text%%+([[:blank:]])}"
      printCurrentLine
    else
      echo -en "${text%%+([[:blank:]])}"
    fi
  }

  (
    local currentLine
    local -i currentLineLength=0 isNewline=1 argLength=0
    local -a additionalLines
    local -i previousLineEmpty=0
    local arg=""

    while (($# > 0)); do
      arg="$1"
      shift || true

      # replace tab by 2 spaces
      arg="${arg//$'\t'/  }"
      # remove trailing spaces
      arg="${arg%[[:blank:]]}"
      if [[ "${arg}" = $'\n' || -z "${arg}" ]]; then
        printCurrentLine
        ((previousLineEmpty = 1))
        continue
      else
        if ((previousLineEmpty == 1)); then
          printCurrentLine
        fi
        ((previousLineEmpty = 0)) || true
      fi
      # convert eol to args
      mapfile -t additionalLines <<<"${arg}"
      if ((${#additionalLines[@]} > 1)); then
        set -- "${additionalLines[@]}" "$@"
        continue
      fi

      ((argLength = ${#arg})) || true

      # empty arg
      if ((argLength == 0)); then
        if ((isNewline == 0)); then
          # isNewline = 0 means currentLine is not empty
          printCurrentLine
        fi
        continue
      fi

      if ((isNewline == 0)); then
        glueLength="${#glue}"
      else
        glueLength="0"
      fi
      if ((currentLineLength + argLength + glueLength > maxLineLength)); then
        if ((argLength + glueLength > maxLineLength)); then
          # arg is too long to even fit on one line
          # we have to split the arg on current and next line
          local -i remainingLineLength
          ((remainingLineLength = maxLineLength - currentLineLength - glueLength))
          appendToCurrentLine "${glue:0:${glueLength}}${arg:0:${remainingLineLength}}" "$((glueLength + remainingLineLength))"
          printCurrentLine
          arg="${arg:${remainingLineLength}}"
          # remove leading spaces
          arg="${arg##[[:blank:]]}"

          set -- "${arg}" "$@"
        else
          # the arg can fit on next line
          printCurrentLine
          appendToCurrentLine "${arg}" "${argLength}"
        fi
      else
        appendToCurrentLine "${glue:0:${glueLength}}${arg}" "$((glueLength + argLength))"
      fi
    done
    if [[ "${currentLine}" != "" ]] && [[ ! "${currentLine}" =~ ^[\ \t]+$ ]]; then
      printCurrentLine
    fi
  ) | sed -E -e 's/[[:blank:]]+$//'
}
