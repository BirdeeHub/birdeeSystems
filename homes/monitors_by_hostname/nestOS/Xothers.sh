if [[ $1 == "HDMI-1-1" ]]; then
    xrandr --output HDMI-1-1 --left-of eDP-2 --preferred
fi
