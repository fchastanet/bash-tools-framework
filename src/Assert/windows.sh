#!/usr/bin/env bash

# @description determine if the script is executed under windows
# cspell:disable
# <pre>
# uname GitBash windows (with wsl) => MINGW64_NT-10.0 ZOXFL-6619QN2 2.10.0(0.325/5/3) 2018-06-13 23:34 x86_64 Msys
# uname GitBash windows (wo wsl)   => MINGW64_NT-10.0 frsa02-j5cbkc2 2.9.0(0.318/5/3) 2018-01-12 23:37 x86_64 Msys
# uname wsl => Linux ZOXFL-6619QN2 4.4.0-17134-Microsoft #112-Microsoft Thu Jun 07 22:57:00 PST 2018 x86_64 x86_64 x86_64 GNU/Linux
# </pre>
# cspell:enable
#
# @exitcode 1 on error
Assert::windows() {
  if [[ "$(uname -o)" = "Msys" ]]; then
    return 0
  else
    return 1
  fi
}
