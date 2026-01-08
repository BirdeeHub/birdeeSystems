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
  config.flags = {
    "-d" = {
      after = [ "BUILD_ARG" ];
      data = lib.mkOptionDefault "./_site";
    };
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
  ];
}
