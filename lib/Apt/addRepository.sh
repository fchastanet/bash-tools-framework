#!/usr/bin/env bash

Apt::addRepository() {
  Functions::retry add-apt-repository -y "$1"
  Functions::aptUpdate
}
