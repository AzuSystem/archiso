#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	QTWEBENGINE_CHROMIUM_FLAGS="" python /azuos/index.py
else
	QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox --no-sandbox" python /azuos/index.py
fi
