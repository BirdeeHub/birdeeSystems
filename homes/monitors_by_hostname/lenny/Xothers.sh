if [[ $1 == "HDMI-0" ]]; then
    xrandr --output HDMI-0 --left-of DP-2 --preferred
fi
