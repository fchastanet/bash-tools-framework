#!/usr/bin/env bash

hugoUpdateLastmodCallback() {
  # shellcheck disable=SC2154
  if [[ "${optionCommit}" == "1" && "${optionInit}" == "1" ]]; then
    Log::displayError "Options --commit and --init cannot be used together. Please choose one mode of operation."
    exit 1
  fi
}

optionHelpCallback() {
  hugoUpdateLastmodCommandHelp
  exit 0
}
