/*
This file imports overlays defined in the following format.
Plugins will still only be downloaded if included in a category.
You may copy paste this example into a new file and then import that file here.
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
inputs: let 
  overlaySet = {

    # this is how you would add another overlay file
    # for if your customBuildsOverlay gets too long
    # the name here will be the name used when importing items from it in your flake.
    # i.e. these items will be accessed as pkgs.nixCatsBuilds.thenameofthepackage

    #except for this one which just outputs to the base pkgs set
    pinnedVersions = import ./pinnedVersions.nix;

  };
in
builtins.attrValues (builtins.mapAttrs (name: value: (value name inputs)) overlaySet)
