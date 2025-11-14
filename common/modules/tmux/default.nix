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
        default = "xterm-256color"; # "alacritty";
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
      withUtempter = mkOption {
        description = mdDoc ''
          Whether to enable libutempter for tmux.
          This is required so that tmux can write to /var/run/utmp (which can be queried with `who` to display currently connected user sessions).
          Note, this will add a guid wrapper for the group utmp!
        '';
        default = true;
        type = types.bool;
      };
    } else {});
  };
  config = lib.mkIf cfg.enable (let
    final_tmux = inputs.wezterm_bundle.packages.${pkgs.system}.tmux.wrap {
      terminal = cfg.term_string;
      secureSocket = cfg.secureSocket;
    };
  in (if homeManager then {
    home.packages = [
      final_tmux
    ];
  } else {
    environment = {
      systemPackages = [
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
