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
  flake.wrappers.awesomeWM =
    {
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    {
      imports = [ wlib.modules.default ];
      options.info = lib.mkOption {
        type = wlib.types.attrsRecursive;
        default = { };
      };
      options.init = lib.mkOption {
        type = lib.types.lines;
        default = "";
      };
      options.extraLuaPaths = lib.mkOption {
        type = lib.types.listOf wlib.types.stringable;
        default = [ ];
      };
      options.generatedLP = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "${placeholder config.constructFiles.info.output}/${config.binName}-generated";
      };
      config.package = lib.mkDefault pkgs.awesome;
      config.flags."-c" = config.constructFiles.init.path;
      config.flags."--search" = [ config.generatedLP ] ++ config.extraLuaPaths;
      config.constructFiles.init = {
        content = config.init;
        relPath = "${config.binName}-init.lua";
      };
      config.constructFiles.info = {
        content = "return " + lib.generators.toLua { } config.info;
        relPath = "${config.binName}-generated/nix-info.lua";
      };
    };
}
