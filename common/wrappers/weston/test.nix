{
  settings = {
    core = {
      xwayland = true;
    };

    libinput = {
      enable-tap = true;
    };

    shell = {
      background-type = "scale-crop";
      background-color = "0xff000000";
      panel-color = "0x00ffffff";
      panel-position = "bottom";
      close-animation = "none";
      focus-animation = "dim-layer";
      num-workspaces = 6;
      locking = false;
      cursor-theme = "Adwaita";
      cursor-size = 24;
    };

    output = {
      name = "LVDS1";
      mode = "preferred";
    };

    keyboard = {
      keymap_rules = "evdev";
      repeat-rate = 30;
      repeat-delay = 300;
    };

    terminal = {
      font = "monospace";
      font-size = 18;
    };
  };

  launchers = [
    {
      icon = "/usr/share/weston/icon_flower.png";
      path = "/usr/bin/weston-flower";
    }
    {
      icon = "/usr/share/icons/gnome/32x32/apps/utilities-terminal.png";
      path = "/usr/bin/weston-terminal --shell=/usr/bin/bash";
    }
    {
      icon = "/usr/share/icons/hicolor/32x32/apps/firefox.png";
      path = "MOZ_ENABLE_WAYLAND=1 /usr/bin/firefox";
    }
  ];
}
