---
title: Commands
linkTitle: Commands
description: Command-line tools provided by Bash Tools Framework
type: docs
weight: 4
creationDate: 2026-03-01
lastUpdated: 2026-03-01
---

The Bash Tools Framework provides several command-line tools for linting, building, and managing bash projects.

## Build Tools

### awkLint
Lint all files with `.awk` extension in specified folder.

```bash
bin/awkLint [directory]
```

### dockerLint
Hadolint wrapper with automatic installation of hadolint.

```bash
bin/dockerLint [directory]
```

### shellcheckLint
ShellCheck wrapper with automatic installation of ShellCheck.

```bash
bin/shellcheckLint [directory]
```

### frameworkLint
Lint files of the current repository to ensure framework conventions are followed.

Checks for:
- All `Namespace::functions` exist in the framework
- Functions defined in `.sh` files are correctly named
- Each framework function has an associated bats test file
- `REQUIRE` directive `AS` ids are not duplicated
- Presence of `# FUNCTIONS`, `# REQUIREMENTS` and `# ENTRYPOINT` markers
- Correct ordering of placeholders

```bash
bin/frameworkLint
```

This linter is used in pre-commit hooks. See [.pre-commit-config.yaml](https://github.com/fchastanet/bash-tools-framework/blob/master/.pre-commit-config.yaml).

### definitionLint
Lint binary definition files (YAML).

```bash
bin/definitionLint
```

## Development Tools

### doc
Generate markdown documentation for the framework from source code comments.

```bash
bin/doc
```

This command:
- Extracts shdoc annotations from `.sh` files
- Generates comprehensive documentation
- Creates function reference pages

### installRequirements
Install development dependencies including:
- [bats-core/bats-core](https://github.com/bats-core/bats-core.git)
- [bats-core/bats-support](https://github.com/bats-core/bats-support.git)
- [bats-core/bats-assert](https://github.com/bats-core/bats-assert.git)
- [Flamefire/bats-mock](https://github.com/Flamefire/bats-mock.git)
- hadolint
- shellcheck
- shdoc

```bash
bin/installRequirements
```

Dependencies are automatically installed when first used. To force update, remove timeout files:
- `vendor/.shdocInstalled`
- `vendor/.batsInstalled`

### test.sh
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

## Docker Tools

### buildPushDockerImage
Build and push Docker images with proper tagging and caching.

```bash
bin/buildPushDockerImage
```

## Utility Tools

### findShebangFiles
Find files with shebang in a directory.

```bash
bin/findShebangFiles [directory]
```

### megalinter
Run MegaLinter for comprehensive code quality checks.

```bash
bin/megalinter
```

### plantuml
Generate PlantUML diagrams.

```bash
bin/plantuml
```

## Bash Compiler Integration

The framework works with [bash-compiler](https://github.com/fchastanet/bash-compiler), a GoLang implementation that generates standalone executables from YAML definitions.

### Compiling Binaries

Using generated binary:

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

## Example: Creating a Command

To create a new command using the framework:

1. Create a YAML definition in `src/_binaries/mycommand/mycommand-binary.yaml`
2. Define the command's options and main script
3. Compile using bash-compiler
4. The generated binary will be placed in `bin/mycommand`

See the [framework command template](https://github.com/fchastanet/bash-tools-framework/blob/master/.github/framework-command-template.yaml) for a starting point.
