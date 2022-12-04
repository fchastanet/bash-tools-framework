#!/usr/bin/env bash

# TODO use alias deactivated by default
# TODO Log:displayXXX should call log::_logMessage too
Log:loadEnv() {
  Log::fatal() {
    __displayFatal "$@"
    exit 1
  }

  Log::logError() { :; }
  Log::logWarning() { :; }
  Log::logInfo() { :; }
  Log::logSuccess() { :; }
  Log::logDebug() { :; }

  Log::displayError() { :; }
  Log::displayWarning() { :; }
  Log::displayInfo() { :; }
  Log::displaySuccess() { :; }
  Log::displayDebug() { :; }

  BASH_FRAMEWORK_LOG_LEVEL=${BASH_FRAMEWORK_LOG_LEVEL:-${__LEVEL_OFF}}
  if ((BASH_FRAMEWORK_LOG_LEVEL > __LEVEL_OFF)); then
    if [[ -z "${BASH_FRAMEWORK_LOG_FILE}" ]]; then
      BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_OFF}
    else
      if ! mkdir -p "$(dirname "${BASH_FRAMEWORK_LOG_FILE}")" 2>/dev/null; then
        # TODO use _logMessage to be sure to display the message during env lading
        Log::displayError "Log file directory '$(dirname "${BASH_FRAMEWORK_LOG_FILE}")' cannot be created"
        BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_OFF}
      elif ! touch --no-create "${BASH_FRAMEWORK_LOG_FILE}" 2>/dev/null; then
        Log::displayError "Log file ${BASH_FRAMEWORK_LOG_FILE} is not writable"
        BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_OFF}
      fi
    fi
    if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_ERROR)); then
      Log::logError() { __logMessage "ERROR  " "$@"; }
    fi
    if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_WARNING)); then
      Log::logWarning() { __logMessage "WARNING" "$@"; }
    fi
    if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_INFO)); then
      Log::logInfo() { __logMessage "INFO   " "$@"; }
    fi
    if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_SUCCESS)); then
      Log::logSuccess() { __logMessage "SUCCESS" "$@"; }
    fi
    if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_DEBUG)); then
      Log::logDebug() { __logMessage "DEBUG  " "$@"; }
    fi
  fi

  BASH_FRAMEWORK_DISPLAY_LEVEL=${BASH_FRAMEWORK_DISPLAY_LEVEL:-${__LEVEL_OFF}}
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL > __LEVEL_OFF)); then
    if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_ERROR)); then
      Log::displayError() { __displayError "$@"; }
    fi
    if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_WARNING)); then
      Log::displayWarning() { __displayWarning "$@"; }
    fi
    if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_INFO)); then
      Log::displayInfo() { __displayInfo "$@"; }
    fi
    if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_SUCCESS)); then
      Log::displaySuccess() { __displaySuccess "$@"; }
    fi
    if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_DEBUG)); then
      Log::displayDebug() { __displayDebug "$@"; }
    fi
  fi
}
