#!/usr/bin/env bash

# from src file extract all the lines containing `# META_var=value`
# with var being any name and value the value of the variable
# And generates export of this var with corresponding value
# Eg.: export var="value"
Compiler::extractMetaForExport() {
  local file="$1"
  # sed that will get header of the file until empty line
  sed -E -n '/^#/!q;p' "${file}" |
    grep -E '# META_.*=' |
    # https://regex101.com/r/7zDYFK/1
    sed -E 's/^#[ \t]+META_([^=]+)=[ \t]*([^\n\r]*)/\1="\2"\nexport \1\n/g' ||
    :
}
