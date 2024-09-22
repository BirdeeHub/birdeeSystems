# will be ran once on each monitor plugged back in
# will be passed the name of the display.
if [[ $1 == "HDMI-1" ]]; then
    xrandr --output HDMI-1 --left-of eDP-1 --preferred
fi
if [[ $1 == "DP-1" ]]; then
    xrandr --output DP-1 --left-of LVDS-2
fi
