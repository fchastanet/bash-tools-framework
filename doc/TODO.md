# Todo

- [1. coverage](#1-coverage)
- [2. Options/Args management](#2-optionsargs-management)
- [3. Env::load](#3-envload)
- [4. Framework Controller](#4-framework-controller)
- [5. REQUIRE directive](#5-require-directive)
  - [5.1. DISABLE directive](#51-disable-directive)
  - [5.2. refact env load using require ?](#52-refact-env-load-using-require-)
- [6. Framework functions changes](#6-framework-functions-changes)
- [7. Compiler and bash Object oriented](#7-compiler-and-bash-object-oriented)
  - [7.1. .framework-config should contain the compiler options](#71-framework-config-should-contain-the-compiler-options)
  - [7.2. compiler --profiler option](#72-compiler---profiler-option)
  - [7.3. FrameworkLint](#73-frameworklint)
- [8. project documentation improvements](#8-project-documentation-improvements)
- [9. Miscellaneous](#9-miscellaneous)
  - [9.1. New binaries](#91-new-binaries)
  - [9.2. automatic help generation](#92-automatic-help-generation)
  - [9.3. Binaries improvement](#93-binaries-improvement)
  - [9.4. merge bash-tools into bash-tools-framework](#94-merge-bash-tools-into-bash-tools-framework)
  - [9.5. run precommit on github action](#95-run-precommit-on-github-action)
  - [9.6. Improve UT](#96-improve-ut)
  - [9.7. best practices](#97-best-practices)
  - [9.8. Other libraries integration](#98-other-libraries-integration)

## 1. coverage

- coverage <https://github.com/bats-core/bats-core/issues/15>
  - bats has to be in PATH
  - kcov needs sudo apt install libdw-dev
  - from src dir
    - usr/local/bin/kcov --collect-only --exclude-path=/tmp $PWD/logs/coverage
      bats -r src/Options/generateCommand.bats -j 30
    - usr/local/bin/kcov --collect-only
      --include-path=$(pwd)/src --exclude-pattern=/testsData/ --exclude-path=/tmp --exclude-path=$PWD/vendor
      $PWD/logs/coverage bats -r src -j 30
    - coverage is in logs/coverage/bats/coverage.json
  - if some test has to be excluded
    - add `# bats test_tags=no-kcov` before the test
  - github <https://github.com/bats-core/bats-core/pull/718/files>
  - integrate with <https://coveralls.io/>
  - to integrate coverage of all files even those not tested, I should generate
    a bats file that source all the src files of the framework.

## 2. Options/Args management

- option/arg callback should be called when all options/args
  have been parsed
  - found issue with
      ./bin/megalinter --check-megalinter-version --image 'oxsecurity/megalinter-terraform:v7.5.0'
      not same result as
      ./bin/megalinter --image 'oxsecurity/megalinter-terraform:v7.5.0' --check-megalinter-version
  - or on megalinter we could use a command callback in this case
- support option String with equal sign
  - --format plain or --format=plain but -f plain or -fplain
- --help-item-name "srcDir" - underline srcDir in --help (see man xargs)
- special group for options --bash-framework-config and --config
- USAGE [OPTIONS] [GlobalOptions]
  - specific Usage [--options] if number of options under 3
  - then describe below each of them
  - check if alt used multiple times
  - order options not working
- Default template for option using run
- manage String|Function
- validatorCallback
  - option type File, would check if String after is a valid file
  - validatorHandler could assert path is valid
  - preProcessHandler could remove duplicates
  - postProcessHandler could remove the argument from arg list (default
    postProcessHandler ?)
- option type env --env OPTION=\*

## 3. Env::load

- should \_.sh files be loaded at header level ?
  - it would allow to load constants, even maybe rename it to \_header.sh
- add in FrameworkDoc.doc
  - default facade template
  - How to create your first binary file

## 4. Framework Controller

- Framework controller/listener
  - Facade becomes a controller with some actions
  - require becomes event listener
  - Event manager, I launch an event from a function
    - it actually add a line in a temp file
  - new directive controller
- With a router to redirect to the right controller function
- [Inspiration](https://symfony.com/doc/current/console.html)

- Framework lifecycle
  - send an event actionInit
  - manage init events
  - call controller manager with arg1
    - controller could send events
  - manage events
- if IMPLEMENT help => @require Args::requireHelpArg

## 5. REQUIRE directive

### 5.1. DISABLE directive

- define REQUIRE_DISABLED array in .framework-config
- Compiler::Requirement::parseDisable + add automatically to global variable
  REQUIRE_DISABLED
  - Warn if a requirement has no associated file using
    Compiler::findFunctionInSrcDirs
- compiler pass
  - will ignore the disabled requirements

### 5.2. refact env load using require ?

- test Env::load
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

## 6. Framework functions changes

- make Array::wrap cut on space
- remove all process substitution as it hides exit code > 0
- Conf::list findOptions as last arg so any number of args
- merge Framework::run and Command::captureOutputAndExitCode
  - replace Command::captureOutputAndExitCode with Framework::run that mimics
    bats run
- Linux::Wsl::cachedWslpathFromWslVar arg2 default value if variable not found
  - but no way to know if variable exists except by using `wslvar -S` or
    `wslvar -L`

## 7. Compiler and bash Object oriented

TODOs linked to bin/compiler or templates .tpl:

- since export have been removed from UI::theme some
  colors interpreted by bash-tpl are not visible anymore
  we have to export them only when launching bash-tpl in subshell.
- migrate to templating language supported by vscode
  - Mustache template <https://github.com/tests-always-included/mo>
- build watch mode
- issue with " or ', create a new string symbol in the template in order to get
  the right escape
  - try to use printf %q "$quote-me"
    <https://stackoverflow.com/a/39463371/3045926>
- review all exported variables
- auto import needed bash framework features like Options/\_\_all.sh without the
  need to source it into the compiler. It would mean to authorize bash-tpl
  template to be able to use bash framework functions automatically.
  <https://stackoverflow.com/a/60612372/3045926> using command not found
  handler.
- ADAPTER directive to allow to choose between multiple implementation depending
  on require conditions
- make compile options works with relative files
  - display info should display relative path too instead of full path
- rename TMPDIR to BASH_FRAMEWORK_TMP_DIR because as this variable overwritten
  and exported, it is used by called scripts
- refact from Profiles::lintDefinitions to
  Compiler::Implement::validateInterfaceFunctions
- use Filters::optimizeShFile using
  [shfmt --minify option](https://github.com/mvdan/sh/blob/master/cmd/shfmt/shfmt.1.scd#generic-flags)
- bash-tpl should be a vendor dependency

### 7.1. .framework-config should contain the compiler options

- .framework-config should contain the compiler options
  - compile should use FRAMEWORK_SRC_DIRS from .framework-config
- Remove FRAMEWORK_ROOT_DIR/FRAMEWORK_SRC_DIR requirements from binaries
  - replace it by optional argument automatically added --root-dir
  - list binaries that really need FRAMEWORK_ROOT_DIR
  - deduce FRAMEWORK_ROOT_DIR based on most near .framework-config file ?

### 7.2. compiler --profiler option

- compile add profiler option
  - if parameter --profiler is passed to compiler, then inject profiling of all
    bash framework function
  - add Framework::timeElapsed to display elapsed time of the command run
  - eg: ShellDoc::generateShellDocsFromDir
  - could compute time elapsed of subShell ?

### 7.3. FrameworkLint

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

## 8. project documentation improvements

- update CompileCommand.md examples
- MAIN_FUNCTION_VAR_NAME add doc - more generally doc about facade template
- update whole README.md to comply with new directives and new templates
- register to <https://repology.org/projects/> in order to show matrix image
  <https://github.com/jirutka/esh/blob/master/README.adoc>

## 9. Miscellaneous

### 9.1. New binaries

- add githubUpgradeRelease based on Github::upgradeRelease
- Update vendor command
  - command that allows to update the libraries in the repo
  - github cron that checks if library updates exists

### 9.2. automatic help generation

- FACADE help auto generated
- use this interface to generate man page
  <https://www.cyberciti.biz/faq/linux-unix-creating-a-manpage/>
- [asciidoctor](https://asciidoctor.org/) to build manpages ?

### 9.3. Binaries improvement

TODOs linked to `src/_binaries/*`:

- refact buildPushDockerImage.sh with Docker/functions... and using correct
  tagging
- parallelization (use xargs)
  - awkLint
  - shellcheckLint
    - --parallel uses GNU parallel
    - --xargs to use xargs
      - for checkstyle(xml) format
        - create a temp directory
        - redirect each process to a new temp file
        - use oq to merge xml files at the end
  - doc generation

### 9.4. merge bash-tools into bash-tools-framework

- move bash-tools binaries to bash-tools-framework
- import bash_dev_env commands but keep this project separated

### 9.5. run precommit on github action

- use github action docker cache
  - <https://github.com/moby/buildkit#github-actions-cache-experimental>
- add megalinter github action
  <https://github.com/marketplace/actions/megalinter>
- <https://github.com/pre-commit/action>

### 9.6. Improve UT

- ensure filters functions never fails (check bashFrameworkFunctions) and ensure
  filters functions are not used as Assert function

### 9.7. best practices

- use printf
  <https://github.com/anordal/shellharden/blob/master/how_to_do_things_safely_in_bash.md#echo--printf>
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

### 9.8. Other libraries integration

- integrate <https://github.com/adoyle-h/lobash> ?
- integrate <https://github.com/elibs/ebash> ?
