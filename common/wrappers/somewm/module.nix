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
      # config.init = ''
      # '';
      # config.extraLuaPaths = [ ./lua ];
    };
}
