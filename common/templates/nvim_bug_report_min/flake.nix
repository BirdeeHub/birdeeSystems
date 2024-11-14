{
  description = ''
    A minimal configuration skeleton for nvim
    using pkgs.wrapNeovim for use in making minimal
    reproduction cases for bug reports to nixpkgs.
  '';
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, neovim-nightly, ...}@inputs: let
    forAllSys = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    extraOverlays = [];
    overlayMyNeovim = nvim: prev: final: {
      myNeovim = let
        luaRC = final.writeText "init.lua" ''
          require("nvim-treesitter.configs").setup({
            auto_install = false,
            highlight = {
              enable = true
            },
          })
        '';
      in
      final.wrapNeovim (if nvim != null then nvim else final.neovim-unwrapped) {
        configure = {
          customRC = ''lua dofile("${luaRC}")'';
          packages.all.start = with final.vimPlugins; [ 
            nvim-treesitter.withAllGrammars
          ];
          packages.all.opt = with final.vimPlugins; [
          ];
        };
        extraMakeWrapperArgs = builtins.concatStringsSep " " [
          ''--prefix PATH : "${final.lib.makeBinPath (with final; [ stdenv.cc.cc ])}"''
        ];
        extraLuaPackages = (_: []);
        extraPythonPackages = (_: []);
        withPython3 = true;
        extraPython3Packages = (_: []);
        withNodeJs = false;
        withRuby = true;
        vimAlias = false;
        viAlias = false;
        extraName = "";
      };
    };
  in 
  {
    packages = forAllSys (system: let
      configuredNvimOverlay = extraOverlays ++ [ (overlayMyNeovim null) ];
      configuredNvimNightlyOverlay = extraOverlays ++ [ (overlayMyNeovim neovim-nightly.packages.${system}.neovim) ];
      pkgs = import nixpkgs {
        inherit system;
        overlays = configuredNvimOverlay;
      };
      pkgs_nightly = import nixpkgs {
        inherit system;
        overlays = configuredNvimNightlyOverlay;
      };
    in
    {
      default = pkgs.myNeovim;
      nightly = pkgs_nightly.myNeovim;
    });
  };
}
