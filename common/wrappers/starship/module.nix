{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:
# If shell is null, the default, it wont be a sourceable script
# It will be like the normal starship command, which returns a string to source yourself.

# If shell is not null, produces a SOURCEABLE file
# which exports STARSHIP_CONFIG and then evals the prompt command
# This is because remembering which way to source it for which shell is obnoxious
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
      type = lib.types.nullOr (lib.types.enum [ "bash" "zsh" "fish" "nu" ]);
      default = null;
      description = ''
        If null, this module just wraps starship with config,
        user must source the output of the command in their shell.

        However, for some languages this wrapper is capable of outputting a sourceable script.

        If you set this option, you can instead source $out/bin/starship directly.

        bash && zsh: `. ''${this}/bin/''${this.meta.mainProgram}`
        fish: `source ''${this}/bin/''${this.meta.mainProgram}`
        nu: `include ''${this}/bin/''${this.meta.mainProgram}`
      '';
    };

    configFile = lib.mkOption {
      type = wlib.types.file pkgs;
      default.path = tomlFmt.generate "starship.toml" config.settings;
      description = "The starship configuration file. By default, this is generated from `config.settings`";
    };
  };

  config = {
    addFlag = lib.mkIf (config.shell != null) [
      {
        name = "GENERATED_INIT_FLAG";
        data = [ "init" config.shell "--print-full-init" ];
      }
    ];
    argv0type = lib.mkIf (config.shell == "bash") (s: ''eval "$(${s})"'');
    drv.buildPhase = lib.mkIf (config.shell != null && config.shell != "bash") (/* bash */ ''
      mv $out/bin/${config.binName} $out/bin/.OG-${config.binName}
    '' + (if config.shell == "fish" then /* bash */ ''
      echo "$out/bin/.OG-${config.binName} | source" > "$out/bin/${config.binName}"
    '' else if config.shell == "zsh" then /* bash */ ''
      echo "eval \"\$($out/bin/.OG-${config.binName})\"" > "$out/bin/${config.binName}"
    '' else if config.shell == "nu" then /* bash */ ''
      echo 'mkdir ($nu.data-dir | path join "vendor/autoload")' > "$out/bin/${config.binName}"
      echo "$out/bin/.OG-${config.binName} | save -f ($nu.data-dir | path join \"vendor/autoload/starship.nu\")" >> "$out/bin/${config.binName}"
    '' else throw "language unsupported by this module"));
    package = lib.mkDefault pkgs.starship;
    runShell = lib.mkIf (config.shell != null && config.shell != "bash") [ (if config.shell == "nu" then "echo ${lib.escapeShellArg ''$env.STARSHIP_CONFIG = ${wlib.escapeShellArgWithEnv config.configFile.path}''}" else if config.shell == "fish" then "echo ${lib.escapeShellArg ''set -x STARSHIP_CONFIG ${wlib.escapeShellArgWithEnv config.configFile.path}''}" else "echo ${lib.escapeShellArg "export ${wlib.escapeShellArgWithEnv "STARSHIP_CONFIG=${config.configFile.path}"}"}") ];
    env.STARSHIP_CONFIG = {
      data = config.configFile.path;
      esc-fn = wlib.escapeShellArgWithEnv;
    };
    meta.platforms = lib.platforms.all;
  };
}
