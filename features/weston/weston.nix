{
  config,
  pkgs,
  lib,
  wlib,
  ...
}:
{
  imports = [ wlib.modules.default ];
  options.settings = lib.mkOption {
    type = wlib.types.attrsRecursive;
    default = { };
    description = ''
      Content of the weston INI config file

      To repeat a heading, provide a list of values for that heading.
    '';
  };
  config.package = lib.mkDefault pkgs.weston;
  config.flags."-c" = config.constructFiles.generatedConfig.path;
  config.constructFiles.generatedConfig = {
    content = lib.pipe config.settings [
      (lib.mapAttrsToList (
        n: v: if builtins.isList v then map (v: { ${n} = v; }) v else [ { ${n} = v; } ]
      ))
      builtins.concatLists
      (map (lib.generators.toINI { }))
      (builtins.concatStringsSep "\n")
    ];
    relPath = "${config.binName}-config.ini";
  };
}
