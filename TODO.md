# Todo

- add UT
- update bashDoc
- add Framework::timeElapsed to display elapsed time of the command run
  - eg: ShellDoc::generateShellDocsFromDir
  - could compute time elapsed of subShell ?
- refact buildPushDockerImages.sh with Docker/functions... and using correct
  tagging
  - update test consequently
- add <https://github.com/fchastanet/bash-tools-framework> in help of each
  command
- awkLint/shellcheckLint use xargs
- workflow
  - register to <https://repology.org/projects/> in order to show matrix image
    <https://github.com/jirutka/esh/blob/master/README.adoc>
- ability to override env variable using OVERRIDE\_\*
- test Env::load
  - Env::load with invalid .env file => should display a warning message
  - Env::load with missing .env file => fatal
  - Env::load twice do not source again the files
  - Env::load with 1 env file as parameter
  - Env::load with overriding BASH_FRAMEWORK_INITIALIZED="0"
  - Env::load with overriding BASH_FRAMEWORK_INITIALIZED="0"
    BASH_FRAMEWORK_ENV_FILEPATH="${ROOT_DIR}/.env"
  - Env::load with BASH_FRAMEWORK_ENV_FILEPATH
- do I add Env::load to \_header.tpl ?
  - no but load tests/data/.env by default ? using var
    BASH_FRAMEWORK_DEFAULT_ENV_FILE ?
- compile exit 1 if at least 1 warning
  - error if bash-tpl template not found
    - File not found: '/dbQueryAllDatabases.awk'
  - manage whitelist or add comment ignore
    - File
      /home/wsl/projects/bash-tools/vendor/bash-tools-framework/src/Acquire/ForceIPv4.sh
      does not exist
- new function Env::get "HOME"

  - eg: Env::get "HOME" will get HOME variable from .env file if exists or get
    global HOME variable
  - replace all ${HOME} by $(Env::get "HOME")
  - generate automatically .env.template from Env::get
  - variables can be overridden by env variables using OVERRIDE_VARIABLE_NAME

- generate github page from Readme.tmpl.md using github workflow
  - include bin help
  - include bash doc
- install.sh will get last version of build tools from bash-tools
- Update libraries command

  - command that allows to update the libraries in the repo
  - github cron that checks if library updates exists

- doc.sh, linters and other build tools will be defined in bash-tools
- support nested namespace
- import bash-tools commands + libs
- import ck_ip_dev_env commands
- add megalinter github action
  <https://github.com/marketplace/actions/megalinter>
- <https://github.com/adoyle-h/lobash>
- <https://github.com/elibs/ebash>
- <https://github.com/pre-commit/action>

## Big Features/Studies

- generate automatically the \_\_all.sh file

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

- Framework linter

  - check if all function namespace::function are existing in the framework
  - check that function defined in a .sh and used outside is correctly named
  - check all functions calls exists
  - do we really need it ? yes if confirmed when bug related is found

- generate options parsing + doc from template

  - <https://github.com/ko1nksm/getoptions>
  - <https://github.com/matejak/argbash>

- migrate bash-tpl to <https://github.com/jirutka/esh/blob/master/esh.1.adoc>

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

## Best practices

- local or declare multiple local a z
- shift each arg to avoid not shifting at all
- declare all variables as local in functions to avoid making them global
- export readonly does not work, first readonly then export
- <https://dougrichardson.us/notes/fail-fast-bash-scripting.html> but set -o
  nounset is not usable because empty array are considered unset
- ${PARAMETER:-WORD} ${PARAMETER-WORD} If the parameter PARAMETER is unset
  (never was defined) or null (empty), this one expands to WORD, otherwise it
  expands to the value of PARAMETER, as if it just was ${PARAMETER}. If you omit
  the : (colon), like shown in the second form, the default value is only used
  when the parameter was unset, not when it was empty.
- always use sed -E
- cat << 'EOF' avoid to interpolate variables
- ensure we don't have any globals, all variables should be passed to the
  functions
- avoid using grep -P as it is not supported on alpine, prefer using -E
