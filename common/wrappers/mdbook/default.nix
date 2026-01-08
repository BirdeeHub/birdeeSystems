{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:
let
in
{
  imports = [ ./module.nix ];
  options.outpath = lib.mkOption {
    type = lib.types.nonEmptyStr;
    default = "./_site";
  };
  options.baked-in-build = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
  config.addFlag = lib.mkIf config.baked-in-build [
    {
      name = "BUILD_ARG";
      data = [
        "build"
        "${placeholder "out"}/${config.generated-book-subdir}"
      ];
    }
    {
      after = [ "BUILD_ARG" ];
      data = [
        "-d"
        "${config.outpath}"
      ];
    }
  ];
}
