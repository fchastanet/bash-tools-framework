#!/usr/bin/env bash

# @description activate or not Log::display* and Log::log* functions
# based on BASH_FRAMEWORK_DISPLAY_LEVEL and BASH_FRAMEWORK_LOG_LEVEL
# environment variables loaded by Env::requireLoad
# try to create log file and rotate it if necessary
# @noargs
# @set BASH_FRAMEWORK_LOG_LEVEL int to OFF level if BASH_FRAMEWORK_LOG_FILE is empty or not writable
# @env BASH_FRAMEWORK_DISPLAY_LEVEL int
# @env BASH_FRAMEWORK_LOG_LEVEL int
# @env BASH_FRAMEWORK_LOG_FILE String
# @env BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION int do log rotation if > 0
# @exitcode 0 always successful
# @stderr diagnostics information about log file is displayed
# @require Env::requireLoad
# @require UI::requireTheme
Log::requireLoad() {
  if [[ -z "${BASH_FRAMEWORK_LOG_FILE:-}" ]]; then
    BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_OFF}
    export BASH_FRAMEWORK_LOG_LEVEL
  fi

  if ((BASH_FRAMEWORK_LOG_LEVEL > __LEVEL_OFF)); then
    if [[ ! -f "${BASH_FRAMEWORK_LOG_FILE}" ]]; then
      if
        ! mkdir -p "$(dirname "${BASH_FRAMEWORK_LOG_FILE}")" 2>/dev/null ||
          ! touch --no-create "${BASH_FRAMEWORK_LOG_FILE}" 2>/dev/null
      then
        BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_OFF}
        echo -e "${__ERROR_COLOR}ERROR   - File ${BASH_FRAMEWORK_LOG_FILE} is not writable${__RESET_COLOR}" >&2
      fi
    elif [[ ! -w "${BASH_FRAMEWORK_LOG_FILE}" ]]; then
      BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_OFF}
      echo -e "${__ERROR_COLOR}ERROR   - File ${BASH_FRAMEWORK_LOG_FILE} is not writable${__RESET_COLOR}" >&2
    fi

  fi

  if ((BASH_FRAMEWORK_LOG_LEVEL > __LEVEL_OFF)); then
    # will always be created even if not in info level
    Log::logMessage "INFO" "Logging to file ${BASH_FRAMEWORK_LOG_FILE} - Log level ${BASH_FRAMEWORK_LOG_LEVEL}"
    if ((BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION > 0)); then
      Log::rotate "${BASH_FRAMEWORK_LOG_FILE}" "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}"
    fi
  fi
}
