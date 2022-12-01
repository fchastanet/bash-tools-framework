#!/usr/bin/env bash
# BUILD_BIN_FILE=${ROOT_DIR}/build/installBuildDeps.sh

.INCLUDE lib/_header.tpl

# FUNCTIONS

Git::shallowClone \
  "https://github.com/fchastanet/tomdoc.sh.git" \
  "${ROOT_DIR}/vendor/fchastanet.tomdoc.sh" \
  "master" \
  "1"

Git::shallowClone \
  "https://github.com/bats-core/bats-core.git" \
  "${ROOT_DIR}/vendor/bats" \
  "v1.5.0" \
  "1"

# last revision 2019
Git::shallowClone \
  "https://github.com/bats-core/bats-support.git" \
  "${ROOT_DIR}/vendor/bats-support" \
  "master" \
  "1"

Git::shallowClone \
  "https://github.com/bats-core/bats-assert.git" \
  "${ROOT_DIR}/vendor/bats-assert" \
  "34551b1d7f8c7b677c1a66fc0ac140d6223409e5" \
  "1"

Git::shallowClone \
  "https://github.com/Flamefire/bats-mock.git" \
  "${ROOT_DIR}/vendor/bats-mock-Flamefire" \
  "1838e83473b14c79014d56f08f4c9e75d885d6b2" \
  "1"
