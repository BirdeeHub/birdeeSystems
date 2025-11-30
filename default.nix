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
  common = import ./common { inherit inputs; };
  inherit (common) birdeeutils;
  my_common_hub = common.hub {};
  inherit (my_common_hub) system-modules home-modules overlaySet flakeModules diskoCFG templates userdata;
  packages_func = my_common_hub.packages;
  overlayList = builtins.attrValues overlaySet;
  # factor out declaring home manager as a module for configs that do that
  HMasModule =
    { users, monitorCFG ? null, username, hmCFGmodMAIN, }:
    { pkgs, lib, ... }:
    {
      nixpkgs.overlays = overlayList;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.birdee = hmCFGmodMAIN; # import ./homes/birdee.nix;
      home-manager.backupFileExtension = "hm-bkp";
      home-manager.verbose = true;
      home-manager.extraSpecialArgs = {
        my_pkgs = packages_func pkgs.system;
        inherit
          stateVersion
          self
          inputs
          home-modules
          flake-path
          username # username = "birdee";
          users
          monitorCFG
          birdeeutils
          ;
      }; # monitorCFG = ./homes/monitors_by_hostname/<hostname>;
      services.displayManager.defaultSession = lib.mkDefault "none+fake";
    };

in
# NOTE: flake parts definitions
# https://flake.parts/options/flake-parts
# https://devenv.sh/reference/options
flake-parts.lib.mkFlake { inherit inputs; } {
  systems = nixpkgs.lib.platforms.all;
  imports = [
    # inputs.flake-parts.flakeModules.easyOverlay
    inputs.devenv.flakeModule
    flakeModules.nixosCFGperSystem
    flakeModules.homeCFGperSystem
    flakeModules.appImagePerSystem

    # e.g. treefmt-nix.flakeModule
  ];
  flake = {
    diskoConfigurations = {
      sda_swap = diskoCFG.PCs.sda_swap;
      sdb_swap = diskoCFG.PCs.sdb_swap;
      dustbook = diskoCFG.PCs.sda_swap;
      aSUS = diskoCFG.PCs.sda_swap;
      "virtbird" = diskoCFG.VMs.noswap_bios;
      "birdee@aSUS" = diskoCFG.PCs.sda_swap;
      "birdee@dustbook" = diskoCFG.PCs.sda_swap;
      "birdee@nestOS" = diskoCFG.PCs.nvme0n1_swap;
    };
    overlays = overlaySet // { };
    nixosModules = system-modules // {
      birdeevim = self.legacyPackages.x86_64-linux.homeConfigurations."birdee@dustbook".config.birdeevim.out.packages.birdeevim.nixosModule;
    };
    homeModules = home-modules // {
      birdeevim = self.legacyPackages.x86_64-linux.homeConfigurations."birdee@dustbook".config.birdeevim.out.packages.birdeevim.homeModule;
    };
    inherit flakeModules templates birdeeutils;
  };
  perSystem = {
    config,
    self',
    inputs',
    lib,
    pkgs,
    system,
    # final, # Only with easyOverlay imported
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgsNV {
      inherit system;
      overlays = overlayList;
      config = {
        allowUnfree = true;
      };
    };

    # overlayAttrs = { outname = config.packages.packagename; }; # Only with easyOverlay imported

    packages = (packages_func system) // {
      inherit (pkgs) dep-tree minesweeper nops manix tmux wezterm antifennel luakitkat opencode git_with_config ranger alakitty;
    } // self.legacyPackages.${system}.homeConfigurations."birdee@dustbook".config.birdeevim.out.packages;

    app-images = let
      bundle = nix-appimage.bundlers.${system}.default;
    in {
      minesweeper = bundle pkgs.minesweeper;
    };

    # NOTE: outputs to legacyPackages.${system}.homeConfigurations.<name>
    homeConfigurations = let users = userdata pkgs; in {
      "birdee@dustbook" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          username = "birdee";
          monitorCFG = ./homes/monitors_by_hostname/dustbook;
          my_pkgs = packages_func system;
          inherit
            stateVersion
            self
            system
            inputs
            users
            home-modules
            flake-path
            birdeeutils
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
      "birdee@aSUS" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          username = "birdee";
          monitorCFG = ./homes/monitors_by_hostname/aSUS;
          my_pkgs = packages_func system;
          inherit
            stateVersion
            self
            system
            inputs
            users
            home-modules
            flake-path
            birdeeutils
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
    nixosConfigurations = let users = userdata pkgs; in {
      "birdee@nestOS" = inputs.nixpkgsNV.lib.nixosSystem {
        specialArgs = {
          hostname = "nestOS";
          my_pkgs = packages_func system;
          inherit
            stateVersion
            self
            inputs
            users
            system-modules
            flake-path
            birdeeutils
            ;
        };
        inherit system;
        modules = [
          home-manager.nixosModules.home-manager
          disko.nixosModules.disko
          diskoCFG.PCs.nvme0n1_swap
          ./systems/PCs/nestOS
          (HMasModule {
            monitorCFG = ./homes/monitors_by_hostname/nestOS;
            username = "birdee";
            inherit users;
            hmCFGmodMAIN = import ./homes/main;
          })
        ];
      };
      "birdee@aSUS" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hostname = "aSUS";
          my_pkgs = packages_func system;
          inherit
            stateVersion
            self
            inputs
            users
            system-modules
            flake-path
            birdeeutils
            ;
        };
        inherit system;
        modules = [
          home-manager.nixosModules.home-manager
          disko.nixosModules.disko
          diskoCFG.PCs.sda_swap
          ./systems/PCs/aSUS
          (HMasModule {
            monitorCFG = ./homes/monitors_by_hostname/aSUS;
            username = "birdee";
            inherit users;
            hmCFGmodMAIN = import ./homes/birdee.nix;
          })
        ];
      };
      "birdee@dustbook" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hostname = "dustbook";
          my_pkgs = packages_func system;
          inherit
            stateVersion
            users
            self
            inputs
            system-modules
            flake-path
            birdeeutils
            ;
        };
        inherit system;
        modules = [
          home-manager.nixosModules.home-manager
          disko.nixosModules.disko
          diskoCFG.PCs.sda_swap
          ./systems/PCs/dustbook
          (HMasModule {
            monitorCFG = ./homes/monitors_by_hostname/dustbook;
            username = "birdee";
            inherit users;
            hmCFGmodMAIN = import ./homes/birdee.nix;
          })
        ];
      };
      "aSUS" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hostname = "aSUS";
          my_pkgs = packages_func system;
          inherit
            stateVersion
            self
            inputs
            users
            system-modules
            flake-path
            birdeeutils
            ;
        };
        inherit system;
        modules = [
          { nixpkgs.overlays = overlayList; }
          disko.nixosModules.disko
          diskoCFG.PCs.sda_swap
          ./systems/PCs/aSUS
        ];
      };
      "dustbook" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hostname = "dustbook";
          my_pkgs = packages_func system;
          inherit
            stateVersion
            self
            inputs
            users
            system-modules
            flake-path
            birdeeutils
            ;
        };
        inherit system;
        modules = [
          { nixpkgs.overlays = overlayList; }
          disko.nixosModules.disko
          diskoCFG.PCs.sda_swap
          ./systems/PCs/dustbook
        ];
      };
      "virtbird" = nixpkgs.lib.nixosSystem (let
        hostname = "virtbird";
        username = "birdee";
      in {
        specialArgs = {
          my_pkgs = packages_func system;
          inherit
            stateVersion
            self
            inputs
            users
            system-modules
            flake-path
            birdeeutils
            hostname
            username
            ;
        };
        inherit system;
        modules = [
          # home-manager.nixosModules.home-manager
          { nixpkgs.overlays = overlayList; }
          disko.nixosModules.disko
          self.diskoConfigurations.${hostname}
          ./systems/VMs/${hostname}
          # (HMasModule {
          #   username = "birdee";
          #   inherit users;
          #   hmCFGmodMAIN = import ./homes/birdee.nix;
          # })
        ];
      });
      "my-qemu-vm" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hostname = "virtbird";
          username = "birdee";
          my_pkgs = packages_func system;
          inherit
            stateVersion
            self
            inputs
            users
            system-modules
            flake-path
            birdeeutils
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
      "installer_mine" = inputs.nixpkgsNV.lib.nixosSystem {
        specialArgs = {
          hostname = "installer_mine";
          is_minimal = true;
          use_alacritty = false;
          my_pkgs = packages_func system;
          inherit
            stateVersion
            self
            inputs
            users
            system-modules
            flake-path
            birdeeutils
            ;
        };
        inherit system;
        modules = [
          { nixpkgs.overlays = overlayList; }
          ./systems/installers/installer_mine
          # home-manager.nixosModules.home-manager
          # (HMasModule {
          #   username = "birdee";
          #   inherit users;
          #   hmCFGmodMAIN = import ./homes/birdee.nix;
          # })
        ];
      };
      "installer" = inputs.nixpkgsNV.lib.nixosSystem {
        specialArgs = {
          my_pkgs = packages_func system;
          inherit self inputs system-modules birdeeutils;
        };
        inherit system;
        modules = [
          { nixpkgs.overlays = overlayList; }
          ./systems/installers/installer
        ];
      };
    };
  };
}
