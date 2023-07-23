# Todo

- [1. Framework functions changes](#1-framework-functions-changes)
- [2. Binaries improvement](#2-binaries-improvement)
  - [2.1. FrameworkLint](#21-frameworklint)
  - [2.2. compile](#22-compile)
    - [2.2.1. add compilation checks](#221-add-compilation-checks)
    - [2.2.2. Generate `__all.sh` file](#222-generate-__allsh-file)
- [3. Other improvements](#3-other-improvements)
  - [3.1. run precommit on github action](#31-run-precommit-on-github-action)
  - [3.2. Other libraries integration](#32-other-libraries-integration)
  - [Options/Args management](#optionsargs-management)
  - [3.3. Robustness](#33-robustness)
  - [3.4. Doc](#34-doc)
  - [3.5. Improve UT](#35-improve-ut)
  - [3.6. Refact - Move binaries to bash-tools](#36-refact---move-binaries-to-bash-tools)
  - [3.7. dev-env](#37-dev-env)
- [5. Compilation](#5-compilation)

## 1. Framework functions changes

- Conf::list findOptions as last arg so any number of args
- Args::version to display binary version
- extract from Profiles::lintDefinitions to Class::isInterfaceImplemented
  - define a sh format able to describe an interface
  - would it be possible to implement inheritance ?
- replace Command::captureOutputAndExitCode with Framework::run
- add Framework::timeElapsed to display elapsed time of the command run
  - eg: ShellDoc::generateShellDocsFromDir
  - could compute time elapsed of subShell ?
- new function Env::get "HOME"
- ensure filters functions never fails (check bashFrameworkFunctions) and ensure
  filters functions are not used as Assert function
- Wsl::cachedWslpathFromWslVar arg2 default value if variable not found
  - but no way to know if variable exists except by using `wslvar -S` or
    `wslvar -L`
- create function Array::remove
- use `builtin cd` instead of `cd`, `builtin pwd` instead of `pwd`, ... to avoid
  using customized aliased commands by the user

## 2. Binaries improvement

- rename metadata to annotation
- ROOT_DIR_RELATIVE_TO_BIN_DIR
  - Mandatory information allowing the compiler to deduce bash-tools-framework
    root directory.
  - deprecate usage of ROOT_DIR_RELATIVE_TO_BIN_DIR as all files can be embedded
- refact buildPushDockerImages.sh with Docker/functions... and using correct
  tagging
- add <https://github.com/fchastanet/bash-tools-framework> link inside help of
  each command
- awkLint/shellcheckLint use xargs
- do I add Env::load to \_header.tpl ?
  - no but load src/Env/testsData/.env by default ? using var
    BASH_FRAMEWORK_DEFAULT_ENV_FILE ?
- Update vendor command
  - command that allows to update the libraries in the repo
  - github cron that checks if library updates exists
- compile should use FRAMEWORK_SRC_DIRS from .framework-config

### 2.1. FrameworkLint

- check if 2 files have the same BINARY_FILE target
- refact src/\_binaries/frameworkLint.sh formatter for plain or checkstyle

### 2.2. compile

- use Filters::optimizeShFile
- check if nested namespaces are supported

#### 2.2.1. add compilation checks

- compile exit 1 if at least 1 warning
- error if bash-tpl template not found
  - File not found: '/dbQueryAllDatabases.awk'

#### 2.2.2. Generate `__all.sh` file

- generate automatically the `__all.sh` file
  - by including all the sh files of the directory except the ZZZ.sh
  - by including also dependent functions
  - it would mean to include dependent functions of the dependent function
    recursively
    - is it a good idea, as probably all the framework would be imported (like
      log, ...)
    - src/Log/\_\_all.sh contains ZZZ.sh
  - instead I could simply move bin files to src and compile them using the
    current bin file (inception) and so get rid of \_\_all.sh
  - could it be solved with dependency injection system ?

## 3. Other improvements

- Remove ROOT_DIR/SRC_DIR requirements from binaries
  - replace it by optional argument automatically added --root-dir
  - other default options to the binaries, log-level, display-log-level, ...
  - add options to `src/_includes/_headerNoRootDir.tpl`
- replace all envsubst by the usage of bash-tpl
- optimize doc generation (parallelization)
- rename TMPDIR to BASH_FRAMEWORK_TMP_DIR because as this variable overwritten
  and exported
  - it is used by called scripts
- migrate bash-tpl to <https://github.com/jirutka/esh/blob/master/esh.1.adoc> ?
- bash-tpl should be a vendor dependency

### 3.1. run precommit on github action

- add megalinter github action
  <https://github.com/marketplace/actions/megalinter>
- <https://github.com/pre-commit/action>

### 3.2. Other libraries integration

- integrate <https://github.com/adoyle-h/lobash> ?
- integrate <https://github.com/elibs/ebash> ?

### Options/Args management

- generate options parsing + doc from template

  - <https://github.com/ko1nksm/getoptions>
  - <https://github.com/matejak/argbash>
  - <https://argbash.dev>
  - <https://github.com/adoyle-h/lobash>
  - <https://github.com/elibs/ebash>

### 3.3. Robustness

- <https://dougrichardson.us/notes/fail-fast-bash-scripting.html>
  - add `shopt -s inherit_errexit`
  - add `set -u`
  - add this page comments to `BestPractices.md`

### 3.4. Doc

- register to <https://repology.org/projects/> in order to show matrix image
  <https://github.com/jirutka/esh/blob/master/README.adoc>
- update bashDoc
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

### 3.5. Improve UT

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

### 3.6. Refact - Move binaries to bash-tools

- move doc.sh, linters and other build tools to bash-tools
  - install.sh will get last version of build tools from bash-tools
  - import bash-tools commands + libs

### 3.7. dev-env

- import ck_ip_dev_env commands

## 5. Compilation

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

frameworkLint could generate a warning :

- if sudo called on Backup::file without using INCLUDE
- if INCLUDE is used but the binary is not used

- frameworkLint: ensure BIN_FILE is provided

- INCLUDE include one file, rest of the script is as usual

  - function allow to unzip the file

- INCLUDE "as" names should be unique + some forbidden names (existing bash
  functions)
