#!/usr/bin/env bash

# @description display info message
# And wall Text to speech to tell the message if wsl and powershell available
# Else try to use bip
# @arg $1 msg:String message to tell
# @env CAN_TALK_DURING_INSTALLATION if not 1 skip talking or beeping
UI::talkToUser() {
  local msg="${1:-Please, your input is required}"

  if [[ "${CAN_TALK_DURING_INSTALLATION:-1}" != "1" ]]; then
    return
  fi

  Log::displayInfo "${msg}"
  if Assert::wsl && "${BASH_FRAMEWORK_COMMAND:-command}" -v powershell.exe &>/dev/null; then
    powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "${SCRIPTS_DIR}/talk.ps1" "'${msg}'" || true
  else
    tput bel || true
  fi
}
