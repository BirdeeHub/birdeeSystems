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

    # work in progress?
    antifennel = import ./antifennel;
    alakazam = import ./alakitty;
    foot = import ./foot;
    luakitkat = import ./luakit birdeeutils;
    opencode = import ./opencode.nix;

  };
  overlaySetMapped = builtins.mapAttrs (name: value: (value name inputs)) overlaySetPre;
  overlaySet = overlaySetMapped // {
    nur = inputs.nur.overlays.default or inputs.nur.overlay;
    minesweeper = inputs.minesweeper.overlays.default;
    shelua = inputs.shelua.overlays.default;
    wezterm = final: prev: {
      wezterm = inputs.wezterm_bundle.packages.${final.system}.wezterm.override {
        autotx = false;
        wrapZSH = false;
      };
    };
    tmux = final: prev: {
      tmux = inputs.wezterm_bundle.packages.${final.system}.tmux;
    };
  };
in overlaySet
