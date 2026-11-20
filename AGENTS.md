# AGENTS.md

Guidance for AI coding agents working in **bash-tools-framework**: a Bash library of unit-tested functions organized by
namespace (Array, File, Git, Docker, Database, Log, …), plus command binaries compiled from YAML definitions with
[bash-compiler](https://github.com/fchastanet/bash-compiler).

Related projects: [bash-tools](https://github.com/fchastanet/bash-tools),
[bash-dev-env](https://github.com/fchastanet/bash-dev-env) (this repo is often vendored at
`bash-dev-env/vendor/bash-tools-framework`).

## Repository layout

```text
src/
├── <Namespace>/              # one directory per namespace (Array, File, Log, ...)
│   ├── _.sh                  # namespace init (variables, constants), no bats needed
│   ├── __all.sh              # batch import of several functions
│   ├── ZZZ.sh                # optional final setup code
│   ├── functionName.sh       # exactly ONE function: Namespace::functionName
│   ├── functionName.bats     # its unit tests
│   ├── <SubNamespace>/       # nested namespace -> Namespace::SubNamespace::fn
│   └── testsData/            # fixtures (excluded from lint/conventions)
├── _binaries/<cmd>/          # command sources: <cmd>-binary.yaml, -main.sh, -options.sh
├── _standalone/              # standalone helpers (excluded from conventions)
└── batsHeaders.sh            # common bats setup sourced by every test
bin/                          # COMPILED binaries (committed, generated - never edit)
content/                      # Hugo/Docsy documentation site sources
.docker/                      # Dockerfiles for test images
manualTests/                  # manual test scripts
vendor/                       # auto-installed tools (bats, shellcheck, shdoc, ...)
```

Convention exclusions and regexps live in `.framework-config` (`NON_FRAMEWORK_FILES_REGEXP`,
`BATS_FILE_NOT_NEEDED_REGEXP`, `FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP`, …).

## Critical conventions

### File path ⇄ function name

`src/Namespace/Sub/functionName.sh` must define exactly one function `Namespace::Sub::functionName()`. `/` in the path
becomes `::`. Any call to a `Namespace::fn` must resolve to an existing file (checked by `bin/frameworkLint`).

### shdoc annotations (mandatory)

```bash
#!/usr/bin/env bash

# @description Brief description (MANDATORY)
# @arg $1 paramName:Type description
# @arg $@ args:String[] description
# @env SOME_VAR String env variable read by the function
# @set RESULT_VAR variable set by the function
# @exitcode 0 success condition
# @exitcode 1 failure condition
# @stdout what is written on stdout
# @stderr what is written on stderr
# @example
#   Namespace::functionName "arg"
Namespace::functionName() {
  local element
  # ...
}
```

### Bash style

- 2-space indentation, LF, final newline (`.editorconfig`); formatted by `shfmt`.
- ShellCheck with optional checks enabled (`.shellcheckrc`): always use braces `"${var}"`, `[[ ]]` instead of `[ ]`, a
  default `*)` case in `case`, no `which`, quote variables, no nullary conditions (`[[ -n "${x}" ]]`, not
  `[[ "${x}" ]]`).
- Declare function variables `local`. Targets Bash 4.4+ on Ubuntu and Alpine.

### Unit tests (bats)

Every function file needs a `.bats` file unless matched by `BATS_FILE_NOT_NEEDED_REGEXP`.

```bash
#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Namespace/functionName.sh
source "${BATS_TEST_DIRNAME}/functionName.sh"

teardown() {
  unstub_all
}

function Namespace::functionName::success { #@test
  run Namespace::functionName "arg"
  assert_success
  assert_lines_count 1
  assert_line --index 0 --partial "expected"
}
```

- Helpers: `run`, `assert_success`, `assert_failure [code]`, `assert_output`, `assert_line`, `assert_lines_count`,
  `stub cmd 'args : output'` + `unstub_all`.
- Tests that cannot run on Alpine: add `# bats test_tags=ubuntu_only`.
- Fixtures go in `testsData/` next to the tests.

### Command binaries (bash-compiler)

- A command lives in `src/_binaries/<cmd>/`: `<cmd>-binary.yaml` (definition, validated against
  `bash-tools-framework-schema.json`), `<cmd>-main.sh`, `<cmd>-options.sh`. Template:
  `.github/framework-command-template.yaml`.
- `bin/<cmd>` is **generated**: never edit it by hand. Change the sources, then recompile. Recompile every binary that
  embeds a function you changed, and commit the regenerated `bin/` files along with the sources.

```bash
export FRAMEWORK_ROOT_DIR="$(pwd)"
bash-compiler src/_binaries/ <cmd >/ <cmd >-binary.yaml   # one binary
bash-compiler $(find src/_binaries -name '*-binary.yaml') # all binaries
npx v8r src/_binaries/ <cmd >/ <cmd >-binary.yaml         # validate definition
```

## Commands

```bash
# Tests (run in Docker; images: scrasnups/build:bash-tools-{ubuntu,alpine}-{4.4,5.0,5.3})
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 -r src -j 30            # all
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 src/Array/contains.bats # one file
vendor/bats/bin/bats src/Array/contains.bats --trace --verbose-run --filter "name"

# Lint
bin/frameworkLint  # naming, annotations, bats presence
bin/shellcheckLint # ShellCheck (auto-installs)
bin/awkLint        # awk files
pre-commit run -a  # everything configured in .pre-commit-config.yaml

# Docs: generates markdown from shdoc into content/ (bashDoc/, commands/ are gitignored)
bin/doc

# Tooling (bats, shellcheck, hadolint, shdoc into vendor/)
bin/installRequirements
```

## Workflow for a change

1. Edit or create `src/Namespace/fn.sh` with full shdoc annotations, following existing functions in the same namespace.
2. Add/update `src/Namespace/fn.bats`; run it with `./test.sh`.
3. Run `bin/frameworkLint` and `bin/shellcheckLint`.
4. Recompile impacted binaries in `bin/` if needed.
5. Keep changes minimal; don't reformat unrelated code.

## Quality tooling & CI

- Pre-commit: `.pre-commit-config.yaml` (local) and `.pre-commit-config-github.yaml` (CI). Includes shfmt, shellcheck,
  frameworkLint, codespell/cspell (custom words in `.cspell/`, forbidden words in `.cspell/forbidden.txt`), mdformat,
  actionlint, v8r, plantuml, and `buildBashBinaries` (bash-compiler).
- MegaLinter: `.mega-linter.yml` (local), `.mega-linter-githubAction.yml` (CI).
- CI: `.github/workflows/main.yml` builds the Docker test images, runs pre-commit + MegaLinter (may open an auto-fix
  PR), and runs bats in a matrix over Ubuntu/Alpine × Bash 4.4/5.0/5.3. `build-site.yml` publishes the docs to
  <https://bash-tools-framework.devlab.top/>.

## Commit messages

Follow `.github/commit-message.instructions.md`: gitmoji + scope title in imperative mood, e.g.
`🔧(pre-commit): Update v8r hook configuration`, then a short summary and bullet details grouped by area.

## Troubleshooting

- "does not have a matching source file" → typo in a `Namespace::fn` call or missing `.sh` file.
- "does not have a matching bats file" → add the `.bats` file or extend `BATS_FILE_NOT_NEEDED_REGEXP`.
- Function name doesn't match path → rename the function, not the file layout.
- Missing vendored tools → `bin/installRequirements` (or delete `vendor/.batsInstalled` / `vendor/.shdocInstalled` to
  force reinstall).
- Conflicts in `bin/` → resolve the sources, then recompile; never hand-merge.

More detail: `.github/copilot-instructions.md`, `content/guides/`.
