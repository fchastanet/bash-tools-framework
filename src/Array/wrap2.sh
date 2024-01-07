#!/usr/bin/env bash

# @description concat each element of an array with a separator
# but wrapping text when line length is more than provided argument
# The algorithm will try not to cut the array element if it can.
# if an arg can be placed on current line it will be,
#   otherwise current line is printed and arg is added to the new
#   current line
# empty arg is interpreted as a new line.
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

  eatNextSpaces() {
    if [[ "${currentChar}" != [[:space:]] ]]; then
      ((i--)) || true
      return 0
    fi
    for (( ; i < textLength; i++)); do
      if [[ "${text:${i}:1}" != [[:space:]] ]]; then
        ((i--)) || true
        break
      fi
    done
  }
  printCurrentLine() {
    echo -e "${currentLine}" | sed -E -e 's/[[:blank:]]*$//'
    ((isNewline = 1))
    currentLine="${indentStr}"
    ((currentLineLength = indentNextLine)) || true
  }
  nextLine() {
    printCurrentLine
    eatNextSpaces
  }
  local currentLine currentChar ansiCode
  local -i isAnsiCode currentLineLength=0 isNewline=1 textLength=0
  local text=""
  local arg=""
  while (($# > 0)); do
    arg="$1"
    shift || true
    if ((${#arg} == 0)) || [[ "${arg}" = $'\n' ]]; then
      if ((isNewline == 0)); then
        # isNewline = 0 means currentLine is not empty
        printCurrentLine
      fi
      echo
      continue
    fi
    local textFirstLine="${arg%%$'\n'*}"
    text="$(echo "${arg}" | sed -E '1d')"
    ((textLength = ${#text})) || true
    local textFirstLineNoAnsi
    textFirstLineNoAnsi="$(echo "${textFirstLine}" | Filters::removeAnsiCodes)"
    local -i textFirstLineNoAnsiLength=0
    ((textFirstLineNoAnsiLength = ${#textFirstLineNoAnsi})) || true

    if ((isNewline == 0)); then
      glueLength="${#glue}"
    else
      glueLength="0"
    fi
    if ((currentLineLength + textFirstLineNoAnsiLength + glueLength > maxLineLength)); then
      if ((isNewline == 0)); then
        # isNewline = 0 means currentLine is not empty
        printCurrentLine
      fi
      # restore current arg without considering first line
      text="${arg}"
      ((textLength = ${#text})) || true
    else
      if ((isNewline == 0)); then
        # isNewline = 0 means currentLine is not empty
        currentLine+="${glue}"
        ((currentLineLength += glueLength)) || true
      fi
      currentLine+="${textFirstLine}"
      isNewline="0"
      ((currentLineLength += ${#textFirstLine})) || true
    fi

    for ((i = 0; i < textLength; i++)); do
      currentChar="${text:${i}:1}"

      if [[ "${currentChar}" = $'\r' ]]; then
        # ignore
        true
      elif [[ "${currentChar}" = "\x1b" ]]; then
        isAnsiCode=1
        ansiCode+="${currentChar}"
      elif ((isAnsiCode == 1)); then
        ansiCode+="${currentChar}"
        if [[ "${currentChar}" =~ [mGKHF] ]]; then
          isAnsiCode=0
          echo -e "${ansiCode}"
        elif [[ "${currentChar}" = $'\n' ]]; then
          # invalid ansi code, ignore it
          isAnsiCode=0
          ansiCode=""
        fi
      else
        # non ansi code
        if [[ "${currentChar}" = $'\n' ]] || ((currentLineLength == maxLineLength)); then
          nextLine
        elif [[ "${currentChar}" = "\t" ]]; then
          if ((currentLineLength + 2 <= maxLineLength)); then
            currentLine+="  "
            ((isNewline = 0)) || true
            ((currentLineLength = currentLineLength + 2))
          else
            nextLine
          fi
        else
          currentLine+="${currentChar}"
          ((isNewline = 0)) || true
          ((++currentLineLength))
        fi
      fi
    done
  done
  if [[ "${currentLine}" != "" ]] && [[ ! "${currentLine}" =~ ^[\ \t]+$ ]]; then
    printCurrentLine
  fi
}
