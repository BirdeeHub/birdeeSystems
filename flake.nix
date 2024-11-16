{
  description = ''
    birdee's system. common/default.nix handles passing modules
    to home-manager and nixos config files in home and system
    and userdata is passed to them as well.

    flake.nix contains only inputs,
    the outputs function is at ./default.nix
  '';

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # system
    nixpkgs.url = "github:nixos/nixpkgs/ae815cee91b417be55d43781eb4b73ae1ecc396c";
    # nixpkgsNV.url = "git+file:/home/birdee/temp/testgrammars/nixpkgs?branch=end-nvim-treesitter-queries-saga";
    # nixpkgsNV.url = "git+file:/home/birdee/temp/nixpkgs?branch=fix-treesitter-duplicate-grammar";
    nixpkgsNV.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgsNV.url = "github:PerchunPak/nixpkgs/end-nvim-treesitter-queries-saga";
    nixpkgsLocked.url = "github:nixos/nixpkgs/e913ae340076bbb73d9f4d3d065c2bca7caafb16";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    manix.url = "github:nix-community/manix";
    manix.inputs.nixpkgs.follows = "nixpkgsNV";
    manix.inputs.flake-utils.follows = "flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
    nur.url = "github:nix-community/nur";
    nixos-hardware.url = "github:NixOS/nixos-hardware/9fc19be21f0807d6be092d70bf0b1de0c00ac895";
    nixos-hardware-new.url = "github:NixOS/nixos-hardware";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nsearch.url = "github:niksingh710/nsearch";
    nsearch.inputs.nixpkgs.follows = "nixpkgs";
    minesweeper.url = "github:BirdeeHub/minesweeper";
    minesweeper.inputs.nixpkgs.follows = "nixpkgsNV";
    maximizer.url = "github:BirdeeHub/maximizer";
    maximizer.inputs.nixpkgs.follows = "nixpkgs";
    nixToLua.url = "github:BirdeeHub/nixtoLua";

    # neovim
    # nixCats.url = "github:BirdeeHub/nixCats-nvim";
    nixCats.url = "git+file:/home/birdee/Projects/nixCats-nvim";
    # neovim-src = { url = "github:neovim/neovim/nightly"; flake = false; };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      # inputs.nixpkgs.follows = "nixpkgsNV";
      # inputs.neovim-src.follows = "neovim-src";
    };
    nix-appimage.url = "github:ralismark/nix-appimage";
    templ.url = "github:a-h/templ";
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    lze = {
    # plugins-lze = {
      url = "github:BirdeeHub/lze";
      # url = "git+file:/home/birdee/Projects/lze";
      inputs.nixpkgs.follows = "nixpkgsNV";
      # flake = false;
    };
    codeium = {
      url = "github:Exafunction/codeium.nvim";
      # inputs.nixpkgs.follows = "nixpkgsNV";
    };
    "plugins-hlargs" = {
      url = "github:m-demare/hlargs.nvim";
      flake = false;
    };
    "plugins-render-markdown" = {
      url = "github:MeanderingProgrammer/markdown.nvim";
      flake = false;
    };
    "plugins-fugit2-nvim" = {
      url = "github:SuperBo/fugit2.nvim";
      flake = false;
    };
    "plugins-nvim-tinygit" = {
      url = "github:chrisgrieser/nvim-tinygit";
      flake = false;
    };
    "plugins-nvim-luaref" = {
      url = "github:milisims/nvim-luaref";
      flake = false;
    };
    "plugins-telescope-git-file-history" = {
      url = "github:isak102/telescope-git-file-history.nvim";
      flake = false;
    };
    "plugins-otter-nvim" = {
      url = "github:jmbuhr/otter.nvim";
      flake = false;
    };
    "plugins-large_file" = {
      url = "github:mireq/large_file";
      flake = false;
    };
    "plugins-code-compass" = {
      url = "github:emmanueltouzery/code-compass.nvim";
      flake = false;
    };
    "plugins-visual-whitespace" = {
      url = "github:mcauley-penney/visual-whitespace.nvim";
      flake = false;
    };
    "plugins-grapple" = {
      url = "github:cbochs/grapple.nvim";
      flake = false;
    };
    "plugins-img-clip" = {
      url = "github:HakonHarnes/img-clip.nvim";
      flake = false;
    };
  };
  outputs = inputs: import ./. inputs;
}
