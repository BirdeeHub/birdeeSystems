# TODO: weston wrapper module
{ config, pkgs, lib, wlib, ... }: {
  imports = [ wlib.modules.default ];
  options.info = lib.mkOption {
    type = wlib.types.attrsRecursive;
    default = { };
  };
  options.init = lib.mkOption {
    type = lib.types.lines;
    default = "";
  };
  options.generatedLP = lib.mkOption {
    type = lib.types.str;
    readOnly = true;
    default = "${placeholder config.constructFiles.info.output}/${config.binName}-generated";
  };
  config.package = lib.mkDefault pkgs.weston;
  config.constructFiles.init = {
    content = config.init;
    relPath = "${config.binName}-init.lua";
  };
  config.constructFiles.info = {
    content = "return " + lib.generators.toLua { } config.info;
    relPath = "${config.binName}-generated/nix-info.lua";
  };
}
