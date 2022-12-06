#!/usr/bin/env bash

# Ask user to enter y or n, retry until answer is correct
# @param {String} $1 message to display before asking
# @output displays message <pre>[msg arg $1] (y or n)?</pre>
# @output if characters entered different than [yYnN] displays "Invalid answer" and continue to ask
# @return 0 if yes, 1 else
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
