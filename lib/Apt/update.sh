#!/usr/bin/env bash

Apt::update() {
  Functions::retry apt-get update -y --fix-missing -o Acquire::ForceIPv4=true
}
