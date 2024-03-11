#!/usr/bin/env bash

# @description generate facade choice script
# - read all IMPLEMENT directives from original script file
# - deduce methods implemented by the script
# - generate a switch case that will call for arg $1,
#   the corresponding function of the interface
# - default case generates an error
# @example
#   # example of choice script generated
#   local action="$1"
#   shift || true
#   case ${action} in
#     interfaceFunction1)
#       interfaceFunction1 "$@"
#       ;;
#     interfaceFunction2)
#       interfaceFunction2 "$@"
#       ;;
#     *)
#       Log::displayError "invalid action requested: ${action}"
#       exit 1
#       ;;
#   esac
#   exit 0
#
# @arg $1 scriptFile:String the file from which a facade will be generated
# @exitcode 1 on template file not found or non readable file
# @exitcode 2 if FACADE doesn't implement any interface
# @stderr diagnostics information is displayed
# @see Compiler::Implement::mergeInterfacesFunctions
Compiler::Facade::generateFacadeChoiceScript() {
  local scriptFile="$1"

  local interfacesFunctionsStr
  interfacesFunctionsStr="$(Compiler::Implement::mergeInterfacesFunctions "${scriptFile}")" || return $?

  if [[ -z "${interfacesFunctionsStr}" ]]; then
    Log::displayWarning "in ${scriptFile} - FACADE doesn't implement any interface"
    return 2
  fi

  # generate code
  (
    printf $"local action="\$1"\n"
    printf 'shift || true\n'
    printf $"case \${action} in\n"
    # The function names have already been asserted
    local interfacesFunction
    while IFS='' read -r interfacesFunction; do
      printf "  %s)\n" "${interfacesFunction}"
      printf "    %s \"\$@\"\n" "${interfacesFunction}"
      printf "    ;;\n"
    done <<<"${interfacesFunctionsStr}"
    printf "  *)\n"
    printf '    if Assert::functionExists defaultFacadeAction; then\n'
    # shellcheck disable=SC2016
    printf '      defaultFacadeAction "$1" "$@"\n'
    printf '    else\n'
    printf $"      Log::displayError \"invalid action requested: \${action}\"\n"
    printf "      exit 1\n"
    printf '    fi\n'
    printf "    ;;\n"
    printf 'esac\n'
    printf 'exit 0\n'
  )

}
