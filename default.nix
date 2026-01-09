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
  stateVersion = "25.11";
  common = import ./common { inherit inputs; };
  inherit (common) util;
  my_common_hub = common.hub {};
  inherit (my_common_hub) system-modules home-modules overlaySet overlayList flakeModules diskoCFG templates userdata wrappers;
  # factor out declaring home manager as a module for configs that do that
  HMasModule =
    { lib, ... }:
    {
      nixpkgs.overlays = overlayList;
      home-manager.backupFileExtension = "hm-bkp";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
      home-manager.extraSpecialArgs = { inherit home-modules ; };
      services.displayManager.defaultSession = lib.mkDefault "none+fake";
    };
  HMmain = module: { username, ... }: { home-manager.users.${username} = module; };
in
# NOTE: flake parts definitions
# https://flake.parts/options/flake-parts
# https://devenv.sh/reference/options
flake-parts.lib.mkFlake { inherit inputs; } {
  systems = nixpkgs.lib.platforms.all;
  imports = [
    # inputs.flake-parts.flakeModules.easyOverlay
    # inputs.devenv.flakeModule
    inputs.flake-parts.flakeModules.flakeModules
    flakeModules.hub

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
    inherit templates util flakeModules;
    inherit (wrappers) modules wrapperModules;
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
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = overlayList;
      config = {
        allowUnfree = true;
      };
    };

    # overlayAttrs = { outname = config.packages.packagename; }; # Only with easyOverlay imported

    packages = {
      inherit (pkgs) dep-tree minesweeper nops manix tmux wezterm antifennel luakit opencode git_with_config ranger alacritty starship xplr nushell bemenu gac libvma;
      wezshterm = pkgs.wezterm.wrap {
        withLauncher = lib.mkDefault true;
        wrapZSH = lib.mkDefault true;
      };
    } // self.legacyPackages.${system}.homeConfigurations."birdee@dustbook".config.birdeevim.out.packages;

    app-images = let
      bundle = nix-appimage.bundlers.${system}.default;
    in {
      minesweeper = bundle pkgs.minesweeper;
    };

    # NOTE: outputs to legacyPackages.${system}.homeConfigurations.<name>
    homeConfigurations = let users = userdata pkgs; in {
      "birdee@dustbook" = {
        inherit home-manager;
        extraSpecialArgs = {
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
      "birdee@aSUS" = {
        inherit home-manager;
        extraSpecialArgs = {
          monitorCFG = ./homes/monitors_by_hostname/aSUS;
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
      "birdee@nestOS" = {
        nixpkgs = inputs.nixpkgs;
        inherit home-manager;
        specialArgs = {
          inherit
            stateVersion
            self
            inputs
            users
            system-modules
            flake-path
            ;
        };
        extraSpecialArgs = {
          monitorCFG = ./homes/monitors_by_hostname/nestOS;
        };
        modules = [
          disko.nixosModules.disko
          diskoCFG.PCs.nvme0n1_swap
          ./systems/PCs/nestOS
          (HMmain (import ./homes/main))
          HMasModule
        ];
      };
      "birdee@aSUS" = {
        nixpkgs = inputs.nixpkgsOLD;
        inherit home-manager;
        specialArgs = {
          inherit
            stateVersion
            self
            inputs
            users
            system-modules
            flake-path
            ;
        };
        extraSpecialArgs = {
          monitorCFG = ./homes/monitors_by_hostname/aSUS;
        };
        modules = [
          disko.nixosModules.disko
          diskoCFG.PCs.sda_swap
          ./systems/PCs/aSUS
          (HMmain (import ./homes/birdee.nix))
          HMasModule
        ];
      };
      "birdee@dustbook" = {
        nixpkgs = inputs.nixpkgsOLD;
        inherit home-manager;
        specialArgs = {
          inherit
            stateVersion
            users
            self
            inputs
            system-modules
            flake-path
            ;
        };
        extraSpecialArgs = {
          monitorCFG = ./homes/monitors_by_hostname/dustbook;
        };
        modules = [
          disko.nixosModules.disko
          diskoCFG.PCs.sda_swap
          ./systems/PCs/dustbook
          (HMmain (import ./homes/birdee.nix))
          HMasModule
        ];
      };
      "aSUS" = {
        nixpkgs = inputs.nixpkgsOLD;
        specialArgs = {
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
          diskoCFG.PCs.sda_swap
          ./systems/PCs/aSUS
        ];
      };
      "dustbook" = {
        nixpkgs = inputs.nixpkgsOLD;
        specialArgs = {
          inherit
            stateVersion
            self
            inputs
            users
            system-modules
            flake-path
            ;
        };
        modules = [
          { nixpkgs.overlays = overlayList; }
          disko.nixosModules.disko
          diskoCFG.PCs.sda_swap
          ./systems/PCs/dustbook
        ];
      };
      "virtbird" = (let
      in {name, ... }: {
        nixpkgs = inputs.nixpkgs;
        username = "birdee";
        specialArgs = {
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
          self.diskoConfigurations.${name}
          ./systems/VMs/${name}
        ];
      });
      "my-qemu-vm" = {
        nixpkgs = inputs.nixpkgs;
        inherit home-manager;
        hostname = "virtbird";
        username = "birdee";
        specialArgs = {
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
          ./systems/VMs/qemu
          (HMmain (import ./homes/birdee.nix))
          HMasModule
        ];
      };
      "installer_mine" = {
        nixpkgs = inputs.nixpkgs;
        specialArgs = {
          is_minimal = true;
          use_alacritty = false;
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
          ./systems/installers/installer_mine
        ];
      };
      "installer" = {
        nixpkgs = inputs.nixpkgs;
        specialArgs = {
          inherit self inputs system-modules;
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
