#!/usr/bin/env bash

# @description from src file extract all the lines containing `# VAR_var=value`
# with var being any name and value the value of the variable
# And generates export of this var with corresponding value
# Eg.: export var="value"
# input file
# @example
#   #!/usr/bin/env bash
#   # VAR_VAR=VALUE
#   # VAR_VAR2=VALUE2
#   other code
#   # VAR_VAR2=VALUE3
# output
# @example
#   VAR="VALUE"
#   export VAR
#   VAR2="VALUE2"
#   export VAR2
# @arg $1 file:String
# @stdout list of export vars
Compiler::extractVarForExport() {
  local file="$1"
  # sed that will get header of the file until empty line
  sed -E -n '/^#/!q;p' "${file}" |
    grep -E '# VAR_.*=' |
    # https://regex101.com/r/7zDYFK/1
    sed -E 's/^#[ \t]+VAR_([^=]+)=[ \t]*([^\n\r]*)/\1="\2"\nexport \1\n/g' ||
    :
}
