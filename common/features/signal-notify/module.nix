{ inputs, moduleNamespace, ... }:
let
  name = "signal-notify";
in
{
  flake.wrappers.${name} = { pkgs, config, lib, wlib, ... }@top: {
    imports = [ wlib.modules.default wlib.modules.systemd ];
    package = pkgs.signal-cli;
    constructFiles.notifier = {
      relPath = "bin/signal-cli-notifier";
      builder = ''cp "$1" "$2" && chmod +x "$2"'';
      content = let
        nixInfo = {
          notify_send = "${pkgs.libnotify}/bin/notify-send";
          signal_desktop = "${pkgs.signal-desktop}/bin/signal-desktop";
          call_handler = lib.generators.mkLuaInline "dofile(${builtins.toJSON ./call.lua})";
          message_handler = lib.generators.mkLuaInline "dofile(${builtins.toJSON ./message.lua})";
          ringer_sound = "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/phone-incoming-call.oga";
          msg_sound = "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message.oga";
          signal_cli = config.wrapperPaths.placeholder;
        };
      in /*lua*/ ''
        #!${(pkgs.luajit.withPackages (lp: [ lp.luv lp.cjson lp.inspect ])).interpreter}
        package.preload.nixInfo = function() return ${lib.generators.toLua {} nixInfo} end
        dofile(${builtins.toJSON ./notifier.lua})
      '';
    };
    systemd.user.service.signal-notify = {
      Unit = {
        Description = "Signal CLI Message Notifications";
      };
      Service = {
        Type = "simple";
        ExecStart = config.constructFiles.notifier.path;
        Restart = "always";
        RestartSec = "3s";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    install.modules.nixos = lib.mkForce ({ pkgs, lib, config, ... }: let
      cfg = top.config.install.getWrapperConfig config;
    in {
      systemd.packages = [ cfg.wrapper ];
    });
    install.modules.homeManager = lib.mkForce ({ pkgs, lib, config, ... }: let
      cfg = top.config.install.getWrapperConfig config;
    in {
      systemd.user.packages = [ cfg.wrapper ];
      # this whole thing is replacing these 3 lines
      # because it opens 5 copies of electron
      # wrappers.i3.appendedConfig = ''
      #   exec --no-startup-id ${pkgs.signal-desktop}/bin/signal-desktop --start-in-tray &
      # '';
    });
  };
}
