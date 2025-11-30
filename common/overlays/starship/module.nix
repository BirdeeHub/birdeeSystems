{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:

let
  tomlFmt = pkgs.formats.toml { };
in
{
  imports = [ wlib.modules.default ];
  options = {
    settings = lib.mkOption {
      type = tomlFmt.type;
      default = { };
      description = "Starship configuration as a Nix attribute set. See https://starship.rs/config/";
      example = {
        add_newline = false;
        character = {
          success_symbol = "[>](bold green)";
          error_symbol = "[x](bold red)";
        };
        directory = {
          truncation_length = 3;
        };
      };
    };

    configFile = lib.mkOption {
      type = wlib.types.file pkgs;
      default.path = toString (tomlFmt.generate "starship.toml" config.settings);
      description = "The starship configuration file.";
    };
  };

  config = {
    package = lib.mkDefault pkgs.starship;
    env.STARSHIP_CONFIG = config.configFile.path;
    meta.platforms = lib.platforms.all;
  };
}
