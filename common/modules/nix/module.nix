{ inputs, moduleNamespace, ... }:
let
  name = "nix";
in
{
  flake.modules.nixos.${name} =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.${moduleNamespace}.${name};
    in
    {
      options.${moduleNamespace}.${name}.enable = lib.mkEnableOption "birdee's nix.conf";
      config = lib.mkIf cfg.enable {
        nix.settings = {
          # bash-prompt-prefix = "✓";
          extra-trusted-substituters = [
            "https://nix-community.cachix.org"
          ];
          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
          ];
          show-trace = true;
          auto-optimise-store = true;
          flake-registry = "";
          extra-trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
          trusted-users = [ "@wheel" ];
        };
        nix.extraOptions = ''
          !include /home/birdee/.secrets/gitoke
        '';
        # nix.extraOptions = ''
        #   plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins
        # '';

        # Allow unfree packages
        nixpkgs.config.allowUnfree = true;

        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "-d";
          persistent = true;
        };
      };
    };
  flake.modules.homeManager.${name} =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.${moduleNamespace}.${name};
    in
    {
      options.${moduleNamespace}.${name}.enable = lib.mkEnableOption "birdee's nix.conf";
      config = lib.mkIf cfg.enable {
        nix.settings = {
          # bash-prompt-prefix = "✓";
          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
          ];
          auto-optimise-store = true;
          flake-registry = "";
          show-trace = true;
          extra-trusted-substituters = [
            "https://nix-community.cachix.org"
          ];
          extra-trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
        nix.extraOptions = ''
          !include /home/birdee/.secrets/gitoke
        '';
        nix.nixPath = [
          "nixpkgs=${builtins.path { path = inputs.nixpkgs; }}"
        ];
        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "-d";
        };
        nix.registry = {
          nixpkgs.flake = inputs.nixpkgs;
          wrappers.flake = inputs.wrappers;
          home-manager.flake = inputs.home-manager;
          birdeeSystems.flake = inputs.self;
          gomod2nix.to = {
            type = "github";
            owner = "nix-community";
            repo = "gomod2nix";
          };
        };
      };
    };
}
