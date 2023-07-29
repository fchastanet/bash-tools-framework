# Todo

- [1. Improve UT](#1-improve-ut)
- [2. merge bash-tools into bash-tools-framework](#2-merge-bash-tools-into-bash-tools-framework)
- [3. Framework functions changes](#3-framework-functions-changes)
- [4. Update Bash-tools-framework dependencies](#4-update-bash-tools-framework-dependencies)
- [5. Compiler and bash Object oriented](#5-compiler-and-bash-object-oriented)
  - [5.1. Embed::include](#51-embedinclude)
  - [5.2. FrameworkLint](#52-frameworklint)
- [6. Binaries](#6-binaries)
  - [6.1. BashDoc](#61-bashdoc)
    - [6.1.1. add compilation checks](#611-add-compilation-checks)
  - [6.2. all binaries - template](#62-all-binaries---template)
  - [6.3. Binaries improvement](#63-binaries-improvement)
- [7. Other improvements/Studies](#7-other-improvementsstudies)
  - [7.1. run precommit on github action](#71-run-precommit-on-github-action)
  - [7.2. Other libraries integration](#72-other-libraries-integration)
  - [7.3. Options/Args management](#73-optionsargs-management)
- [8. best practices](#8-best-practices)
  - [8.1. Robustness](#81-robustness)

## 1. Improve UT

- ensure filters functions never fails (check bashFrameworkFunctions) and ensure
  filters functions are not used as Assert function
- bats assert that no new variable pollute environment to check that every
  variable is used as local
- test Env::load
  - Env::load with invalid .env file => should display a warning message
  - Env::load with missing .env file => fatal
  - Env::load twice do not source again the files
  - Env::load with 1 env file as parameter
  - Env::load with overriding BASH_FRAMEWORK_INITIALIZED="0"
  - Env::load with overriding BASH_FRAMEWORK_INITIALIZED="0"
    BASH_FRAMEWORK_ENV_FILEPATH="${ROOT_DIR}/.env"
  - Env::load with BASH_FRAMEWORK_ENV_FILEPATH
  - eg: Env::get "HOME" will get HOME variable from .env file if exists or get
    global HOME variable
  - replace all ${HOME} by $(Env::get "HOME")
  - generate automatically .env.template from Env::get
  - variables can be overridden by env variables using OVERRIDE_VARIABLE_NAME

## 2. merge bash-tools into bash-tools-framework

- move bash-tools binaries to bash-tools-framework
- import bash_dev_env commands but keep this project separated

## 3. Framework functions changes

- create function Array::remove
- Conf::list findOptions as last arg so any number of args
- replace Command::captureOutputAndExitCode with Framework::run that mimics bats
  run
- add Framework::timeElapsed to display elapsed time of the command run
  - eg: ShellDoc::generateShellDocsFromDir
  - could compute time elapsed of subShell ?

## 4. Update Bash-tools-framework dependencies

- Remove ROOT_DIR/SRC_DIR requirements from binaries
  - replace it by optional argument automatically added --root-dir
  - other default options to the binaries, log-level, display-log-level, ...
  - add options to `src/_includes/_headerNoRootDir.tpl`

## 5. Compiler and bash Object oriented

TODOs linked to bin/compiler:

- make compile options works with relative files
  - update CompileCommand.md examples
- rename metadata/meta data/annotation to directive
- extract from Profiles::lintDefinitions to Class::isInterfaceImplemented
  - define a sh format able to describe an interface
  - would it be possible to implement inheritance ?
- deprecate usage of ROOT_DIR_RELATIVE_TO_BIN_DIR as all files can be embedded
- compile should use FRAMEWORK_SRC_DIRS from .framework-config
- use Filters::optimizeShFile
- check if nested namespaces are supported
- get rid of `__all.sh` files, useless because of compiler auto include

### 5.1. Embed::include

- implement INCLUDE AS annotation
  - new bash-framework function to call bash-tpl (embedded)
  - replace all envsubst by the usage of bash-tpl

it doesn't matter if the command to execute is a sudo or not we just want to
encapsulate a dependent binary(bash or not) inside the executable.

- <https://blog.tratif.com/2023/02/17/bash-tips-6-embedding-files-in-a-single-bash-script/>
  - from bin file, generate a directory will all the necessary bin files and
    assets
  - tar the entire directory
  - create a bootstrap script able to untar and execute the entrypoint
- add INCLUDE meta data
- INCLUDE of a function of the framework will automatically generate a bin file
  called with the name of the function and calling this function
- using INCLUDE supposes to unsure the targeted binary has been constructed
- using INCLUDE with a framework function (eg: Backup::file) will first
  construct a bin file using that function directly
- inject Embed::extract\_${asName} just before the use of the alias(lazy
  loading)
  - remove the call in `src/Embed/includeFileFunction.tpl`

eg: Backup::file so it would allow to use `sudo Backup::file ...`

```bash
# INCLUDE Backup::file
```

### 5.2. FrameworkLint

- check if 2 files have the same BINARY_FILE target
- refact `src/_binaries/frameworkLint.sh` formatter for plain or checkstyle
- if sudo called on Backup::file without using INCLUDE
- if INCLUDE is used but the binary is not used
- ensure BIN_FILE is provided
- INCLUDE include one file, rest of the script is as usual
  - function allow to unzip the file
- INCLUDE "as" names should be unique + some forbidden names (existing bash
  functions)

## 6. Binaries

### 6.1. BashDoc

- update bashDoc and include it inside bash-tools-framework
- register to <https://repology.org/projects/> in order to show matrix image
  <https://github.com/jirutka/esh/blob/master/README.adoc>
- bash documentation
  - <https://www.sphinx-doc.org/en/master/>
  - <https://www.cyberciti.biz/faq/linux-unix-creating-a-manpage/> add man page
    heredoc + tool that extract heredoc from each sh files
  - asciidoctor to build manpages
  - <https://github.com/gumpu/ROBODoc>
  - could I use groovy doc ?
  - bashDoc linter check params coherence
    - 2 @param $1
    - @param $1 after @param $2
    - @paramDefault $1 just after @param $2

#### 6.1.1. add compilation checks

- compile exit 1 if at least 1 warning
- error if bash-tpl template not found
  - File not found: '/dbQueryAllDatabases.awk'

### 6.2. all binaries - template

default binary template improvement that adds:

- rename TMPDIR to BASH_FRAMEWORK_TMP_DIR because as this variable overwritten
  and exported
  - it is used by called scripts
- default arguments
  - Args::version to display binary version
- add <https://github.com/fchastanet/bash-tools-framework> link inside help of
  each command
- do I add Env::load to `_header.tpl` ?
  - no but load src/Env/testsData/.env by default ? using var
    BASH_FRAMEWORK_DEFAULT_ENV_FILE ?

### 6.3. Binaries improvement

TODOs linked to `src/_binaries/*`:

- refact buildPushDockerImages.sh with Docker/functions... and using correct
  tagging
- parallelization (use xargs)
  - awkLint
  - shellcheckLint
  - doc generation
- Update vendor command
  - command that allows to update the libraries in the repo
  - github cron that checks if library updates exists

## 7. Other improvements/Studies

- migrate bash-tpl to <https://github.com/jirutka/esh/blob/master/esh.1.adoc> ?
- bash-tpl should be a vendor dependency

### 7.1. run precommit on github action

- add megalinter github action
  <https://github.com/marketplace/actions/megalinter>
- <https://github.com/pre-commit/action>

### 7.2. Other libraries integration

- integrate <https://github.com/adoyle-h/lobash> ?
- integrate <https://github.com/elibs/ebash> ?

### 7.3. Options/Args management

- generate options parsing + doc from template

  - <https://github.com/ko1nksm/getoptions>
  - <https://github.com/matejak/argbash>
  - <https://argbash.dev>
  - <https://github.com/adoyle-h/lobash>
  - <https://github.com/elibs/ebash>

## 8. best practices

- use `builtin cd` instead of `cd`, `builtin pwd` instead of `pwd`, ... to avoid
  using customized aliased commands by the use
- Wsl::cachedWslpathFromWslVar arg2 default value if variable not found
  - but no way to know if variable exists except by using `wslvar -S` or
    `wslvar -L`

### 8.1. Robustness

- <https://dougrichardson.us/notes/fail-fast-bash-scripting.html>
  - add `shopt -s inherit_errexit`
  - add `set -u`
  - add this page comments to `BestPractices.md`
