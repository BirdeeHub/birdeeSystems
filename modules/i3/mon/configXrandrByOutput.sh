if [[ $1 == "HDMI-1" ]]; then
    # $xrandr --newmode "1920x1080_custom" 130.18 1920 2008 2052 2200 1080 1084 1089 1125 +hsync +vsync
    # $xrandr --addmode HDMI-1 "1920x1080_custom"
    # $xrandr --output HDMI-1 --left-of eDP-1 --mode "1920x1080_custom"
    # $xrandr --output HDMI-1 --left-of eDP-1 --mode "1920x1080" --rate 59.50
    $xrandr --output HDMI-1 --left-of eDP-1 --preferred
fi
