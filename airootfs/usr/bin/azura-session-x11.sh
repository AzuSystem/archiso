#!/bin/bash

export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=Darkly

kwalletd6 &

feh --bg-scale '/usr/share/azuos-wallpapers/white concrete pillars on water.jpg'

cd /usr/share/azuos/dock

/usr/share/azuos/dock/azura-dock &
cd /usr/share/azuos/desktop
# python /home/mt/Documents/azuos-desktop/desktop.py &
/usr/share/azuos/desktop/azura_desktop &

kitty / &
picom &
openbox
