{
  description = ''
    birdee's system. modules/default.nix handles passing modules
    to home-manager and nixos config files in home and system
    and userdata is passed to them as well.
  '';

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs_4_OMP.url = "github:nixos/nixpkgs/6660475dea29309327ee3b2e6824ec0011589017";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/nur";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";


    # neovim
    flake-utils.url = "github:numtide/flake-utils";
    nixCats.url = "/home/birdee/Projects/nixCats-nvim";
    # nixCats.url = "github:BirdeeHub/nixCats-nvim/nixCats-5.0.0";
    # have not figured out how to download a debug adapter not on nixpkgs
    # Will be attempting to build this from source in an overlay eventually
    # neovim = {
    #   url = "github:neovim/neovim";
    #   flake = false;
    # };
    "bash-debug-adapter" = {
      url = "github:rogalmic/vscode-bash-debug";
      flake = false;
    };
    # If you want your plugin to be loaded by the standard overlay,
    # Then you should name it "plugins-something"
    "plugins-nvim-luaref" = {
      url = "github:milisims/nvim-luaref";
      flake = false;
    };
    "plugins-harpoon" = {
      url = "github:ThePrimeagen/harpoon/harpoon2";
      flake = false;
    };
    codeium.url = "github:Exafunction/codeium.nvim";
    sg-nvim.url = "github:sourcegraph/sg.nvim";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }@inputs: let
    system = "x86_64-linux";
    stateVersion = "23.05";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        inputs.nur.overlay
      ];
      config.allowUnfree = true;
    };
    users = import ./userdata pkgs;
    home-modules = import ./common { homeModule = true; inherit inputs pkgs; };
    system-modules = import ./common { homeModule = false; inherit inputs pkgs; };
  in {
    packages = home-modules.birdeeVim.packages;
    homeConfigurations = {
      "birdee" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          username = "birdee";
          inherit stateVersion self system inputs users home-modules;
        };
        inherit pkgs;
        modules = [
          ./homes/birdee.nix
        ];
      };
    };
    nixosConfigurations = {
      "nestOS" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hostname = "nestOS";
          inherit stateVersion self inputs users system-modules;
        };
        inherit system;
        modules = [
          ./systems/aSUS.nix
          nixos-hardware.outputs.nixosModules.asus-fx504gd
        ];
      };
    };
  };
}
