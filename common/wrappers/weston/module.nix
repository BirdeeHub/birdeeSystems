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
      imports = [ ./weston.nix ];
      settings = import ./test.nix;
    };
}
