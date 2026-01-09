# This file imports overlays defined in the following format.
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
{ inputs, util, ... }:
let
  wrapmod = extraFromPrev: importName: inputs: final: prev: {
    ${importName} = inputs.self.wrapperModules.${importName}.wrap {
      pkgs =
        final
        // (builtins.listToAttrs (
          map (name: {
            inherit name;
            value = prev.${name};
          }) ([ importName ] ++ extraFromPrev)
        ));
    };
  };
  overlays = {

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
    gac = import ./gac;

    # wrapper modules
    git_with_config = importName: inputs: final: prev: {
      ${importName} = inputs.self.wrapperModules.git.wrap { pkgs = final; };
    };
    ranger = wrapmod [ ];
    luakit = wrapmod [ ];
    nushell = wrapmod [ ];
    opencode = wrapmod [ ];
    alacritty = wrapmod [ ];
    starship = wrapmod [ ];
    tmux = wrapmod [ ];
    wezterm = wrapmod [ "tmux" ];
    bemenu = wrapmod [ ];
    xplr = importName: inputs: final: prev: {
      ${importName} = inputs.self.wrapperModules.${importName}.wrap {
        pkgs = final // {
          ${importName} = prev.${importName};
          tmux = prev.tmux;
        };
        termCmd = "${final.wezterm}/bin/wezterm";
      };
    };

  };
  importedOverlays = {
    nur = inputs.nur.overlays.default or inputs.nur.overlay;
    minesweeper = inputs.minesweeper.overlays.default;
    shelua = inputs.shelua.overlays.default;
  };
  oversBefore = [];
  oversAfter = [ "tmux" ];
in
rec {
  overlaySet = util.pipe overlays [
    (builtins.mapAttrs (name: f: (f name inputs)))
    (v: v // importedOverlays)
  ];
  overlayList = map (n: overlaySet.${n}) oversBefore
    ++ builtins.attrValues (builtins.removeAttrs overlaySet (oversBefore ++ oversAfter))
    ++ map (n: overlaySet.${n}) oversAfter;
}
