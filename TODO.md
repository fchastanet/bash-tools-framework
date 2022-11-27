# Todo

- generate github page from Readme.tmpl.md using github workflow
  - include bin help
  - include bash doc
- Update libraries command

  - command that allows to update the libraries in the repo
  - github cron that checks if library updates exists

- Refact
  - check all functions calls exists
  - ensure we don't have any globals, all variables should be passed to the
    functions
- add build.sh in precommit hook
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
