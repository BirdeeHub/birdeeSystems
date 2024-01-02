{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.xserver.windowManager.i3.me;
  updateSessionEnvironmentScript = ''
    systemctl --user import-environment PATH DISPLAY XAUTHORITY DESKTOP_SESSION XDG_CONFIG_DIRS XDG_DATA_DIRS XDG_RUNTIME_DIR XDG_SESSION_ID DBUS_SESSION_BUS_ADDRESS || true
    dbus-update-activation-environment --systemd --all || true
  '';
in

{
  options.services.xserver.windowManager.i3.me = {
    enable = mkEnableOption (lib.mdDoc "i3 window manager");

    configFile = mkOption {
      default     = null;
      type        = with types; nullOr path;
      description = lib.mdDoc ''
        Path to the i3 configuration file.
        If left at the default value, $HOME/.i3/config will be used.
      '';
    };

    # TODO: figure out how to git well enough to upstream this
    configText = mkOption {
      default     = null;
      type        = with types; nullOr str;
      description = lib.mdDoc ''
        Text of the i3 configuration file.
        If left at the default value, configFile setting will be used.
      '';
    };

    updateSessionEnvironment = mkOption {
      default = true;
      type = types.bool;
      description = lib.mdDoc ''
        Whether to run dbus-update-activation-environment and systemctl import-environment before session start.
        Required for xdg portals to function properly.
      '';
    };

    extraSessionCommands = mkOption {
      default     = "";
      type        = types.lines;
      description = lib.mdDoc ''
        Shell commands executed just before i3 is started.
      '';
    };

    package = mkOption {
      type        = types.package;
      default     = pkgs.i3;
      defaultText = literalExpression "pkgs.i3";
      description = lib.mdDoc ''
        i3 package to use.
      '';
    };

    extraPackages = mkOption {
      type = with types; listOf package;
      default = with pkgs; [ dmenu i3status i3lock ];
      defaultText = literalExpression ''
        with pkgs; [
          dmenu
          i3status
          i3lock
        ]
      '';
      description = lib.mdDoc ''
        Extra packages to be installed system wide.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.xserver.windowManager.session = [{
      name  = "i3";
      start = let
        # TODO: figure out how to git well enough to upstream this
        configFile = if (cfg.configText == null) then "/etc/i3/config" else ''${pkgs.writeTextFile {
          name = "config";
          text = cfg.configText;
        }}'';
      in ''
        ${cfg.extraSessionCommands}

        ${lib.optionalString cfg.updateSessionEnvironment updateSessionEnvironmentScript}

        ${cfg.package}/bin/i3 ${optionalString (cfg.configFile != null || cfg.configText != null)
          "-c ${configFile}"
        } &
        waitPID=$!
      '';
    }];
    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;
    environment.etc."i3/config" = mkIf (cfg.configFile != null) {
      source = cfg.configFile;
    };
  };

  # imports = [
  #   (mkRemovedOptionModule [ "services" "xserver" "windowManager" "i3-gaps" "enable" ]
  #     "i3-gaps was merged into i3. Use services.xserver.windowManager.i3.enable instead.")
  # ];
}
