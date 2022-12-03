#!/usr/bin/env bash

# display info message
# And wall Text to speech to tell the message if wsl and powershell available
# Else try to use bip
# @param {String} $1 message to tell
# @global CAN_TALK_DURING_INSTALLATION if not 1 skip talking or beeping
UI::talkToUser() {
  local msg="${1:-Please, your input is required}"

  if [[ "${CAN_TALK_DURING_INSTALLATION:-1}" != "1" ]]; then
    return
  fi

  Log::displayInfo "${msg}"
  if Functions::isWsl && command -v powershell.exe &>/dev/null; then
    powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "${SCRIPTS_DIR}/talk.ps1" "'${msg}'" || true
  else
    tput bel || true
  fi
}
