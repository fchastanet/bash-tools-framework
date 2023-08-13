#!/usr/bin/env bash

# @description add apt repository followed by an apt-get update
# @feature Retry::default
# @feature sudo
# @constraint Apt::requiresUbuntu
Apt::addRepository() {
  Retry::default add-apt-repository -y "$1"
  Retry::default Apt::update
}
