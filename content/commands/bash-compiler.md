---
title: bash-compiler command
linkTitle: Build - bash-compiler
description: Overview of the bash-compiler command for compiling bash scripts into standalone binaries using the bash-compiler framework
tags: [commands, build]
type: docs
weight: 10
date: 2026-03-01
lastmod: 2026-04-26T20:10:14+02:00
version: 1.1
---

## 1. Usage

The framework works with [bash-compiler](https://github.com/fchastanet/bash-compiler), a GoLang implementation that
generates standalone executables from YAML definitions.

Using `bash-compiler` binary:

```bash
export PATH=$PATH:/home/wsl/fchastanet/bash-compiler/bin
FRAMEWORK_ROOT_DIR=$(pwd) bash-compiler \
  src/_binaries/shellcheckLint/shellcheckLint-binary.yaml
```

Using Go interpreter (must be executed from bash-compiler folder):

```bash
export FRAMEWORK_ROOT_DIR=/home/wsl/fchastanet/bash-dev-env/vendor/bash-tools-framework
go run ./cmd/bash-compiler "${FRAMEWORK_ROOT_DIR}/src/_binaries/shellcheckLint/shellcheckLint-binary.yaml"
```

Compile all `*-binary.yaml` files at once:

```bash
export FRAMEWORK_ROOT_DIR=/home/wsl/fchastanet/bash-dev-env/vendor/bash-tools-framework
go run ./cmd/bash-compiler $(find "${FRAMEWORK_ROOT_DIR}/src/_binaries" -name '*-binary.yaml' -print)
```

See [Bash Compiler documentation](https://github.com/fchastanet/bash-compiler) for more information.

## 2. Example: Creating a Command

To create a new command using the framework:

1. Create a YAML definition in `src/_binaries/myCommand/myCommand-binary.yaml`
2. Define the command's options and main script
3. Compile using bash-compiler
4. The generated binary will be placed in `bin/myCommand`

See the
[framework command template](https://github.com/fchastanet/bash-tools-framework/blob/master/.github/framework-command-template.yaml)
for a starting point.

## 3. More info

- [Bash Compiler documentation](https://bash-compiler.devlab.top/)
