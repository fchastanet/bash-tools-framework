---
title: installRequirements command
linkTitle: Build - installRequirements
description: Overview of the installRequirements command for installing required libraries and tools for the Bash Tools Framework
tags: [commands, build]
type: docs
weight: 10
date: 2026-03-01
lastmod: 2026-03-02
version: 1.0
---

## 1. Help

**Command:** `bin/installRequirements --help`

## 2. Usage

`bin/installRequirements` script will install the following libraries inside `vendor` folder:

- [bats-core/bats-core](https://github.com/bats-core/bats-core.git)
- [bats-core/bats-support](https://github.com/bats-core/bats-support.git)
- [bats-core/bats-assert](https://github.com/bats-core/bats-assert.git)
- [Flamefire/bats-mock](https://github.com/Flamefire/bats-mock.git)
- hadolint
- shellcheck
- shdoc

`bin/doc` script will install:

- [reconquest/shdoc](https://github.com/reconquest/shdoc)
- hadolint
- shellcheck

Dependencies are automatically installed when first used. To avoid checking for libraries update and have an impact on
performance, a file is created in vendor dir.

- `vendor/.shdocInstalled`
- `vendor/.batsInstalled`

You can remove these files to force the update of the libraries, or just wait 24 hours for the timeout to expire 😉
