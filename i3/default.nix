pkgs: {
  enable = true;
  package = pkgs.i3-gaps;
  configFile = builtins.toFile "config" (''
    set $i3barConfigFile ${builtins.toFile "i3bar" (builtins.readFile ./i3bar)}
  ''+builtins.readFile ./config + ''
  '');
  extraPackages = with pkgs; [
    (pkgs.writeScriptBin "monWkspcCycle.sh" (
    ''
      #!/usr/bin/env bash
    '' + (builtins.readFile ./monWkspcCycle.sh)))
    jq
    dmenu #application launcher most people use
    i3status # gives you the default i3 status bar
    # i3lock #default i3 screen locker
    pa_applet
    pavucontrol
    networkmanagerapplet
    dunst
    lxappearance
    # i3blocks #if you are planning on using i3blocks over i3status
  ];
}
