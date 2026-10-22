{ inputs, moduleNamespace, ... }:
let
  name = "REPLACE_ME";
in
{
  flake.wrappers.${name} = { pkgs, config, lib, wlib, ... }@top: {
    imports = [ wlib.modules.default ];
    install.modules.nixos = { pkgs, lib, config, ... }: let
      cfg = top.config.install.getWrapperConfig config;
    in {
    };
    install.modules.homeManager = { pkgs, lib, config, ... }: let
      cfg = top.config.install.getWrapperConfig config;
    in {
    };
  };
  flake.modules.nixos.${name} = { pkgs, config, lib, ... }: let
    cfg = config.${moduleNamespace}.${name};
  in {
    options.${moduleNamespace}.${name} = {
      enable = lib.mkEnableOption name;
    };
    config = lib.mkIf cfg.enable {
    };
  };
  flake.modules.homeManager.${name} = { pkgs, config, lib, ... }: let
    cfg = config.${moduleNamespace}.${name};
  in {
    options.${moduleNamespace}.${name} = {
      enable = lib.mkEnableOption name;
    };
    config = lib.mkIf cfg.enable {
    };
  };
}
