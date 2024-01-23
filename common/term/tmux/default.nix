{ config, pkgs, self, inputs, lib, ... }: {
  imports = [];
  options = {
    birdeeMods.tmux = with lib.types; {
      enable = lib.mkOption {
        default = false;
        type = bool;
        description = "enable birdee's tmux configuration";
      };
    };
  };
  config = lib.mkIf config.birdeeMods.tmux.enable (let
  in {
    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
    };
    home.sessionVariables = {
      TERM = "tmux-256color";
    };
  });
}
