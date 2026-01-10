{ inputs, util, ... }:
let
  combinepkgs =
    fromPrev: final: prev:
    final
    // (builtins.listToAttrs (
      map (name: {
        inherit name;
        value = prev.${name};
      }) fromPrev
    ));
  wrapmod = extrasFromPrev: {
    data = name: final: prev: {
      ${name} = inputs.self.wrappedModules.${name}.wrap {
        pkgs = combinepkgs ([ name ] ++ extrasFromPrev) final prev;
      };
    };
    call-data-with-name = true;
  };
in
{
  overlays = {
    dep-tree = final: prev: {
      dep-tree = prev.callPackage ./dep-tree.nix { };
    };
    antifennel = final: prev: { antifennel = prev.callPackage ./antifennel.nix { inherit inputs; }; };
    libvma = final: prev: { libvma = prev.callPackage ./libvma.nix { inherit (inputs) libvma-src; }; };
    gac = import ./gac.nix inputs;
    pinnedVersions = import ./pinnedVersions.nix inputs;
    nops = {
      call-data-with-name = true;
      data = import ./nops inputs;
    };
    nerd-fonts-compat = import ./nerd-fonts-compat.nix;
    nur = inputs.nur.overlays.default or inputs.nur.overlay;
    minesweeper = inputs.minesweeper.overlays.default;
    shelua = inputs.shelua.overlays.default;

    # wrapper modules
    git_with_config = final: prev: {
      git_with_config = inputs.self.wrappedModules.git.wrap { pkgs = final; };
    };
    ranger = wrapmod [ ];
    luakit = wrapmod [ ];
    nushell = wrapmod [ ];
    bemenu = wrapmod [ ];
    opencode = wrapmod [ ];
    alacritty = wrapmod [ ];
    starship = wrapmod [ ];
    tmux = wrapmod [ ];
    wezterm = wrapmod [ "tmux" ] // {
      before = [ "tmux" ];
    };
    xplr = {
      before = [ "tmux" ];
      data = final: prev: {
        xplr = inputs.self.wrappedModules.xplr.wrap {
          pkgs = final // {
            xplr = prev.xplr;
            tmux = prev.tmux;
          };
          termCmd = "${final.wezterm}/bin/wezterm";
        };
      };
    };
  };
}
