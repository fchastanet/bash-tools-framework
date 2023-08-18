#!/usr/bin/env bash

# @description Ask user to enter y or n, retry until answer is correct
# @arg $1 message:String message to display before asking
# @stdout displays message <pre>[msg arg $1] (y or n)?</pre>
# @stdout if characters entered different than [yYnN] displays "Invalid answer" and continue to ask
# @exitcode 0 if yes
# @exitcode 1 else
UI::askYesNo() {
  while true; do
    read -p "$1 (y or n)? " -n 1 -r
    echo # move to a new line
    case ${REPLY} in
      [yY]) return 0 ;;
      [nN]) return 1 ;;
      *)
        read -r -N 10000000 -t '0.01' || true # empty stdin in case of control characters
        # \\r to go back to the beginning of the line
        Log::displayError "\\r invalid answer                                                          "
        ;;
    esac
  done
}
