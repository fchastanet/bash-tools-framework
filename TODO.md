# Todo

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
- <https://dougrichardson.us/notes/fail-fast-bash-scripting.html>
- <https://github.com/adoyle-h/lobash>
- <https://github.com/elibs/ebash>
- <https://github.com/pre-commit/action>
