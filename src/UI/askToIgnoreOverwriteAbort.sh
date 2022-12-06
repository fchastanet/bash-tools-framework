#!/usr/bin/env bash
readonly __bash_framework__choice_ignore=0
readonly __bash_framework__choice_overwrite=1

# Public: ask the user to ignore(i), overwrite(o) or abort(a)
#
# **Input**: user input any characters
#
# **Output**:
# * displays message <pre>do you want to ignore(i), overwrite(o), abort(a) ?</pre>
# * if characters entered different than [iIoOaA] displays "Invalid answer" and continue to ask
#
# **Returns**:
# * 0 if i or I
# * 1 if o or O
# **Exit**:
# * 1 if a or A
UI::askToIgnoreOverwriteAbort() {
  while true; do
    read -p "do you want to ignore(i), overwrite(o), abort(a) ? " -n 1 -r
    echo # move to a new line
    case ${REPLY} in
      [iI]) return "${__bash_framework__choice_ignore}" ;;
      [oO]) return "${__bash_framework__choice_overwrite}" ;;
      [aA]) exit 1 ;;
      *)
        read -r -N 10000000 -t '0.01' || true # empty stdin in case of control characters
        # \\r to go back to the beginning of the line
        Log::displayError "\\r invalid answer                                                          "
        ;;
    esac
  done
  # we can't arrive here
}
