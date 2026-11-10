{ inputs, util, ... }:
{
  imports = [ (util.importApply ./nops inputs) ];
  overlays = {
    dep-tree = final: prev: {
      dep-tree = prev.callPackage ./dep-tree.nix { };
    };
    libvma = {
      enable = false;
      data = final: prev: {
        libvma = prev.callPackage ./libvma.nix { libvma-src = inputs.libvma-src or null; };
      };
    };
    hpg = {
      enable = false;
      data = final: prev: {
        hpg = prev.callPackage ./hpg.nix {
          hpg-src = inputs.hpg-src;
          kokkos4 = inputs.nixpkgsKokkos4.legacyPackages.${final.stdenv.hostPlatform.system}.kokkos;
        };
      };
    };
    gac = import ./gac.nix inputs;
    pinnedVersions = {
      data = import ./pinnedVersions.nix inputs;
      enable = false;
    };
    nerd-fonts-compat = import ./nerd-fonts-compat.nix;
    nur = inputs.nur.overlays.default or inputs.nur.overlay;
    minesweeper = inputs.minesweeper.overlays.default;
  };
}
