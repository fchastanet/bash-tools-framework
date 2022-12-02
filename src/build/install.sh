#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/install
# BIN_FILE_RELATIVE2ROOT_DIR=..

.INCLUDE lib/_header.tpl

if ! command -v parallel 2>/dev/null; then
  Log::displayInfo "We will install GNU parallel software, please enter you sudo password"
  sudo apt update || true
  if sudo apt install -y parallel; then
    # remove parallel nagware
    mkdir -p ~/.parallel
    touch ~/.parallel/will-cite
  else
    Log::displayWarning "Impossible to install GNU parallel, please install it manually"
  fi
fi

if [[ -d "${HOME}/.bash-tools" ]]; then
  # update
  cp -R --no-clobber "${BASE_DIR}/conf/." "${HOME}/.bash-tools"
  [[ "${BASE_DIR}/conf/.env" -nt "${HOME}/.bash-tools/.env" ]] && {
    Log::displayWarning "${BASE_DIR}/conf/.env is newer than ${HOME}/.bash-tools/.env, compare the files to check if some updates need to be applied"
  }
else
  mkdir -p ~/.bash-tools
  cp -R conf/. ~/.bash-tools
  sed -i -e "s@^BASH_TOOLS_FOLDER=.*@BASH_TOOLS_FOLDER=$(pwd)@g" ~/.bash-tools/.env
fi