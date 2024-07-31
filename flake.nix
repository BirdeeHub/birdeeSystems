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
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
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
    "plugins-fugit2.nvim" = {
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
    "plugins-otter.nvim" = {
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
      flake-parts,
      ...
    }@inputs:
    let
      # NOTE: setup
      flake-path = "/home/birdee/birdeeSystems";
      stateVersion = "23.05";
      overlaysPre = (import ./overlays inputs);
      overlayList = overlaysPre.overlayList;
      overlaySet = overlaysPre.overlaySet;
      common = import ./common { inherit inputs flake-path; };
      home-modules = common { homeModule = true; };
      system-modules = common { homeModule = false; };
      # factor out declaring home manager as a module for configs that do that
      HMasModule =
        { users, monitorCFG ? null, username, hmCFGmodMAIN, }:
        { lib, ... }:
        {
          nixpkgs.overlays = overlayList;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.birdee = hmCFGmodMAIN; # import ./homes/birdee.nix;
          home-manager.backupFileExtension = "hm-bkp";
          home-manager.verbose = true;
          home-manager.extraSpecialArgs = {
            inherit
              stateVersion
              self
              inputs
              home-modules
              flake-path
              username # username = "birdee";
              users
              ;
          } // (if monitorCFG == null then {} else { inherit monitorCFG;}); # monitorCFG = ./homes/monitors_by_hostname/<hostname>;
          services.displayManager.defaultSession = lib.mkDefault "none+fake";
        };

    in
    # NOTE: flake parts definitions
    # https://flake.parts/options/flake-parts
    # https://devenv.sh/reference/options
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.platforms.all;
      imports =
        let
          myMods = import ./flakeModules;
        in
        [
          # inputs.flake-parts.flakeModules.easyOverlay
          inputs.devenv.flakeModule
          myMods.nixosCFGperSystem
          myMods.homeCFGperSystem
          myMods.appImagePerSystem

          # e.g. treefmt-nix.flakeModule
        ];
      flake = {
        homeModules = home-modules // { birdeeVim = home-modules.birdeeVim.homeModule; };
        diskoConfigurations = {
          PC_sda_swap = import ./disko/PCs/sda_swap.nix;
          PC_sdb_swap = import ./disko/PCs/sdb_swap.nix;
        };
        overlays = home-modules.birdeeVim.overlays // overlaySet // { };
        nixosModules = system-modules // { birdeeVim = system-modules.birdeeVim.nixosModules.default; };
        templates = import ./templates inputs;
        flakeModules = import ./flakeModules;
        birdeeVim = home-modules.birdeeVim;
      };
      perSystem =
        {
          config,
          self',
          inputs',
          lib,
          pkgs,
          system,
          # final, # Only with easyOverlay imported
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgsNV {
            inherit system;
            overlays = overlayList;
            config = {
              allowUnfree = true;
            };
          };

          # overlayAttrs = { outname = config.packages.packagename; }; # Only with easyOverlay imported

          packages = home-modules.birdeeVim.packages.${system} // {
            inherit (pkgs) dep-tree minesweeper;
          };

          app-images =
            home-modules.birdeeVim.app-images.${system}
            // (
              let
                bundle = nix-appimage.bundlers.${system}.default;
              in
              {
                minesweeper = bundle pkgs.minesweeper;
              }
            );

          # NOTE: outputs to legacyPackages.${system}.homeConfigurations.<name>
          homeConfigurations =
            let
              users = import ./userdata pkgs;
            in
            {
              "birdee@dustbook" = home-manager.lib.homeManagerConfiguration {
                extraSpecialArgs = {
                  username = "birdee";
                  monitorCFG = ./homes/monitors_by_hostname/dustbook;
                  inherit
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

          # NOTE: outputs to legacyPackages.${system}.nixosConfigurations.<name>
          nixosConfigurations =
            let
              users = import ./userdata pkgs;
            in
            {
              "birdee@nestOS" = nixpkgs.lib.nixosSystem {
                specialArgs = {
                  hostname = "nestOS";
                  inherit
                    stateVersion
                    self
                    inputs
                    users
                    system-modules
                    flake-path
                    ;
                };
                inherit system;
                modules = [
                  home-manager.nixosModules.home-manager
                  disko.nixosModules.disko
                  ./disko/PCs/sda_swap.nix
                  ./systems/PCs/aSUS
                  (HMasModule {
                    monitorCFG = ./homes/monitors_by_hostname/nestOS;
                    username = "birdee";
                    inherit users;
                    hmCFGmodMAIN = import ./homes/birdee.nix;
                  })
                ];
              };
              "birdee@dustbook" = nixpkgs.lib.nixosSystem {
                specialArgs = {
                  hostname = "dustbook";
                  inherit
                    stateVersion
                    users
                    self
                    inputs
                    system-modules
                    flake-path
                    ;
                };
                inherit system;
                modules = [
                  home-manager.nixosModules.home-manager
                  disko.nixosModules.disko
                  ./disko/PCs/sda_swap.nix
                  ./systems/PCs/dustbook
                  (HMasModule {
                    monitorCFG = ./homes/monitors_by_hostname/dustbook;
                    username = "birdee";
                    inherit users;
                    hmCFGmodMAIN = import ./homes/birdee.nix;
                  })
                ];
              };
              "nestOS" = nixpkgs.lib.nixosSystem {
                specialArgs = {
                  hostname = "nestOS";
                  inherit
                    stateVersion
                    self
                    inputs
                    users
                    system-modules
                    flake-path
                    ;
                };
                inherit system;
                modules = [
                  { nixpkgs.overlays = overlayList; }
                  disko.nixosModules.disko
                  ./disko/PCs/sda_swap.nix
                  ./systems/PCs/aSUS
                ];
              };
              "dustbook" = nixpkgs.lib.nixosSystem {
                specialArgs = {
                  hostname = "dustbook";
                  inherit
                    stateVersion
                    self
                    inputs
                    users
                    system-modules
                    flake-path
                    ;
                };
                inherit system;
                modules = [
                  { nixpkgs.overlays = overlayList; }
                  disko.nixosModules.disko
                  ./disko/PCs/sda_swap.nix
                  ./systems/PCs/dustbook
                ];
              };
              "my-qemu-vm" = nixpkgs.lib.nixosSystem {
                specialArgs = {
                  hostname = "virtbird";
                  inherit
                    stateVersion
                    self
                    inputs
                    users
                    system-modules
                    flake-path
                    ;
                };
                inherit system;
                modules = [
                  home-manager.nixosModules.home-manager
                  ./systems/VMs/qemu
                  (HMasModule {
                    username = "birdee";
                    inherit users;
                    hmCFGmodMAIN = import ./homes/birdee.nix;
                  })
                ];
              };
              "installer" = inputs.nixpkgsNV.lib.nixosSystem {
                specialArgs = {
                  inherit self inputs system-modules;
                };
                inherit system;
                modules = [
                  { nixpkgs.overlays = overlayList; }
                  ./systems/PCs/installer
                ];
              };
            };
        };
    };
}
