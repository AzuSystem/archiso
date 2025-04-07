#/bin/bash

feh --bg-scale '/usr/share/azuos-wallpapers/white concrete pillars on water.jpg'
cd /usr/share/azuos/dock
exec /usr/share/azuos/dock/azuos-dock &
cd /usr/share/azuos/desktop
# python /home/mt/Documents/azuos-desktop/desktop.py &
exec /usr/share/azuos/desktop/azuos-desktop &
exec kitty / &
picom &
openbox
