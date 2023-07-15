#!/usr/bin/env bash

Embed::include() {
  local src="$1"
  local asName="$2"

  if ! Assert::validVariableName "${asName}"; then
    Log::displayError "invalid include name format ${asName}"
    return 1
  fi
  if [[ -f "${src}" ]]; then
    Embed::includeFile "${src}" "${asName}"
  elif [[ -d "${src}" ]]; then
    Embed::includeDir "${src}" "${asName}"
  elif Assert::bashFrameworkFunction "${src}"; then
    Embed::includeFrameworkFunction "${src}" "${asName}"
  else
    Log::displayError "invalid include ${src}"
    return 1
  fi
}
