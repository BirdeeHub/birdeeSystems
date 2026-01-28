{
  lib,
  wlib,
  collectOptions,
}:
pkgs: options:
let
  og_options = collectOptions {
    inherit options;
    transform = x: if builtins.elem "_module" x.loc then [ ] else [ x ];
  };
in
og_options
