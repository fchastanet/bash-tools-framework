#!/usr/bin/env bash

Apt::install() {
  Functions::retry apt-get install -y -q "$@"
}
