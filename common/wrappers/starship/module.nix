{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:
# Produces a SOURCEABLE script which exports STARSHIP_CONFIG and then evals the prompt command
# This is because remembering which way to source it for which shell is obnoxious

# If shell is null, the default, it wont be a sourceable script
# It will be like the normal starship command, which returns a string to source yourself.
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

    shell = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "bash" "zsh" "fish" ]);
      default = null;
      description = "Target shell this will be sourced in";
    };

    configFile = lib.mkOption {
      type = wlib.types.file pkgs;
      default.path = tomlFmt.generate "starship.toml" config.settings;
      description = "The starship configuration file.";
    };
  };

  config = {
    addFlag = lib.mkIf (config.shell != null) [ [ "init" config.shell ] ];
    argv0type = lib.mkIf (config.shell != null) (
      if config.shell == "fish" then
        s: s + " | source"
      else
        s: ''eval "$(${s})"''
    );
    package = lib.mkDefault pkgs.starship;
    env.STARSHIP_CONFIG = config.configFile.path;
    meta.platforms = lib.platforms.all;
  };
}
