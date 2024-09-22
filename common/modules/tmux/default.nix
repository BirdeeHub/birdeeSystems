{ moduleNamespace, homeManager, inputs, ... }:
{ config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.tmux;
in {
  _file = ./default.nix;
  imports = [];
  options = {
    ${moduleNamespace}.tmux = with lib; {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "enable birdee's tmux configuration";
      };
      term_string = mkOption {
        default = "alacritty";
        type = types.str;
        description = "TERM";
      };
      secureSocket = mkOption {
        default = pkgs.stdenv.isLinux;
        type = types.bool;
        description = ''
          Store tmux socket under {file}`/run`, which is more
          secure than {file}`/tmp`, but as a downside it doesn't
          survive user logout.
        '';
      };
    } // (if !homeManager then {
      withUtempter = mkIf (! homeManager) (mkOption {
        description = mdDoc ''
          Whether to enable libutempter for tmux.
          This is required so that tmux can write to /var/run/utmp (which can be queried with `who` to display currently connected user sessions).
          Note, this will add a guid wrapper for the group utmp!
        '';
        default = true;
        type = types.bool;
      });
    } else {});
  };
  config = lib.mkIf cfg.enable (let
    # tmuxBoolToStr = value: if value then "on" else "off";

    # relies on the tmux overlay being present
    final_tmux = pkgs.tmux.override {
      term_string = cfg.term_string;
      secureSocket = cfg.secureSocket;
    };

    tx = pkgs.writeShellScriptBin "tx" /*bash*/''
      if [[ $(${final_tmux}/bin/tmux list-sessions -F '#{?session_attached,1,0}' | grep -c '0') -ne 0 ]]; then
        selected_session=$(${final_tmux}/bin/tmux list-sessions -F '#{?session_attached,,#{session_name}}' | tr '\n' ' ' | awk '{print $1}')
        ${final_tmux}/bin/tmux new-session -At $selected_session
      else
        ${final_tmux}/bin/tmux new-session
      fi
    '';

  in (if homeManager then {
    home.packages = [
      tx
      final_tmux
    ];
  } else {
    environment = {
      systemPackages = [
        tx
        final_tmux
      ];
    };
    security.wrappers = lib.mkIf cfg.withUtempter {
      utempter = {
        source = "${pkgs.libutempter}/lib/utempter/utempter";
        owner = "root";
        group = "utmp";
        setuid = false;
        setgid = true;
      };
    };
  }));
}
