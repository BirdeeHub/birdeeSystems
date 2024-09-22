isHomeModule: { config, pkgs, self, inputs, lib, ... }: {
  _file = ./default.nix;
  imports = [];
  options = {
    birdeeMods.tmux = with lib; {
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
    } // (if !isHomeModule then {
      withUtempter = mkIf (! isHomeModule) (mkOption {
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
  config = let
    cfg = config.birdeeMods.tmux;
  in lib.mkIf cfg.enable (let
    # tmuxBoolToStr = value: if value then "on" else "off";

    final_tmux = pkgs.tmux.override (prev: {
      term_string = cfg.term_string;
      secureSocket = cfg.secureSocket;
    });

    tx = pkgs.writeShellScriptBin "tx" (/*bash*/''
      if [[ $(${final_tmux}/bin/tmux list-sessions -F '#{?session_attached,1,0}' | grep -c '0') -ne 0 ]]; then
        selected_session=$(${final_tmux}/bin/tmux list-sessions -F '#{?session_attached,,#{session_name}}' | tr '\n' ' ' | awk '{print $1}')
        ${final_tmux}/bin/tmux new-session -At $selected_session
      else
        ${final_tmux}/bin/tmux new-session
      fi
    '');

  in (if isHomeModule then {
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
