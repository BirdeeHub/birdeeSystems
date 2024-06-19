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
    flake-utils.url = "github:numtide/flake-utils";
    nur.url = "github:nix-community/nur";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    minesweeper.url = "github:BirdeeHub/minesweeper/nix";
    minesweeper.inputs.nixpkgs.follows = "nixpkgs";
    minesweeper.inputs.flake-utils.follows = "flake-utils";

    # neovim
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    nixCats.inputs.nixpkgs.follows = "nixpkgs";
    neovim-src = { url = "github:neovim/neovim/nightly"; flake = false; };
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    #   # inputs.nixpkgs.follows = "nixpkgs";
    #   # inputs.neovim-src.follows = "neovim-src";
    # };
    templ.url = "github:a-h/templ";
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    "plugins-lz-n" = {
      url = "github:nvim-neorocks/lz.n";
      flake = false;
    };
    "plugins-lazydev-nvim" = {
      url = "github:folke/lazydev.nvim";
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
    codeium.url = "github:Exafunction/codeium.nvim";
    sg-nvim.url = "github:sourcegraph/sg.nvim";
    "bash-debug-adapter" = {
      url = "github:rogalmic/vscode-bash-debug";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, ... }@inputs: let
    system = "x86_64-linux";
    stateVersion = "23.05";
    forEachSystem = (import ./platforms.nix).eachSystem nixpkgs.lib.platforms.all;
    overlays = (import ./overlays inputs);
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
    myOverlays = overlays;
    homeConfigurations = {
      "birdee@dustbook" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          username = "birdee";
          monitorCFG = ./homes/monitors_by_hostname/dustbook;
          inherit nixpkgs stateVersion self system inputs users home-modules;
        };
        inherit pkgs;
        modules = [
          ./homes/birdee.nix
          ({ pkgs, ... }:{
            nix.package = pkgs.nix;
          })
        ];
      };
      "birdee@nestOS" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          username = "birdee";
          monitorCFG = ./homes/monitors_by_hostname/nestOS;
          inherit nixpkgs stateVersion self system inputs users home-modules;
        };
        inherit pkgs;
        modules = [
          ./homes/birdee.nix
          ({ pkgs, ... }:{
            nix.package = pkgs.nix;
          })
        ];
      };
    };
    nixosConfigurations = {
      "birdee@nestOS" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hostname = "nestOS";
          inherit nixpkgs stateVersion self inputs users system-modules overlays;
        };
        inherit system;
        modules = [
          home-manager.nixosModules.home-manager
          disko.nixosModules.disko
          ./disko/PCs/sda_swap.nix
          ./systems/PCs/aSUS
          {
            nixpkgs.overlays = overlays;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.birdee = import ./homes/birdee.nix;
            home-manager.extraSpecialArgs = {
              username = "birdee";
              monitorCFG = ./homes/monitors_by_hostname/nestOS;
              inherit nixpkgs stateVersion self system inputs users home-modules;
            };
          }
        ];
      };
      "birdee@dustbook" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hostname = "dustbook";
          inherit nixpkgs stateVersion self inputs users system-modules overlays;
        };
        inherit system;
        modules = [
          home-manager.nixosModules.home-manager
          disko.nixosModules.disko
          ./disko/PCs/sda_swap.nix
          ./systems/PCs/dustbook
          {
            nixpkgs.overlays = overlays;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.birdee = import ./homes/birdee.nix;
            home-manager.extraSpecialArgs = {
              username = "birdee";
              monitorCFG = ./homes/monitors_by_hostname/dustbook;
              inherit nixpkgs stateVersion self system inputs users home-modules;
            };
          }
        ];
      };
      "nestOS" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hostname = "nestOS";
          inherit nixpkgs stateVersion self inputs users system-modules overlays;
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
          inherit nixpkgs stateVersion self inputs users system-modules overlays;
        };
        inherit system;
        modules = [
          disko.nixosModules.disko
          ./disko/PCs/sda_swap.nix
          ./systems/PCs/dustbook
        ];
      };
      "my-qemu-vm" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hostname = "virtbird";
          inherit nixpkgs stateVersion self inputs users system-modules overlays;
        };
        inherit system;
        modules = [
          home-manager.nixosModules.home-manager
          ./systems/VMs/qemu
          {
            nixpkgs.overlays = overlays;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.birdee = import ./homes/birdee.nix;
            home-manager.extraSpecialArgs = {
              username = "birdee";
              monitorCFG = null;
              inherit nixpkgs stateVersion self system inputs users home-modules;
            };
          }
        ];
      };
    };
    diskoConfigurations = {
      PC_sda_swap = import ./disko/PCs/sda_swap.nix;
      PC_sdb_swap = import ./disko/PCs/sdb_swap.nix;
    };
    templates = import ./templates inputs;
  } // (forEachSystem (system:
      { installer = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit self nixpkgs inputs system-modules overlays;
        };
        inherit system;
        modules = [
          ./systems/PCs/installer
        ];
      };
    }));
}
