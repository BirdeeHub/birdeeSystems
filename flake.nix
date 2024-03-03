{
  description = ''
    birdee's system. modules/default.nix handles passing modules
    to home-manager and nixos config files in home and system
    and userdata is passed to them as well.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    nixCats.inputs.nixpkgs.follows = "nixpkgs";
    nixCats.inputs.flake-utils.follows = "flake-utils";
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    neovim = {
      url = "github:neovim/neovim/nightly";
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
    "bash-debug-adapter" = {
      url = "github:rogalmic/vscode-bash-debug";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, disko, ... }@inputs: let
    system = "x86_64-linux";
    stateVersion = "23.05";
    overlays = [
      inputs.nur.overlay
    ] ++ (import ./overlays inputs);
    pkgs = import inputs.nixpkgs {
      inherit system overlays;
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
          inherit stateVersion self inputs users system-modules overlays;
        };
        inherit system;
        modules = [
          disko.nixosModules.disko
          ./disko/PCs/sda_swap.nix
          ./systems/PCs/aSUS
        ];
      };
      "dustbook" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hostname = "dustbook";
          inherit stateVersion self inputs users system-modules overlays;
        };
        inherit system;
        modules = [
          disko.nixosModules.disko
          ./disko/PCs/sda_swap.nix
          ./systems/PCs/dustbook
        ];
      };
    } // (flake-utils.lib.eachSystem flake-utils.lib.allSystems (system:
      { "installer" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit self nixpkgs inputs system-modules overlays;
        };
        inherit system;
        modules = [
          ./systems/PCs/installer
        ];
      };
    }));
    diskoConfigurations = {
      PCs = {
        sda_swap = import ./disko/PCs/sda_swap.nix;
        sdb_swap = import ./disko/PCs/sdb_swap.nix;
      };
    };
  };
}
