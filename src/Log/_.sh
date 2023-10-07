#!/usr/bin/env bash
# @description Log namespace provides 2 kind of functions
# - Log::display* allows to display given message with
#   given display level
# - Log::log* allows to log given message with
#   given log level
# Log::display* functions automatically log the message too
# @see Env::requireLoad to load the display and log level from .env file

# @description log level off
export __LEVEL_OFF=0
# @description log level error
export __LEVEL_ERROR=1
# @description log level warning
export __LEVEL_WARNING=2
# @description log level info
export __LEVEL_INFO=3
# @description log level success
export __LEVEL_SUCCESS=3
# @description log level debug
export __LEVEL_DEBUG=4

# @description verbose level off
export __VERBOSE_LEVEL_OFF=0
# @description verbose level info
export __VERBOSE_LEVEL_INFO=1
# @description verbose level info
export __VERBOSE_LEVEL_DEBUG=2
# @description verbose level info
export __VERBOSE_LEVEL_TRACE=3
