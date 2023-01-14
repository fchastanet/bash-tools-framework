#!/usr/bin/env bash

Assert::validVariableName() {
  echo "$1" | grep -q '^[_[:alpha:]][_[:alpha:][:digit:]]*$' || return 1
}
