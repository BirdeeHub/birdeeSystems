{
  description = ''
    birdee's system. modules/default.nix handles passing modules
    to home-manager and nixos config files in home and system
    and userdata is passed to them as well.
  '';

  inputs = {
    # system
    nixpkgs.url = "github:nixos/nixpkgs/e913ae340076bbb73d9f4d3d065c2bca7caafb16";
    # nixpkgsNV.url = "git+file:/home/birdee/Projects/nixpkgs?branch=fixtsserver";
    nixpkgsNV.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgsLocked.url = "github:nixos/nixpkgs/e913ae340076bbb73d9f4d3d065c2bca7caafb16";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nur.url = "github:nix-community/nur";
    nixos-hardware.url = "github:NixOS/nixos-hardware/acb4f0e9bfa8ca2d6fca5e692307b5c994e7dbda";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    minesweeper.url = "github:BirdeeHub/minesweeper";
    minesweeper.inputs.nixpkgs.follows = "nixpkgsNV";

    # neovim
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    # nixCats.url = "git+file:/home/birdee/Projects/nixCats-nvim";
    nixCats.inputs.nixpkgs.follows = "nixpkgsNV";
    # neovim-src = { url = "github:neovim/neovim/nightly"; flake = false; };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      # inputs.nixpkgs.follows = "nixpkgs";
      # inputs.neovim-src.follows = "neovim-src";
    };
    nix-appimage.url = "github:ralismark/nix-appimage";
    templ.url = "github:a-h/templ";
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    lz-n = {
      url = "github:nvim-neorocks/lz.n";
      # url = "github:BirdeeHub/lz.n";
      # url = "git+file:/home/birdee/Projects/lz.n";
      inputs.nixpkgs.follows = "nixpkgsNV";
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
    codeium = {
      url = "github:Exafunction/codeium.nvim";
      # inputs.nixpkgs.follows = "nixpkgsNV";
    };
    sg-nvim = {
      url = "github:sourcegraph/sg.nvim";
      # inputs.nixpkgs.follows = "nixpkgsNV";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      nix-appimage,
      ...
    }@inputs:
    let
      flake-path = "/home/birdee/birdeeSystems";
      stateVersion = "23.05";
      forEachSystem = (import ./platforms.nix).eachSystem nixpkgs.lib.platforms.all;
      withEachSystem = (import ./platforms.nix).bySystems nixpkgs.lib.platforms.all;
      overlays = (import ./overlays inputs);
      common = import ./common { inherit inputs flake-path; };
      home-modules = common { homeModule = true; };
      system-modules = common { homeModule = false; };
    in
    {
      inherit home-modules system-modules;
      myOverlays = overlays;
      diskoConfigurations = {
        PC_sda_swap = import ./disko/PCs/sda_swap.nix;
        PC_sdb_swap = import ./disko/PCs/sdb_swap.nix;
      };
      templates = import ./templates inputs;
    }
    // (forEachSystem (system: {
      app-images = home-modules.birdeeVim.app-images.${system} // (let
        bundle = nix-appimage.bundlers.${system}.default;
      in {
        minesweeper = bundle inputs.minesweeper.packages.${system}.default;
      });
      packages =
        home-modules.birdeeVim.packages.${system}
        // (
          let
            pkgs = import inputs.nixpkgs {
              inherit system overlays;
              config.allowUnfree = true;
            };
          in
          {
            inherit (pkgs) dep-tree;
          }
        )
        // {
          homeConfigurations =
            let
              pkgs = import inputs.nixpkgs {
                inherit system overlays;
                config.allowUnfree = true;
              };
              users = import ./userdata pkgs;
            in
            {
              "birdee@dustbook" = home-manager.lib.homeManagerConfiguration {
                extraSpecialArgs = {
                  username = "birdee";
                  monitorCFG = ./homes/monitors_by_hostname/dustbook;
                  inherit
                    nixpkgs
                    stateVersion
                    self
                    system
                    inputs
                    users
                    home-modules
                    flake-path
                    ;
                };
                inherit pkgs;
                modules = [
                  ./homes/birdee.nix
                  (
                    { pkgs, ... }:
                    {
                      nix.package = pkgs.nix;
                    }
                  )
                ];
              };
              "birdee@nestOS" = home-manager.lib.homeManagerConfiguration {
                extraSpecialArgs = {
                  username = "birdee";
                  monitorCFG = ./homes/monitors_by_hostname/nestOS;
                  inherit
                    nixpkgs
                    stateVersion
                    self
                    system
                    inputs
                    users
                    home-modules
                    flake-path
                    ;
                };
                inherit pkgs;
                modules = [
                  ./homes/birdee.nix
                  (
                    { pkgs, ... }:
                    {
                      nix.package = pkgs.nix;
                    }
                  )
                ];
              };
            };
          nixosConfigurations =
            let
              pkgs = import inputs.nixpkgs {
                inherit system overlays;
                config.allowUnfree = true;
              };
              users = import ./userdata pkgs;
            in
            {
              "birdee@nestOS" = nixpkgs.lib.nixosSystem {
                specialArgs = {
                  hostname = "nestOS";
                  inherit
                    nixpkgs
                    stateVersion
                    self
                    inputs
                    users
                    system-modules
                    overlays
                    flake-path
                    ;
                };
                inherit system;
                modules = [
                  home-manager.nixosModules.home-manager
                  disko.nixosModules.disko
                  ./disko/PCs/sda_swap.nix
                  ./systems/PCs/aSUS
                  (
                    { lib, ... }:
                    {
                      nixpkgs.overlays = overlays;
                      home-manager.useGlobalPkgs = true;
                      home-manager.useUserPackages = true;
                      home-manager.users.birdee = import ./homes/birdee.nix;
                      home-manager.backupFileExtension = "hm-bkp";
                      home-manager.verbose = true;
                      home-manager.extraSpecialArgs = {
                        username = "birdee";
                        monitorCFG = ./homes/monitors_by_hostname/nestOS;
                        inherit
                          nixpkgs
                          stateVersion
                          self
                          system
                          inputs
                          users
                          home-modules
                          flake-path
                          ;
                      };
                      services.displayManager.defaultSession = lib.mkDefault "none+fake";
                    }
                  )
                ];
              };
              "birdee@dustbook" = nixpkgs.lib.nixosSystem {
                specialArgs = {
                  hostname = "dustbook";
                  inherit
                    nixpkgs
                    stateVersion
                    self
                    inputs
                    users
                    system-modules
                    overlays
                    flake-path
                    ;
                };
                inherit system;
                modules = [
                  home-manager.nixosModules.home-manager
                  disko.nixosModules.disko
                  ./disko/PCs/sda_swap.nix
                  ./systems/PCs/dustbook
                  (
                    { lib, ... }:
                    {
                      nixpkgs.overlays = overlays;
                      home-manager.useGlobalPkgs = true;
                      home-manager.useUserPackages = true;
                      home-manager.users.birdee = import ./homes/birdee.nix;
                      home-manager.backupFileExtension = "hm-bkp";
                      home-manager.verbose = true;
                      home-manager.extraSpecialArgs = {
                        username = "birdee";
                        monitorCFG = ./homes/monitors_by_hostname/dustbook;
                        inherit
                          nixpkgs
                          stateVersion
                          self
                          system
                          inputs
                          users
                          home-modules
                          flake-path
                          ;
                      };
                      services.displayManager.defaultSession = lib.mkDefault "none+fake";
                    }
                  )
                ];
              };
              "nestOS" = nixpkgs.lib.nixosSystem {
                specialArgs = {
                  hostname = "nestOS";
                  inherit
                    nixpkgs
                    stateVersion
                    self
                    inputs
                    users
                    system-modules
                    overlays
                    flake-path
                    ;
                };
                inherit system;
                modules = [
                  { nixpkgs.overlays = overlays; }
                  disko.nixosModules.disko
                  ./disko/PCs/sda_swap.nix
                  ./systems/PCs/aSUS
                ];
              };
              "dustbook" = nixpkgs.lib.nixosSystem {
                specialArgs = {
                  hostname = "dustbook";
                  inherit
                    nixpkgs
                    stateVersion
                    self
                    inputs
                    users
                    system-modules
                    overlays
                    flake-path
                    ;
                };
                inherit system;
                modules = [
                  { nixpkgs.overlays = overlays; }
                  disko.nixosModules.disko
                  ./disko/PCs/sda_swap.nix
                  ./systems/PCs/dustbook
                ];
              };
              "my-qemu-vm" = nixpkgs.lib.nixosSystem {
                specialArgs = {
                  hostname = "virtbird";
                  inherit
                    nixpkgs
                    stateVersion
                    self
                    inputs
                    users
                    system-modules
                    overlays
                    flake-path
                    ;
                };
                inherit system;
                modules = [
                  home-manager.nixosModules.home-manager
                  ./systems/VMs/qemu
                  (
                    { lib, ... }:
                    {
                      nixpkgs.overlays = overlays;
                      home-manager.useGlobalPkgs = true;
                      home-manager.useUserPackages = true;
                      home-manager.users.birdee = import ./homes/birdee.nix;
                      home-manager.backupFileExtension = "hm-bkp";
                      home-manager.verbose = true;
                      home-manager.extraSpecialArgs = {
                        username = "birdee";
                        monitorCFG = null;
                        inherit
                          nixpkgs
                          stateVersion
                          self
                          system
                          inputs
                          users
                          home-modules
                          flake-path
                          ;
                      };
                      services.displayManager.defaultSession = lib.mkDefault "none+fake";
                    }
                  )
                ];
              };
              "installer" = inputs.nixpkgsNV.lib.nixosSystem {
                specialArgs = {
                  nixpkgs = inputs.nixpkgsNV;
                  inherit
                    self
                    inputs
                    system-modules
                    overlays
                    ;
                };
                inherit system;
                modules = [
                  { nixpkgs.overlays = overlays; }
                  ./systems/PCs/installer
                ];
              };
            };
        };
    }));
}
