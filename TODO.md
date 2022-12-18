# Todo

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
- Framework linter
  - check if all function namespace::function are existing in the framework
  - check that function defined in a .sh and used outside is correctly named
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
  - variables can be overridden by env variables using OVERRIDE_VARIABLE_NAME
- refact Log::loadEnv
  - just load variables with fallback
  - then in each log file vendor/bash-tools-framework/src/Log/displayInfo.sh
    - if ((BASH_FRAMEWORK_LOG_LEVEL >= \_\_LEVEL_INFO)); then define function
      else define function empty fi
- Bash-tools-framework contains framework and common code

- generate github page from Readme.tmpl.md using github workflow
  - include bin help
  - include bash doc
- install.sh will get last version of build tools from bash-tools
- cat << EOF avoid to interpolate variables
- Update libraries command

  - command that allows to update the libraries in the repo
  - github cron that checks if library updates exists

- Refact
  - check all functions calls exists
  - ensure we don't have any globals, all variables should be passed to the
    functions
- add build.sh in precommit hook
- doc.sh, linters and other build tools will be defined in bash-tools
- linter that checks if namespace::function exist in lib directory
- support nested namespace
- import bash-tools commands + libs
- import ck_ip_dev_env commands
- fix github actions scripts
- add megalinter <https://github.com/marketplace/actions/megalinter>
- new function Env::get "HOME"
  - eg: Env::get "HOME" will get HOME variable from .env file if exists or get
    global HOME variable
  - replace all ${HOME} by $(Env::get "HOME")
  - generate automatically .env.template from Env::get
- <https://github.com/adoyle-h/lobash>
- <https://github.com/elibs/ebash>
- <https://github.com/pre-commit/action>

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
