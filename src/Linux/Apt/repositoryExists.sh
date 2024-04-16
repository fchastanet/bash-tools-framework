#!/usr/bin/env bash

# @description check if apt repository is added to apt sources
# Linux::requireSudoCommand
# @require Linux::requireUbuntu
# @stdout diagnostics logs
Linux::Apt::repositoryExists() {
  local aptRepoName="$1"
  local regexp
  if [[ "${aptRepoName}" =~ https?:// ]]; then
    regexp="^[[:space:]]*deb ${aptRepoName}"
  else
    regexp="^[[:space:]]*deb .*${aptRepoName}"
  fi
  [[ -n "$(find /etc/apt/ -name '*.list' -print0 |
    xargs -0 -P 10 -L 1 grep "${regexp}" || true)" ]]
}
