# Todo

- [1. Improve UT](#1-improve-ut)
- [2. merge bash-tools into bash-tools-framework](#2-merge-bash-tools-into-bash-tools-framework)
- [3. Framework functions changes](#3-framework-functions-changes)
- [4. Update Bash-tools-framework dependencies](#4-update-bash-tools-framework-dependencies)
- [5. Compiler and bash Object oriented](#5-compiler-and-bash-object-oriented)
  - [REQUIRE directive](#require-directive)
  - [5.2. FrameworkLint](#52-frameworklint)
- [6. Binaries](#6-binaries)
  - [New binaries](#new-binaries)
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
  - <https://github.com/bats-core/bats-core/issues/726>
  - <https://github.com/koalaman/shellcheck/issues/1395>
  - <https://github.com/koalaman/shellcheck/issues/468>
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

## 2. merge bash-tools into bash-tools-framework

- move bash-tools binaries to bash-tools-framework
- import bash_dev_env commands but keep this project separated

## 3. Framework functions changes

- remove all process substitution as it hides exit code > 0
- log use alias
- logMessage do nothing if Log::load has been called, no need to check logLevel
  if Log::load do correctly its job
- check if we could use alias to override methods to be able to reload or pass
  by temp functions?
- replace \_colors.sh with Log/theme
- merge Framework::run and Command::captureOutputAndExitCode
- Conf::list findOptions as last arg so any number of args
- replace Command::captureOutputAndExitCode with Framework::run that mimics bats
  run
- add Framework::timeElapsed to display elapsed time of the command run
  - eg: ShellDoc::generateShellDocsFromDir
  - could compute time elapsed of subShell ?

## 4. Update Bash-tools-framework dependencies

- make \_commonHeader.sh be loaded sooner (should include unalias -a || true)
- Remove FRAMEWORK_ROOT_DIR/FRAMEWORK_SRC_DIR requirements from binaries
  - replace it by optional argument automatically added --root-dir
  - other default options to the binaries, log-level, display-log-level, ...
  - add options to `src/_includes/_headerNoRootDir.tpl`

## 5. Compiler and bash Object oriented

TODOs linked to bin/compiler:

- FACADE help auto generated
- what would be the impact to add shopt -s lastpipe
- new IMPLEMENT directive
  - [detect that file is being sourced](https://stackoverflow.com/a/47613477)
  - implement main security in tpl, the binary script has just to implement a
    main function
- IMPLEMENT directive
- add main function
- arg configuration: display whole bash framework configuration
- deduce FRAMEWORK_ROOT_DIR based on most near .framework-config file ?
- .framework-config should contain the compiler options
- make compile options works with relative files
  - display info should display relative path too instead of full path
  - update CompileCommand.md examples
- extract from Profiles::lintDefinitions to Class::isInterfaceImplemented
  - Profiles::lintDefinitions can be changed to provide a dynamic list of method
    names
  - define a sh format able to describe an interface
    - installScripts_Install1_helpDescription should be named
      installScripts_Install1.helpDescription
      - installScripts_Install1 is the object, on which we call helpDescription
        method
    - or could we use file for implementing an object
      - then call function of the class with this instance
        - installScripts_helpDescription $instanceFile
          - source the file and display help
  - would it be possible to implement inheritance ?
- compile should use FRAMEWORK_SRC_DIRS from .framework-config
- use Filters::optimizeShFile
  - using
    [shfmt --minify option](https://github.com/mvdan/sh/blob/master/cmd/shfmt/shfmt.1.scd#generic-flags)
- check if nested namespaces are supported
- get rid of `__all.sh` files, useless because of compiler auto include
- [Apply defensive suggestions](https://docs.fedoraproject.org/en-US/defensive-coding/programming-languages/Shell/)

### REQUIRE directive

- move Embed to Compiler namespace
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

### 5.2. FrameworkLint

- check no use of ${TMPDIR} without default value
- check if 2 files have the same BINARY_FILE target
- refact `src/_binaries/frameworkLint.sh` formatter for plain or checkstyle
- if sudo called on Backup::file without using EMBED
- if EMBED is used but the binary is not used
- ensure BIN_FILE is provided
- EMBED include one file, rest of the script is as usual
  - function allow to unzip the file
- EMBED "as" names should be unique + some forbidden names (existing bash
  functions)

## 6. Binaries

### New binaries

- add githubUpgradeRelease based on Github::upgradeRelease

### 6.1. BashDoc

- update bashDoc and include it inside bash-tools-framework
- generates automatically bash framework functions dependencies recursively
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
    - 2 @arg $1
    - @arg $1 after @arg $2

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
- Linux::Wsl::cachedWslpathFromWslVar arg2 default value if variable not found
  - but no way to know if variable exists except by using `wslvar -S` or
    `wslvar -L`

### 8.1. Robustness

- <https://dougrichardson.us/notes/fail-fast-bash-scripting.html>
  - add `shopt -s inherit_errexit`
  - add `set -u`
  - add this page comments to `BestPractices.md`
