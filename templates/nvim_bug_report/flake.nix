{
  description = ''
    A minimal configuration skeleton for nvim
    using pkgs.wrapNeovim for use in making minimal
    reproduction cases for bug reports to nixpkgs.

    Also uses nixToLua to pass a table,
    and loads the directory as a config directory.
  '';
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nixToLua.url = "github:BirdeeHub/nixToLua";
  };
  outputs = { nixpkgs, neovim-nightly, nixToLua, ...}: let
    forAllSys = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    extraOverlays = [];
    overlayMyNeovim = prev: final: {
      valuesToPass = {
      };
      myNeovim = let
        luaRC = final.writeText "init.lua" /*lua*/''
          -- create require('nixvals') table
          package.preload["nixvals"] = function()
            return ${nixToLua.prettyNoModify valuesToPass}
          end
          -- load current directory as config directory
          vim.opt.rtp:remove(vim.fn.stdpath("config"))
          vim.opt.packpath:remove(vim.fn.stdpath("config"))
          vim.opt.rtp:remove(vim.fn.stdpath("config") .. "/after")
          vim.opt.rtp:prepend(${./.})
          vim.opt.packpath:prepend(${./.})
          vim.opt.rtp:append(${./.} .. "/after")
          -- require lua/my_config
          require("my_config")
        '';
      in
      final.wrapNeovim final.neovim {
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
      configuredNvimOverlay = extraOverlays ++ [ overlayMyNeovim ];
      pkgs = import nixpkgs {
        inherit system;
        overlays = configuredNvimOverlay;
      };
      pkgs_nightly = import nixpkgs {
        inherit system;
        overlays = [ neovim-nightly.overlays.default ] ++ configuredNvimOverlay;
      };
    in
    {
      default = pkgs.myNeovim;
      nightly = pkgs_nightly.myNeovim;
    });
  };
}
