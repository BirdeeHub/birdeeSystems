{
  lib,
  wlib,
  collectOptions,
}:
{ graph, options, config, ... }:
let
  inherit (config) pkgs;
  og_options = collectOptions {
    inherit options;
    transform = x: if builtins.elem "_module" x.loc then [ ] else [ x ];
  };
in
og_options
