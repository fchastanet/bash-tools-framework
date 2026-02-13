# Copilot Instructions for bash-tools-framework

## Project Overview

**bash-tools-framework** is a comprehensive Bash library framework that provides reusable functions organized by namespace. It includes:
- 150+ unit-tested Bash functions (Array, File, Git, Docker, Database, etc.)
- Custom bash-compiler for generating standalone executables from YAML definitions
- Extensive linting and testing infrastructure
- Pre-commit hooks with MegaLinter integration
- Multi-version Bash testing (4.4, 5.0, 5.3 on Ubuntu and Alpine)

## Critical Conventions

### 1. Function Naming and File Organization

**MANDATORY PATTERN**: `Namespace::functionName` or `Namespace::SubNamespace::functionName`

- **File Path → Function Name**: `/src/Namespace/SubNamespace/functionName.sh` → `Namespace::SubNamespace::functionName()`
- Forward slashes (`/`) in paths convert to `::` in function names
- Each `.sh` file MUST contain exactly ONE function matching its path

**Directory Structure**:
```
src/
├── Namespace/             # Top-level namespace
│   ├── _.sh               # Namespace initialization (variables, constants)
│   ├── __all.sh           # Batch import file (sources multiple functions)
│   ├── functionName.sh    # Individual function implementation
│   ├── functionName.bats  # Unit test for the function
│   ├── SubNamespace/      # Nested namespace
│   └── testsData/         # Test fixtures (excluded from linting)
```

**Special Files**:
- `_.sh` - Namespace-level initialization, variables, docstrings (not unit tested)
- `__all.sh` - Batch import file that sources multiple related functions
- `ZZZ.sh` - Optional cleanup/final setup code (excluded from linting)
- Files in `testsData/`, `_binaries/`, `_includes/`, `_standalone/` are excluded from framework conventions

### 2. Function Documentation (shdoc format)

**REQUIRED annotations** for every function:
```bash
#!/usr/bin/env bash

# @description Brief description of what the function does
# @arg $1 paramName:Type description of parameter
# @arg $@ arrayParam:Type[] description of array parameter
# @env SOME_VAR String description of environment variable used
# @set RESULT_VAR description of variable set by function
# @exitcode 0 success condition
# @exitcode 1 failure condition
# @stdout description of output to stdout
# @stderr description of error output
# @example
#   Namespace::functionName "example" "args"
Namespace::functionName() {
  # implementation
}
```

**Rules**:
- `@description` is MANDATORY
- Use `@arg` for positional parameters (format: `$N name:Type description`)
- Use `@env` for environment variables read by the function
- Use `@set` for variables/arrays set by the function
- Use `@exitcode` to document all possible exit codes
- Use `@example` to show typical usage
- Documentation is parsed by shdoc to generate markdown

### 3. Testing Requirements

**Every function MUST have a corresponding `.bats` test file** (unless excluded in `.framework-config`).

**Test Structure**:
```bash
#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Namespace/functionName.sh
source "${BATS_TEST_DIRNAME}/functionName.sh"

function Namespace::functionName { #@test
  run Namespace::functionName "test" "args"
  assert_success
  assert_lines_count 1
  assert_line --index 0 --partial "expected output"
}
```

**Common test patterns**:
- `run <command>` - Executes command and captures output/exit code
- `assert_success` / `assert_failure [code]` - Check exit codes
- `assert_lines_count N` - Validate output line count
- `assert_line --index N --partial "text"` - Check specific output lines
- `stub <command> <return>` - Mock external commands (requires cleanup)
- `teardown() { unstub_all; }` - Clean up mocked commands

**Running tests**:
```bash
# Run all tests on Ubuntu Bash 5.3
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 -r src -j 30

# Run specific test file
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 src/Array/contains.bats

# Debug a specific test
vendor/bats/bin/bats -r src/Array/contains.bats --trace --verbose-run --filter "testName"
```

### 4. Bash Compiler Workflow

**Purpose**: Generates standalone executable binaries from YAML definitions that embed all required functions.

