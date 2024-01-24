isHomeModule:
{ config, pkgs, inputs, self, ... }: let
in (/*toml*/''
# https://alacritty.org/config-alacritty.html
# [env]
# TERM = "xterm-256color"

[font]
size = 11.0

[font.bold]
family = "FiraMono Nerd Font"
style = "Bold"

[font.bold_italic]
family = "FiraMono Nerd Font"
style = "Bold Italic"

[font.italic]
family = "FiraMono Nerd Font"
style = "Italic"

[font.normal]
family = "FiraMono Nerd Font"
style = "Regular"
'')
