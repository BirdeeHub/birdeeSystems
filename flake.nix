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
      inputs.nixpkgs.follows = "nixpkgsNV";
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
    shelua.url = "github:BirdeeHub/shelua";
    shelua.inputs.nixpkgs.follows = "nixpkgs";
    shelua.inputs.n2l.follows = "nixToLua";
    nix-appimage.url = "github:ralismark/nix-appimage";
    templ.url = "github:a-h/templ";
    antifennel = {
      url = "sourcehut:~technomancy/antifennel";
      flake = false;
    };
    nixpkgs-ollama.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    ollama = {
      url = "github:ollama/ollama";
      flake = false;
    };

    # also has tmux config
    wezterm_bundle.url = "github:BirdeeHub/wezterm_bundle";
    # wezterm_bundle.url = "git+file:/home/birdee/Projects/wezterm_bundle";
    wezterm_bundle.inputs.nixpkgs.follows = "nixpkgsNV";
    wezterm_bundle.inputs.wrappers.follows = "wrappers";

    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";

    # neovim
    birdeevim.url = "github:BirdeeHub/birdeevim";
    birdeevim.inputs.wrappers.follows = "wrappers";
    # birdeevim.url = "git+file:/home/birdee/.birdeevim";
  };
  outputs = inputs: import ./. inputs;
}
