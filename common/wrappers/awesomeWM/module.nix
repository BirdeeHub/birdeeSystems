{ inputs, ... }:
{
  flake.wrappers.somewm =
    {
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    {
      imports = [ inputs.self.wrapperModules.awesomeWM ];
      config.package = inputs.somewm.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  flake.wrappers.awesomeWM =
    {
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    {
      imports = [ ./. ];
      # config.init = ''
      # '';
      # config.extraLuaPaths = [ ./lua ];
    };
}
