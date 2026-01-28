{
  lib,
  wlib,
  collectOptions,
}:
pkgs:
options:
collectOptions {
  inherit options;
  transform = x: if !builtins.elem "_module" x.loc then [ x ] else [ ];
}
