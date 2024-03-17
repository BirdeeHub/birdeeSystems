isHomeModule:
{config, pkgs, self, inputs, lib, ... }@args: let

  alakitty-toml = isHomeModule: { config, pkgs, inputs, self, lib, ... }: let
  in (/*toml*/''
    # https://alacritty.org/config-alacritty.html
    # [env]
    # TERM = "xterm-256color"

    [shell]
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
  '');

in {
  options = {
    birdeeMods.alacritty = with lib.types; {
      enable = lib.mkEnableOption "alacritty";
      extraToml = lib.mkOption {
        default = "";
        type = str;
      };
    };
  };
  config = lib.mkIf config.birdeeMods.alacritty.enable (let
    cfg = config.birdeeMods.alacritty;
    final-alakitty-toml = pkgs.writeText "alacritty.toml" (builtins.concatStringsSep "\n" [
      (alakitty-toml isHomeModule args)
      cfg.extraToml
      ]);
    alakitty = pkgs.writeShellScriptBin "alacritty" ''
      exec ${pkgs.alacritty}/bin/alacritty --config-file ${final-alakitty-toml} "$@"
    '';
  in (if isHomeModule then {
    home.packages = [ alakitty ];
  } else {
    environment.systemPackages = [ alakitty ];
  }));
}
