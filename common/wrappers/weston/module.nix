# TODO: weston wrapper module
{ inputs, ... }:
{
  flake.wrappers.weston =
    {
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    {
      imports = [ wlib.modules.default ];
      config.package = lib.mkDefault pkgs.weston;
      config.flags."-c" = config.constructFiles.generatedConfig.path;
      config.constructFiles.generatedConfig = {
        content = "";
        relPath = "${config.binName}-config.ini";
      };
    };
}
