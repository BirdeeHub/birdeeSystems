{ moduleNamespace, homeManager, inputs, ... }:
{config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.alacritty;

  alakitty-toml = /*toml*/''
    # https://alacritty.org/config-alacritty.html
    # [env]
    # TERM = "xterm-256color"

    [terminal.shell]
    program = "${pkgs.zsh}/bin/zsh"
    args = [ "-l" ]

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

    ${cfg.extraToml}
  '';

in {
  _file = ./default.nix;
  options = {
    ${moduleNamespace}.alacritty = with lib.types; {
      enable = lib.mkEnableOption "alacritty";
      extraToml = lib.mkOption {
        default = "";
        type = str;
      };
    };
  };
  config = lib.mkIf cfg.enable (let
    newpkgs = import inputs.nixpkgsNV { inherit (pkgs) system overlays; };
    final-alakitty-toml = pkgs.writeText "alacritty.toml" alakitty-toml;
    alakitty = pkgs.writeShellScriptBin "alacritty" ''
      exec ${newpkgs.alacritty}/bin/alacritty --config-file ${final-alakitty-toml} "$@"
    '';
  in (if homeManager then {
    home.packages = [ alakitty ];
  } else {
    environment.systemPackages = [ alakitty ];
  }));
}
