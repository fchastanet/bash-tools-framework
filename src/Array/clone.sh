#!/usr/bin/env bash

Array::clone() {
  set -- "$(declare -p "$1")" "$2"
  eval "$2=${1#*=}"
}
