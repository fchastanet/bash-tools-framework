#!/usr/bin/env bash

BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )

# load bash-framework
# shellcheck source=bash-framework/_bootstrap.sh
source "$( cd "${BASE_DIR}" && pwd )/bash-framework/_bootstrap.sh"
import bash-framework/Git

Git::ShallowClone \
  "https://github.com/fchastanet/tomdoc.sh.git" \
  "${BASE_DIR}/vendor/fchastanet.tomdoc.sh" \
  "master" \
  "1"

Git::ShallowClone \
  "https://github.com/bats-core/bats-core.git" \
  "${BASE_DIR}/vendor/bats" \
  "v1.5.0" \
  "1"

# last revision 2019
Git::ShallowClone \
  "https://github.com/bats-core/bats-support.git" \
  "${BASE_DIR}/vendor/bats-support" \
  "master" \
  "1"

Git::ShallowClone \
  "https://github.com/bats-core/bats-assert.git" \
  "${BASE_DIR}/vendor/bats-assert" \
  "34551b1d7f8c7b677c1a66fc0ac140d6223409e5" \
  "1"

Git::ShallowClone \
  "https://github.com/Flamefire/bats-mock.git" \
  "${BASE_DIR}/vendor/bats-mock-Flamefire" \
  "1838e83473b14c79014d56f08f4c9e75d885d6b2" \
  "1"