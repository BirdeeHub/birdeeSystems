{
  description = ''
    birdee's system. modules/default.nix handles passing modules
    to home-manager and nixos config files in home and system
    and userdata is passed to them as well.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/nur";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";


    # neovim
    flake-utils.url = "github:numtide/flake-utils";
    # nixCats.url = "/home/birdee/Projects/nixCats-nvim";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    # have not figured out how to download a debug adapter not on nixpkgs
    # Will be attempting to build this from source in an overlay eventually
    "bash-debug-adapter" = {
      url = "github:rogalmic/vscode-bash-debug";
      flake = false;
    };
    # neovim = {
    #   url = "github:neovim/neovim";
    #   flake = false;
    # };
    # If you want your plugin to be loaded by the standard overlay,
    # Then you should name it "plugins-something"
    "plugins-onedark" = {
      url = "github:navarasu/onedark.nvim";
      flake = false;
    };
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

  outputs = { self, nixpkgs, home-manager, flake-utils, disko, ... }@inputs: let
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
    common = import ./common { inherit inputs pkgs; };
    home-modules = common { homeModule = true; };
    system-modules = common { homeModule = false; };
  in {
    packages = home-modules.birdeeVim.packages;
    inherit home-modules system-modules;
    homeConfigurations = {
      "birdee@dustbook" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          username = "birdee";
          monitorCFG = ./homes/monitors_by_hostname/dustbook;
          inherit stateVersion self system inputs users home-modules;
        };
        inherit pkgs;
        modules = [
          ./homes/birdee.nix
        ];
      };
      "birdee@nestOS" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          username = "birdee";
          monitorCFG = ./homes/monitors_by_hostname/nestOS;
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
          ./systems/PCs/aSUS
        ];
      };
      "dustbook" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hostname = "dustbook";
          inherit stateVersion self inputs users system-modules;
        };
        inherit system;
        modules = [
          disko.nixosModules.disko
          ./systems/PCs/dustbook
        ];
      };
      "installer" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit self nixpkgs disko inputs system-modules;
        };
        inherit system;
        modules = [
          disko.nixosModules.disko
          ./systems/PCs/installer
        ];
      };
    };
    diskoConfigurations = {
      sda_swap = ./systems/PCs/disko/sda.nix;
      sdb_swap = ./systems/PCs/disko/sdb.nix;
    };
  };
}
