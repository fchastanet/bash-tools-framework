#!/usr/bin/env bash

# shellcheck disable=SC2034
declare optionFormat="plain"
declare optionFormatDefault="plain"
declare optionFormatAuthorizedValues="plain|checkstyle"

optionHelpCallback() {
  definitionLintCommandHelp
  exit 0
}

argFolderCallback() {
  if [[ ! -d "$1" ]]; then
    Log::fatal "Folder specified is not a valid directory: $1"
  fi
}
