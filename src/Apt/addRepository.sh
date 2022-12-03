#!/usr/bin/env bash

Apt::addRepository() {
  Retry::default add-apt-repository -y "$1"
  Apt::update
}
