#!/bin/sh

# Wrapper for running real init script (prevents LightDM from failing
# if mba62 package is removed)

MBA62INIT="/usr/lib/mba62/init-brightness.sh"
if [ -x "${MBA62INIT}" ]
then
	${MBA62INIT}
else
	exit 0
fi