# TODO: weston wrapper module
{ inputs, ... }:
{
  flake.wrappers.weston =
    {
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    {
      imports = [ ./weston.nix ];
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
          num-workspaces = 10;
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

        launcher = [
          {
            path = "${inputs.self.wrappers.wezterm.wrap { inherit pkgs; withLauncher = true; }}";
          }
        ];
      };
    };
}
