#!/usr/bin/env bash

Apt::addRepository() {
  Retry::default add-apt-repository -y "$1"
  Retry::default Apt::update
}
