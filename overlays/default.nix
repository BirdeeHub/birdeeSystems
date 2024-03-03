/*
This file imports overlays defined in the following format.
*/
# Example overlay:
/*
importName: inputs: let
  overlay = self: super: { 
    ${importName} = {
      # define your overlay derivations here
    };
  };
in
overlay
*/
{ inputs, ... }: let 
  overlaySet = {

    # this is how you would add another overlay file
    # for if your customBuildsOverlay gets too long
    # the name here will be the name used when importing items from it in your flake.
    # i.e. these items will be accessed as pkgs.nixCatsBuilds.thenameofthepackage

    # except this one which outputs wherever it needs to.
    pinnedVersions = import ./pinnedVersions.nix;

  };
  overlayList = builtins.attrValues (builtins.mapAttrs (name: value: (value name inputs)) overlaySet);
in overlayList
