#!/usr/bin/env bash

# @description add apt repository followed by an apt-get update
# @feature Retry::default
# Linux::requireSudoCommand
# @require Linux::requireUbuntu
Linux::Apt::addRepository() {
  Retry::default add-apt-repository -y "$1"
  Retry::default Linux::Apt::update
}
