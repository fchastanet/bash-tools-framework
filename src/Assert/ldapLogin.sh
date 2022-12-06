#!/usr/bin/env bash

Assert::ldapLogin() {
  [[ $1 =~ ^[a-z]+$ ]]
}
