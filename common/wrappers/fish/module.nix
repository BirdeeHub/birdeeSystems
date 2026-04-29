{ inputs, moduleNamespace, ... }:
{
  flake.wrappers.fish =
    {
      config,
      lib,
      wlib,
      pkgs,
      ...
    }:
    {
      imports = [ ./. ];
      extraPackages = [ pkgs.hello ];
    };
  flake.modules.nixos.fish-install = { config, pkgs, lib, ... }: {
    wrappers.fish.enable = true;
    programs.fish = {
      enable = true;
      package = config.wrappers.fish.wrapper;
    };
  };
  flake.modules.homeManager.fish-install = { config, pkgs, lib, ... }: {
    # wrappers.fish.enable = true;
    # programs.fish = {
    #   enable = true;
    #   package = config.wrappers.fish.wrapper;
    # };
  };
}
