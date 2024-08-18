#!/usr/bin/env bash

declare versionNumber="1.0"
# shellcheck disable=SC2034
declare copyrightBeginYear="2022"

declare optionFormat="plain"
declare optionFormatDefault="plain"
declare optionFormatAuthorizedValues="plain|checkstyle"

Env::requireLoad
UI::requireTheme
Log::requireLoad

optionHelpCallback() {
  definitionLintCommandHelp
  exit 0
}

argFolderCallback() {
  if [[ ! -d "$1" ]]; then
    Log::fatal "Folder specified is not a valid directory: $1"
  fi
}
