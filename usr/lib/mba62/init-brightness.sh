#!/bin/sh

# Set initial brightness

MBABL="/usr/bin/mbabl"

. /etc/default/mba62

if [ -x "${MBABL}" ]
then
	${MBABL} -d ${MBA62_INITIAL_DISPLAY_BRIGHTNESS} -k ${MBA62_INITIAL_KEYBOARD_BRIGHTNESS}
fi