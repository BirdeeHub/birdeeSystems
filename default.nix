{
  self,
  nixpkgs,
  home-manager,
  nix-appimage,
  flake-parts,
  ...
}@inputs:
let
  # NOTE: setup
  flake-path = "/home/birdee/birdeeSystems";
  stateVersion = "25.11";
  # factor out declaring home manager as a module for configs that do that
  HMasModule =
    { lib, ... }:
    {
      home-manager.backupFileExtension = "hm-bkp";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
      services.displayManager.defaultSession = lib.mkDefault "none+fake";
    };
  HMmain = module: { username, ... }: { home-manager.users.${username} = module; };
in
# NOTE: flake parts definitions
# https://flake.parts/options/flake-parts
# https://devenv.sh/reference/options
flake-parts.lib.mkFlake { inherit inputs; } ({ config, ... }: let
  overlayList = config.flake.overlist;
  userdata = pkgs: {
    birdee = {
      name = "birdee";
      shell = pkgs.zsh;
      isNormalUser = true;
      description = "";
      extraGroups = [ "networkmanager" "wheel" "docker" "vboxusers" ];
      # this is packages for nixOS user config.
      # packages = []; # empty because that is managed by home-manager
    };
  };
in {
  systems = nixpkgs.lib.platforms.all;
  imports = [
    # inputs.flake-parts.flakeModules.easyOverlay
    # inputs.devenv.flakeModule
    # e.g. treefmt-nix.flakeModule
    (nixpkgs.lib.modules.importApply ./common inputs)
  ];
  perSystem = let
    flakeCfg = config.flake;
  in {
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

    # Make sure the exported wrapper module packages
    # don't get a pkgs with the items already imported
    # This is because we also added our wrapper modules
    # into our overlayList
    wrapperPkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    packages = {
      inherit (pkgs) dep-tree minesweeper nops manix antifennel gac libvma;
      wezshterm = config.packages.wezterm.wrap {
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
    homeConfigurations = let
      defaultSpecialArgs = {
        users = userdata pkgs;
        inherit
          stateVersion
          inputs
          flake-path
          ;
      };
    in {
      "birdee@dustbook" = {
        inherit home-manager;
        extraSpecialArgs = defaultSpecialArgs // {
          monitorCFG = ./homes/monitors_by_hostname/dustbook;
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
        extraSpecialArgs = defaultSpecialArgs // {
          monitorCFG = ./homes/monitors_by_hostname/aSUS;
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
    nixosConfigurations = let
      defaultSpecialArgs = {
        users = userdata pkgs;
        inherit
          stateVersion
          inputs
          flake-path
          ;
      };
    in {
      "birdee@nestOS" = {
        nixpkgs = inputs.nixpkgs;
        inherit home-manager;
        disko.diskoModule = flakeCfg.diskoConfigurations.nvme0n1_swap;
        specialArgs = defaultSpecialArgs;
        extraSpecialArgs = {
          monitorCFG = ./homes/monitors_by_hostname/nestOS;
        };
        module.nixpkgs.overlays = overlayList;
        modules = [
          ./systems/PCs/nestOS
          (HMmain (import ./homes/main))
          HMasModule
        ];
      };
      "birdee@aSUS" = {
        nixpkgs = inputs.nixpkgsOLD;
        inherit home-manager;
        disko.diskoModule = flakeCfg.diskoConfigurations.sda_swap;
        specialArgs = defaultSpecialArgs;
        extraSpecialArgs = {
          monitorCFG = ./homes/monitors_by_hostname/aSUS;
        };
        module.nixpkgs.overlays = overlayList;
        modules = [
          ./systems/PCs/aSUS
          (HMmain (import ./homes/birdee.nix))
          HMasModule
        ];
      };
      "birdee@dustbook" = {
        nixpkgs = inputs.nixpkgsOLD;
        disko.diskoModule = flakeCfg.diskoConfigurations.sda_swap;
        inherit home-manager;
        specialArgs = defaultSpecialArgs;
        extraSpecialArgs = {
          monitorCFG = ./homes/monitors_by_hostname/dustbook;
        };
        module.nixpkgs.overlays = overlayList;
        modules = [
          ./systems/PCs/dustbook
          (HMmain (import ./homes/birdee.nix))
          HMasModule
        ];
      };
      "aSUS" = {
        nixpkgs = inputs.nixpkgsOLD;
        disko.diskoModule = flakeCfg.diskoConfigurations.sda_swap;
        specialArgs = defaultSpecialArgs;
        module.nixpkgs.overlays = overlayList;
        modules = [
          ./systems/PCs/aSUS
        ];
      };
      "dustbook" = {
        nixpkgs = inputs.nixpkgsOLD;
        disko.diskoModule = flakeCfg.diskoConfigurations.sda_swap;
        specialArgs = defaultSpecialArgs;
        module.nixpkgs.overlays = overlayList;
        modules = [
          ./systems/PCs/dustbook
        ];
      };
      "virtbird" = (let
      in {name, ... }: {
        nixpkgs = inputs.nixpkgs;
        username = "birdee";
        disko.diskoModule = flakeCfg.diskoConfigurations.noswap_bios;
        specialArgs = defaultSpecialArgs;
        module.nixpkgs.overlays = overlayList;
        modules = [
          ./systems/VMs/${name}
        ];
      });
      "my-qemu-vm" = {
        nixpkgs = inputs.nixpkgs;
        inherit home-manager;
        hostname = "virtbird";
        disko.diskoModule = flakeCfg.diskoConfigurations.noswap_bios;
        username = "birdee";
        specialArgs = defaultSpecialArgs;
        module.nixpkgs.overlays = overlayList;
        modules = [
          ./systems/VMs/qemu
          (HMmain (import ./homes/birdee.nix))
          HMasModule
        ];
      };
      "installer_mine" = {
        nixpkgs = inputs.nixpkgs;
        specialArgs = defaultSpecialArgs // {
          is_minimal = true;
          use_alacritty = false;
        };
        extraSpecialArgs = {
        };
        module.nixpkgs.overlays = overlayList;
        modules = [
          ./systems/installers/installer_mine
        ];
      };
      "installer" = {
        nixpkgs = inputs.nixpkgs;
        specialArgs = defaultSpecialArgs;
        module.nixpkgs.overlays = overlayList;
        modules = [
          ./systems/installers/installer
        ];
      };
    };
  };
})
