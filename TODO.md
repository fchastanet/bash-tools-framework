# Todo

- [1. REQUIRE directive](#1-require-directive)
  - [Require use cases](#require-use-cases)
  - [1.1. refact env load using require ?](#11-refact-env-load-using-require-)
  - [1.2. Options/Args management](#12-optionsargs-management)
- [2. Framework functions changes](#2-framework-functions-changes)
- [3. Compiler and bash Object oriented](#3-compiler-and-bash-object-oriented)
  - [3.1. .framework-config should contain the compiler options](#31-framework-config-should-contain-the-compiler-options)
  - [3.2. compiler --profiler option](#32-compiler---profiler-option)
  - [3.3. FrameworkLint](#33-frameworklint)
- [4. project documentation improvements](#4-project-documentation-improvements)
- [5. Miscellaneous](#5-miscellaneous)
  - [5.1. New binaries](#51-new-binaries)
  - [5.2. automatic help generation](#52-automatic-help-generation)
  - [5.3. Binaries improvement](#53-binaries-improvement)
  - [5.4. merge bash-tools into bash-tools-framework](#54-merge-bash-tools-into-bash-tools-framework)
  - [5.5. run precommit on github action](#55-run-precommit-on-github-action)
  - [5.6. Improve UT](#56-improve-ut)
  - [5.7. best practices](#57-best-practices)
  - [5.8. Other libraries integration](#58-other-libraries-integration)

## 1. REQUIRE directive

- clarify when to use `# @feature sudo, ...`, shouldn't be a require ?
- define REQUIRE_DISABLED array in .framework-config
- Compiler::Requirement::assertRequireName
  - error if requires name does not begin with requires
  - error if requires name does not comply naming convention
- Compiler::Requirement::parseDisable + add automatically to global variable
  REQUIRE_DISABLED
  - Warn if a requirement has no associated file using
    Compiler::findFunctionInSrcDirs
- Compiler::Requirement::parse
  - Warn if a requirement has no associated file using
    Compiler::findFunctionInSrcDirs
- Compiler::Requirement::incrementRequireUsage
- Compiler::Requirement::addRequireDependency
- implement compiler pass
  - will parse `# REQUIRE` directives
    - error if _requires\*_ file not found
  - will ignore the disabled requirements
  - use of Compiler::Requirement::incrementRequireUsage
  - use of Compiler::Requirement::addRequireDependency
  - eventual framework functions needed will be imported
- on second pass, execute again compiler pass as eventual other `REQUIRE`
  directives could be found
- At the end of compiler processing, inject the requirements in the order
  specified by dependency tree.

### Require use cases

- `Log::display*` requires Log::load
  - Log::load requires Env::load
    - Env::load requires Framework::tmpFileManagement (see
      `src/_includes/_commonHeader.sh`)

### 1.1. refact env load using require ?

- test Env::load
  - Env::load with invalid .env file => should display a warning message
  - Env::load with missing .env file => fatal
  - Env::load twice do not source again the files
  - Env::load with 1 env file as parameter
  - Env::load with overriding BASH_FRAMEWORK_INITIALIZED="0"
  - Env::load with overriding BASH_FRAMEWORK_INITIALIZED="0"
    BASH_FRAMEWORK_ENV_FILEPATH="${FRAMEWORK_ROOT_DIR}/.env"
  - Env::load with BASH_FRAMEWORK_ENV_FILEPATH
  - eg: Env::get "HOME" will get HOME variable from .env file if exists or get
    global HOME variable
  - replace all ${HOME} by $(Env::get "HOME")
  - generate automatically .env.template from Env::get
  - variables can be overridden by env variables using OVERRIDE_VARIABLE_NAME
- log use alias
  - or check if we could use alias to override methods to be able to reload or
    pass by temp functions?
- logMessage do nothing if Log::load has been called, no need to check logLevel
  if Log::load do correctly its job
- do I add Env::load to `_header.tpl` ?
  - no but load src/Env/testsData/.env by default ? using var
    BASH_FRAMEWORK_DEFAULT_ENV_FILE ?

### 1.2. Options/Args management

- default arguments

  - Args::version to display binary version
  - IMPLEMENT special to manage options: --verbose, --version, --help, ...
  - other default options to the binaries: log-level, display-log-level, ...
  - arg configuration: display whole bash framework configuration

- generate options parsing + doc from template

  - <https://github.com/ko1nksm/getoptions>
  - <https://github.com/matejak/argbash>
  - <https://argbash.dev>
  - <https://github.com/adoyle-h/lobash>
  - <https://github.com/elibs/ebash>

## 2. Framework functions changes

- remove all process substitution as it hides exit code > 0
- replace `_colors.sh` with `Log/theme`
- Conf::list findOptions as last arg so any number of args
- merge Framework::run and Command::captureOutputAndExitCode
  - replace Command::captureOutputAndExitCode with Framework::run that mimics
    bats run
- Linux::Wsl::cachedWslpathFromWslVar arg2 default value if variable not found
  - but no way to know if variable exists except by using `wslvar -S` or
    `wslvar -L`

## 3. Compiler and bash Object oriented

TODOs linked to bin/compiler or templates .tpl:

- ADAPTER directive to allow to choose between multiple implementation
  dependening on require conditions
- make compile options works with relative files
  - display info should display relative path too instead of full path
- rename TMPDIR to BASH_FRAMEWORK_TMP_DIR because as this variable overwritten
  and exported, it is used by called scripts
- refact from Profiles::lintDefinitions to
  Compiler::Implement::validateInterfaceFunctions
- use Filters::optimizeShFile using
  [shfmt --minify option](https://github.com/mvdan/sh/blob/master/cmd/shfmt/shfmt.1.scd#generic-flags)
- bash-tpl should be a vendor dependency

### 3.1. .framework-config should contain the compiler options

- .framework-config should contain the compiler options
  - compile should use FRAMEWORK_SRC_DIRS from .framework-config
- Remove FRAMEWORK_ROOT_DIR/FRAMEWORK_SRC_DIR requirements from binaries
  - replace it by optional argument automatically added --root-dir
  - list binaries that really need FRAMEWORK_ROOT_DIR
  - deduce FRAMEWORK_ROOT_DIR based on most near .framework-config file ?

### 3.2. compiler --profiler option

- compile add profiler option
  - if parameter --profiler is passed to compiler, then inject profiling of all
    bash framework function
  - add Framework::timeElapsed to display elapsed time of the command run
  - eg: ShellDoc::generateShellDocsFromDir
  - could compute time elapsed of subShell ?

### 3.3. FrameworkLint

- check no use of ${TMPDIR} without default value
- check if 2 files have the same BINARY_FILE target
- if sudo called on Backup::file without using EMBED
- if EMBED is used but the binary is not used
- ensure BIN_FILE is provided
- EMBED "as" names should be unique + some forbidden names (existing bash
  functions)
- shDoc linter check params coherence
  - 2 @arg $1
  - @arg $1 after @arg $2

## 4. project documentation improvements

- update CompileCommand.md examples
- MAIN_FUNCTION_VAR_NAME add doc - more generally doc about facade template
- update whole README.md to comply with new directives and new templates
- register to <https://repology.org/projects/> in order to show matrix image
  <https://github.com/jirutka/esh/blob/master/README.adoc>

## 5. Miscellaneous

### 5.1. New binaries

- add githubUpgradeRelease based on Github::upgradeRelease
- Update vendor command
  - command that allows to update the libraries in the repo
  - github cron that checks if library updates exists

### 5.2. automatic help generation

- FACADE help auto generated
- IMPLEMENT special to manage options: --verbose, --version, --help, ...
- use this interface to generate man page
  <https://www.cyberciti.biz/faq/linux-unix-creating-a-manpage/>
- [asciidoctor](https://asciidoctor.org/) to build manpages ?

### 5.3. Binaries improvement

TODOs linked to `src/_binaries/*`:

- refact buildPushDockerImages.sh with Docker/functions... and using correct
  tagging
- parallelization (use xargs)
  - awkLint
  - shellcheckLint
  - doc generation

### 5.4. merge bash-tools into bash-tools-framework

- move bash-tools binaries to bash-tools-framework
- import bash_dev_env commands but keep this project separated

### 5.5. run precommit on github action

- add megalinter github action
  <https://github.com/marketplace/actions/megalinter>
- <https://github.com/pre-commit/action>

### 5.6. Improve UT

- ensure filters functions never fails (check bashFrameworkFunctions) and ensure
  filters functions are not used as Assert function

### 5.7. best practices

- what would be the impact to add shopt -s lastpipe
- use `builtin cd` instead of `cd`, `builtin pwd` instead of `pwd`, ... to avoid
  using customized aliased commands by the use => but unalias --all is used in
  header
- <https://dougrichardson.us/notes/fail-fast-bash-scripting.html>
  - add `set -u`
  - add this page comments to `BestPractices.md`
- check that every lowercase variable is used as local in functions
  - <https://github.com/bats-core/bats-core/issues/726>
  - <https://github.com/koalaman/shellcheck/issues/1395>
  - <https://github.com/koalaman/shellcheck/issues/468>
- [Apply defensive suggestions](https://docs.fedoraproject.org/en-US/defensive-coding/programming-languages/Shell/)

### 5.8. Other libraries integration

- integrate <https://github.com/adoyle-h/lobash> ?
- integrate <https://github.com/elibs/ebash> ?