**Binary Definition Structure** (`src/_binaries/*/name-binary.yaml`):
```yaml
extends:
  - ${FRAMEWORK_ROOT_DIR}/src/_binaries/commandDefinitions/defaultCommand.yaml

compilerConfig:
  targetFile: "${FRAMEWORK_ROOT_DIR}/bin/commandName"
  relativeRootDirBasedOnTargetDir: ".."

binData:
  commands:
    default:
      functionName: commandNameFunction
      mainFile: ${FRAMEWORK_ROOT_DIR}/src/_binaries/commandName/commandName-main.sh
      definitionFiles:
        10: ${FRAMEWORK_ROOT_DIR}/src/_binaries/commandName/commandName-config.sh
        20: ${FRAMEWORK_ROOT_DIR}/src/_binaries/commandName/commandName-options.sh
      version: "1.0.0"
      copyrightBeginYear: 2024
      commandName: commandName
      author: "Author Name"
      license: MIT
      options:
        - variableName: OPTION_VAR
          type: String
          callbacks:
            - optionCallback
          help: "Description of option"
          alts:
            - --option
            - -o
```

**Compiling binaries** (requires external [bash-compiler](https://github.com/fchastanet/bash-compiler)):
```bash
# Compile single binary
export FRAMEWORK_ROOT_DIR=$(pwd)
bash-compiler src/_binaries/frameworkLint/frameworkLint-binary.yaml

# Compile all binaries
bash-compiler $(find src/_binaries -name '*-binary.yaml')
```

**Note**: Compiled binaries in `bin/` are committed to the repository. Re-compile after changing source files referenced in YAML definitions.
**Note2**: **Never** edit compiled binaries directly - always modify source files and re-compile.

## Development Workflow

### Initial Setup

1. **Install dependencies** (auto-installed when first used):
   ```bash
   bin/installRequirements  # Installs bats, shellcheck, hadolint, shdoc
   ```

2. **Install pre-commit hooks**:
   ```bash
   pre-commit install --hook-type pre-commit --hook-type pre-push
   ```

### Making Changes

1. **Add/modify a function**:
   - Create/edit `src/Namespace/functionName.sh` with proper annotations
   - Create/edit `src/Namespace/functionName.bats` test file
   - Run function-specific tests: `./test.sh scrasnups/build:bash-tools-ubuntu-5.3 src/Namespace/functionName.bats`

2. **Update compiled binaries**: If you modified functions used by a binary, recompile:

```bash
bash-compiler src/_binaries/commandName/commandName-binary.yaml
```

3. **Run linters**:

```bash
bin/frameworkLint          # Check framework conventions
bin/shellcheckLint         # ShellCheck linting
bin/awkLint               # AWK file linting
```

4. **Generate documentation**:

```bash
bin/doc                   # Generates markdown docs from shdoc annotations
```

### Common Errors and Solutions

#### Error: "Function X does not have a matching source file"
- **Cause**: frameworkLint detected a function call with no corresponding `.sh` file
- **Solution**: Create the missing file `src/Namespace/FunctionName.sh` or check for typos in function name

#### Error: "File X does not have a matching bats file"
- **Cause**: Each function needs a unit test
- **Solution**: Create `src/Namespace/functionName.bats` or add file pattern to `BATS_FILE_NOT_NEEDED_REGEXP` in `.framework-config`

#### Error: "Expected function name doesn't match actual"
- **Cause**: Function name doesn't match file path
- **Solution**: Rename function to match path: `/src/Array/contains.sh` → `Array::contains()`

#### Error: "Missing @description annotation"
- **Cause**: Function lacks required documentation
- **Solution**: Add `# @description ...` above function definition

#### Alpine Test Failures
- **Cause**: Some tests are Ubuntu-specific
- **Solution**: Tag Ubuntu-only tests with `# bats test_tags=ubuntu_only` and they'll be excluded on Alpine

## Linting and Quality Tools

### Pre-commit Hooks
- **Configuration**: `.pre-commit-config.yaml` (local) and `.pre-commit-config-github.yaml` (CI)
- **Main tools**: mdformat, shellcheck, actionlint, codespell, yamllint, prettier
- **Framework-specific**: `bin/frameworkLint` checks naming conventions and documentation

### MegaLinter
- **Configuration**: `.mega-linter.yml` (local), `.mega-linter-githubAction.yml` (CI)
- **Runs in CI**: Terraform flavor with extensive linters for Bash, YAML, JSON, Markdown, Docker
- **Auto-fixes**: Can create PRs with automatic fixes when `APPLY_FIXES_MODE=pull_request`

### ShellCheck
- **Configuration**: `.shellcheckrc`
- **Wrapper**: `bin/shellcheckLint` auto-installs ShellCheck if missing
- **Usage**: `bin/shellcheckLint [directory]`

### Other Linters
- **Hadolint**: Docker linting (`.hadolint.yaml`)
- **YAML**: `.yamllint.yml`
- **Markdown**: `.markdownlint.json` + `.markdown-link-check.json`
- **Spelling**: `cspell.yaml` + `.cspell/` dictionary files

## CI/CD Pipeline

### Workflow: `.github/workflows/lint-test.yml`

**Jobs**:
1. **build-bash-docker-images**: Builds test Docker images (6 variants: Ubuntu/Alpine × Bash 4.4/5.0/5.3)
2. **pre-commit**: Runs pre-commit hooks + MegaLinter, creates fix PRs if needed
3. **unit-tests**: Runs bats tests in parallel across all Docker variants (matrix)

**Key environment variables**:
- `CI_MODE=1` - Disables interactive features
- `VALIDATE_ALL_CODEBASE=true` - Lint all files (not just diff)
- `APPLY_FIXES_MODE=pull_request` - Auto-creates fix PRs

**Test results**: Published as JUnit reports and uploaded as artifacts

## Important Configuration Files

- `.framework-config` - Framework-specific settings (source dirs, ignore patterns)
- `.bash-compiler` - Bash compiler configuration
- `test.sh` - Test runner script (wraps bats in Docker)
- `preCommitTest.sh` - Quick pre-commit test subset
- `.pre-commit-hooks.yaml` - Defines this repo as a pre-commit hooks provider

## Best Practices

1. **Make minimal changes**: Only modify what's necessary for the task
2. **Follow naming conventions**: Strictly adhere to `Namespace::functionName` pattern
3. **Write tests first**: Create `.bats` file alongside new functions
4. **Document thoroughly**: Use all relevant shdoc annotations
5. **Test cross-platform**: Verify on both Ubuntu and Alpine (or tag Ubuntu-only)
6. **Recompile binaries**: After changing function signatures or implementations used in binaries
7. **Run frameworkLint**: Before committing to catch convention violations early
8. **Use existing patterns**: Study similar functions in the same namespace

## Architecture Notes

- **Framework config loading**: Uses `Env::requireLoad` to load `.framework-config` files hierarchically
- **Logging**: `Log::display*` functions output colored messages; `Log::log*` writes to files
- **Assertions**: `Assert::*` functions validate preconditions and exit with messages
- **Backup**: `Backup::file` and `Backup::dir` store backups in configured locations
- **Retry logic**: `Retry::*` functions wrap commands with automatic retries

## External Dependencies

**Required for development**:
- Bash 4.4+ (5.0+ recommended)
- Docker (for running tests)
- Pre-commit (for hooks)
- bash-compiler (external Go binary, not in this repo)

**Auto-installed** (to `vendor/`):
- bats-core
- bats-support, bats-assert, bats-mock
- shellcheck
- hadolint
- shdoc

## Documentation Generation

**Process**:
1. `bin/doc` extracts shdoc comments from `.sh` files
2. Generates markdown files in `doc/` directory
3. GitHub Pages served from `pages/` directory using Docsify
4. View locally: `docsify serve pages` (requires `npm i docsify-cli -g`)
5. Published at: https://fchastanet.github.io/bash-tools-framework/

## Related Projects

This framework is part of a suite:
- [bash-compiler](https://github.com/fchastanet/bash-compiler) - Compiles bash scripts
- [bash-tools](https://github.com/fchastanet/bash-tools) - Tools built with this framework
- [bash-dev-env](https://github.com/fchastanet/bash-dev-env) - Development environment setup

## Troubleshooting Tips

1. **Vendored dependencies missing**: Run `bin/installRequirements` or delete `vendor/.batsInstalled` / `vendor/.shdocInstalled` to force refresh

2. **Docker image not found**: Pull or build:
   ```bash
   docker pull scrasnups/build:bash-tools-ubuntu-5.3
   ```

3. **Exit code 127 on Alpine**: Known issue with `shopt -u lastpipe` in older bash-compiler versions - ensure latest compiler

4. **Pre-commit slow**: Use `--files` to limit scope or `SKIP=some-check pre-commit run`

5. **Merge conflicts in binaries**: Re-compile binaries after resolving source file conflicts

## Quick Reference

```bash
# Run all tests
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 -r src -j 30

# Run framework linter
bin/frameworkLint

# Compile a binary
bash-compiler src/_binaries/commandName/commandName-binary.yaml

# Generate documentation
bin/doc

# Install/update dependencies
bin/installRequirements

# Run pre-commit on all files
pre-commit run -a

# Debug a test
vendor/bats/bin/bats src/Array/contains.bats --trace --verbose-run
```
