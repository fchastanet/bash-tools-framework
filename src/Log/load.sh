#!/usr/bin/env bash
# shellcheck disable=SC2317

# @description activate or not Log::display* and Log::log* functions
# based on BASH_FRAMEWORK_DISPLAY_LEVEL and BASH_FRAMEWORK_LOG_LEVEL
# environment variables
# try to create log file and rotate it if necessary
# @noargs
# @set BASH_FRAMEWORK_LOG_LEVEL int to OFF level if BASH_FRAMEWORK_LOG_FILE is empty or not writable
# @env BASH_FRAMEWORK_DISPLAY_LEVEL int
# @env BASH_FRAMEWORK_LOG_LEVEL int
# @env BASH_FRAMEWORK_LOG_FILE String
# @env BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION int do log rotation if > 0
# @exitcode 0 always successful
# @stderr diagnostics information about log file is displayed
Log::load() {
  # disable display methods following display level
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL < __LEVEL_DEBUG)); then
    Log::displayDebug() { :; }
  fi
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL < __LEVEL_INFO)); then
    Log::displayHelp() { :; }
    Log::displayInfo() { :; }
    Log::displaySkipped() { :; }
    Log::displaySuccess() { :; }
  fi
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL < __LEVEL_WARNING)); then
    Log::displayWarning() { :; }
    Log::displayStatus() { :; }
  fi
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL < __LEVEL_ERROR)); then
    Log::displayError() { :; }
  fi
  # disable log methods following log level
  if ((BASH_FRAMEWORK_LOG_LEVEL < __LEVEL_DEBUG)); then
    Log::logDebug() { :; }
  fi
  if ((BASH_FRAMEWORK_LOG_LEVEL < __LEVEL_INFO)); then
    Log::logHelp() { :; }
    Log::logInfo() { :; }
    Log::logSkipped() { :; }
    Log::logSuccess() { :; }
  fi
  if ((BASH_FRAMEWORK_LOG_LEVEL < __LEVEL_WARNING)); then
    Log::logWarning() { :; }
    Log::logStatus() { :; }
  fi
  if ((BASH_FRAMEWORK_LOG_LEVEL < __LEVEL_ERROR)); then
    Log::logError() { :; }
  fi

  if ((BASH_FRAMEWORK_LOG_LEVEL > __LEVEL_OFF)); then
    if [[ -z "${BASH_FRAMEWORK_LOG_FILE}" ]]; then
      BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_OFF}
      export BASH_FRAMEWORK_LOG_LEVEL
    elif [[ ! -f "${BASH_FRAMEWORK_LOG_FILE}" ]]; then
      if ! mkdir -p "$(dirname "${BASH_FRAMEWORK_LOG_FILE}")" 2>/dev/null; then
        BASH_FRAMEWORK_LOG_LEVEL=__LEVEL_OFF
        Log::displayWarning "Log dir cannot be created $(dirname "${BASH_FRAMEWORK_LOG_FILE}")"
      fi
      if ! touch --no-create "${BASH_FRAMEWORK_LOG_FILE}" 2>/dev/null; then
        BASH_FRAMEWORK_LOG_LEVEL=__LEVEL_OFF
        Log::displayWarning "Log file '${BASH_FRAMEWORK_LOG_FILE}' cannot be created"
      fi
    fi
    Log::displayInfo "Logging to file ${BASH_FRAMEWORK_LOG_FILE}"
    if ((BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION > 0)); then
      Log::rotate "${BASH_FRAMEWORK_LOG_FILE}" "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}"
    fi
  fi
}
