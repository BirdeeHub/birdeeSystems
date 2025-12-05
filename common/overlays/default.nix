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
{ inputs, birdeeutils, ... }: let 
  wrapmod = importName: inputs: final: prev: {
    ${importName} = inputs.self.wrapperModules.${importName}.wrap {
        pkgs = final // { ${importName} = prev.${importName}; };
    };
  };
  overlaySetPre = {

    # this is how you would add another overlay file
    # for if your customBuildsOverlay gets too long
    # the name here will be the name used when importing items from it in your flake.
    # i.e. these items will be accessed as pkgs.nixCatsBuilds.thenameofthepackage

    # except this one which outputs wherever it needs to.
    pinnedVersions = import ./pinnedVersions.nix;

    nerd-fonts-compat = import ./nerd-fonts-compat.nix;

    dep-tree = import ./dep-tree;
    nops = import ./nops;
    antifennel = import ./antifennel;

    # wrapper modules
    git_with_config = importName: inputs: final: prev: {
      ${importName} = inputs.self.wrapperModules.git.wrap {
        pkgs = final // { ${importName} = prev.${importName}; };
      };
    };
    ranger = wrapmod;
    luakit = wrapmod;
    nushell = wrapmod;
    opencode = wrapmod;
    alacritty = wrapmod;
    starship = wrapmod;
    tmux = wrapmod;
    xplr = importName: inputs: final: prev: {
      ${importName} = inputs.self.wrapperModules.${importName}.wrap {
        pkgs = final // {
          ${importName} = prev.${importName};
        };
        termCmd = "${final.wezterm}/bin/wezterm";
      };
    };
    wezterm = wrapmod;

  };
  overlaySetMapped = builtins.mapAttrs (name: value: (value name inputs)) overlaySetPre;
  overlaySet = overlaySetMapped // {
    nur = inputs.nur.overlays.default or inputs.nur.overlay;
    minesweeper = inputs.minesweeper.overlays.default;
    shelua = inputs.shelua.overlays.default;
  };
in overlaySet
