{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { self, nixpkgs, flake-parts, systems, ... }@inputs: let
    APPNAME = "REPLACE_ME";
  in
  flake-parts.lib.mkFlake {inherit inputs;} {
    systems = import systems;
    imports = [
      inputs.flake-parts.flakeModules.easyOverlay
      inputs.devenv.flakeModule
      # e.g. treefmt-nix.flakeModule
    ];
    flake = {
      # typical flake output definition..
      # anything you'd normally put in result of `outputs = inputs: flake`
    };
    perSystem = {
      config,
      self',
      inputs',
      lib,
      pkgs,
      system,
      final,
      ...
    }: {
      _module.args.pkgs = import nixpkgs {
        inherit system;
        overlays = [];
        config = {};
      };
      overlayAttrs = {
        ${APPNAME} = config.packages.${APPNAME};
      };
      packages = {
        default = config.packages.${APPNAME};
        ${APPNAME} = pkgs.callPackage ./. { inherit APPNAME; };
      };
      devenv.shells.devenv = {
        # https://devenv.sh/reference/options/
        packages = [ config.packages.default ];
        languages.nix = {
          enable = true;
        };
        languages.java = {
          enable = true;
        };
        env.DEVSHELL = 0;

        enterShell = ''
          echo "${APPNAME} shell"
        '';
      };
      devShells = {
        default = pkgs.callPackage ./shell.nix {
          inherit APPNAME;
          shellPkg = "${pkgs.zsh}/bin/zsh";
        };
      };
      # etc. ...
    };
  };
}
