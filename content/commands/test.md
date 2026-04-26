---
title: test.sh command
linkTitle: Build - test.sh
description: Overview of the test.sh command for running unit tests using bats inside Docker containers with needed dependencies
tags: [commands, test]
type: docs
weight: 10
date: 2026-03-01
lastmod: 2026-04-26T20:10:14+02:00
version: 1.0
---

## 1. Usage

Run unit tests using bats inside Docker container with needed dependencies.

```bash
# Run all tests on Ubuntu Bash 5.3
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 -r src -j 30

# Run specific test file
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 src/Array/contains.bats

# Run on different environments
./test.sh scrasnups/build:bash-tools-ubuntu-4.4 -r src -j 30
./test.sh scrasnups/build:bash-tools-ubuntu-5.0 -r src -j 30
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 -r src -j 30
./test.sh scrasnups/build:bash-tools-alpine-4.4 -r src -j 30
./test.sh scrasnups/build:bash-tools-alpine-5.0 -r src -j 30
./test.sh scrasnups/build:bash-tools-alpine-5.3 -r src -j 30
```
