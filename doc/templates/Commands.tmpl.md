---
title: Commands
linkTitle: Commands
description: Overview of the Bash Tools Framework command-line tools
type: docs
weight: 1002
date: 2026-03-01
lastmod: 2026-03-02
version: 1.0
---

<!-- @generated -->

The Bash Tools Framework provides several command-line tools for linting, building, and managing bash projects.

## 1. Compile command

The framework works with [bash-compiler](https://github.com/fchastanet/bash-compiler), a GoLang implementation that
generates standalone executables from YAML definitions.

### 1.1. Usage

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

### 1.2. Example: Creating a Command

To create a new command using the framework:

1. Create a YAML definition in `src/_binaries/myCommand/myCommand-binary.yaml`
2. Define the command's options and main script
3. Compile using bash-compiler
4. The generated binary will be placed in `bin/myCommand`

See the
[framework command template](https://github.com/fchastanet/bash-tools-framework/blob/master/.github/framework-command-template.yaml)
for a starting point.

## 2. Build Tools

### 2.1. bin/installRequirements

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

```text
@@@installRequirements_help@@@
```

### 2.2. bin/findShebangFiles

Find files with shebang in a directory.

```text
@@@findShebangFiles_help@@@
```

### 2.3. bin/buildPushDockerImage

Build and push Docker images with proper tagging and caching.

```text
@@@buildPushDockerImage_help@@@
```

### 2.4. bin/doc

Generate markdown documentation for the framework from source code comments. This command:

- Extracts shdoc annotations from `.sh` files
- Generates comprehensive documentation
- Creates function reference pages

```text
@@@doc_help@@@
```

### 2.5. test.sh

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

### 2.6. bin/hugoUpdateLastmod

Update `lastmod` field in Hugo frontmatter based on git modification dates or the current date. It can be run in two
modes: migration mode (using `--init`) to update all git-tracked markdown files in the `content/` directory, and commit
mode (using `--commit`) to update only staged files. The hook includes smart update detection to prevent unnecessary
changes, making it ideal for use in pre-commit hooks to ensure that your Hugo content is always up-to-date with the
latest modification dates.

```text
@@@hugoUpdateLastmod_help@@@
```

## 3. Linters

### 3.1. bin/frameworkLint

Lint files of the current repository to ensure framework conventions are followed.

This linter is used in pre-commit hooks. See
[.pre-commit-config.yaml](https://github.com/fchastanet/bash-tools-framework/blob/master/.pre-commit-config.yaml).

```text
@@@frameworkLint_help@@@
```

### 3.2. bin/dockerLint

Hadolint wrapper with automatic installation of hadolint.

```text
@@@dockerLint_help@@@
```

### 3.3. bin/shellcheckLint

ShellCheck wrapper with automatic installation of ShellCheck.

```text
@@@shellcheckLint_help@@@
```

### 3.4. bin/awkLint

Lint all files with `.awk` extension in specified folder.

```text
@@@awkLint_help@@@
```

### 3.5. bin/definitionLint

Lint binary definition files (YAML).

```text
@@@definitionLint_help@@@
```

### 3.6. bin/megalinter

Run MegaLinter for comprehensive code quality checks.

```text
@@@megalinter_help@@@
```

### 3.7. bin/cspellForbidden

Ensure .cspell/forbidden.txt exists and is used by cspell and launch cspell only on git files.

```text
@@@cspellForbidden_help@@@
```

## 4. Converter and Generator tools

### 4.1. bin/plantuml

Generate PlantUML diagrams.

```text
@@@plantuml_help@@@
```

### 4.2. bin/mermaid

Generate Mermaid diagrams.

```text
@@@mermaid_help@@@
```

### 4.3. bin/rimageWrapper

Generate images from source image files using the rimage tool.

```text
@@@rimageWrapper_help@@@
```

### 4.4. bin/krokiWrapper

Convert diagram files to images using Kroki CLI. Supports multiple diagram formats including PlantUML, Mermaid,
Graphviz, and many more.

```text
@@@krokiWrapper_help@@@
```

### 4.5. bin/html2image

Generate images from HTML files.

```text
@@@html2image_help@@@
```
