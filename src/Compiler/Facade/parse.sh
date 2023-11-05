#!/usr/bin/env bash

# @description parse FACADE directive
# @example
#   # FACADE
#   # FACADE "_includes/facadeDefault/facadeDefault.tpl"
# @arg $1 str:String the directive to parse
# @arg $2 ref_template:&String (passed by reference) the facade template to use
# @arg $3 defaultFacadeTemplate:String the default facade template to use when no template is provided in FACADE directive
# @exitcode 1 on non existing template
Compiler::Facade::parse() {
  local str="$1"
  local -n ref_template=$2
  local defaultFacadeTemplate="${3:-_includes/facadeDefault/facadeDefault.tpl}"

  if [[ "${str}" =~ ^#\ FACADE(.*)$ ]]; then
    # shellcheck disable=SC2034
    ref_template="$(echo "${BASH_REMATCH[1]}" | Filters::trimString | Filters::removeExternalQuotes)"
    if [[ -z "${ref_template}" ]]; then
      ref_template="${defaultFacadeTemplate}"
    fi
    ref_template="$(dynamicTemplateDir "${ref_template}")"

    Compiler::Facade::assertFacadeTemplate "${ref_template}" || return $?
  fi
}
