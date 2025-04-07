#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	QTWEBENGINE_CHROMIUM_FLAGS="" python /usr/share/azuos/installer/setup.py
else
	QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox --no-sandbox" python /usr/share/azuos/installer/setup.py
fi
