#!/usr/bin/env bash
# @description Log namespace provides 2 kind of functions
# - Log::display* allows to display given message with
#   given display level
# - Log::log* allows to log given message with
#   given log level
# Log::display* functions automatically log the message too
# @see Log::load to load the display and log level from .env file

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

export __LEVEL_OFF
export __LEVEL_ERROR
export __LEVEL_WARNING
export __LEVEL_INFO
export __LEVEL_SUCCESS
export __LEVEL_DEBUG
