{
  lib,
  flake-parts-lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib) types mkOption genAttrs;
  file = ./configsPerSystem.nix;
  hubutils = config.flake.util;
  mkHMdir =
    pkgs: username:
    let
      homeDirPrefix = if pkgs.stdenv.hostPlatform.isDarwin then "Users" else "home";
      homeDirectory = "/${homeDirPrefix}/${username}";
    in
    homeDirectory;
in
{
  _file = file;
  key = file;
  options = {
    perSystem = flake-parts-lib.mkPerSystemOption (
      { system, pkgs, ... }:
      {
        _file = file;
        key = file;
        options.nixosConfigurations = mkOption {
          type = types.attrsOf (
            types.submodule (
              { config, name, ... }:
              {
                _file = file;
                key = file;
                freeformType = inputs.wrappers.lib.types.attrsRecursive;
                options = {
                  home-manager = mkOption {
                    type = types.raw;
                    default = null;
                  };
                  nixpkgs = mkOption {
                    type = types.raw;
                    default = inputs.nixpkgs or null;
                  };
                  extraSpecialArgs = mkOption {
                    type = types.attrsOf types.raw;
                    default = { };
                  };
                  specialArgs = mkOption {
                    type = types.attrsOf types.raw;
                    default = { };
                    apply =
                      x:
                      x
                      // {
                        util = hubutils;
                        inherit (config) hostname username;
                        inherit inputs;
                      };
                  };
                  system = mkOption {
                    type = types.str;
                    default = system;
                  };
                  hostname = mkOption {
                    type = types.str;
                    default =
                      if config.home-manager != null then
                        let
                          matchres = builtins.match ".+@(.+)" name;
                        in
                        if matchres != null && builtins.length matchres > 0 then builtins.head matchres else name
                      else
                        name;
                  };
                  username = mkOption {
                    type = types.nullOr types.str;
                    default =
                      if config.home-manager != null then
                        let
                          matchres = builtins.match "(.+)@.+" name;
                        in
                        if matchres != null && builtins.length matchres > 0 then builtins.head matchres else null
                      else
                        null;
                  };
                  config = mkOption {
                    type = types.deferredModule;
                    default = { };
                  };
                  modules = mkOption {
                    type = types.listOf types.raw;
                    default = [ ];
                    apply =
                      x:
                      lib.optionals (config.home-manager != null) [
                        (config.home-manager.nixosModules.home-manager or { })
                        {
                          config.home-manager.extraSpecialArgs = config.specialArgs // config.extraSpecialArgs;
                        }
                      ]
                      ++ lib.optional (config.home-manager != null && config.username != null) {
                        config.home-manager.users.${config.username} =
                          { pkgs, ... }:
                          {
                            home.username = config.username;
                            home.homeDirectory = lib.mkDefault (mkHMdir pkgs config.username);
                          };
                      }
                      ++ [ config.config ]
                      ++ x;
                  };
                };
              }
            )
          );
          default = { };
          description = ''
            `perSystem.nixosConfigurations.<name> = flake.legacyPackages.$${system}.nixosConfigurations.<name>`
            Warning: will conflict with existing `flake.legacyPackages.$${system}.nixosConfigurations.<name>` definitions
          '';
        };
        options.homeConfigurations = mkOption {
          type = types.attrsOf (
            types.submodule (
              { config, name, ... }:
              {
                freeformType = inputs.wrappers.lib.types.attrsRecursive;
                options = {
                  home-manager = mkOption {
                    type = types.raw;
                    default = inputs.home-manager or null;
                  };
                  username = mkOption {
                    type = types.str;
                    default =
                      let
                        matchres = builtins.match "(.+)@.+" name;
                      in
                      if matchres != null && builtins.length matchres > 0 then builtins.head matchres else name;
                  };
                  pkgs = mkOption {
                    type = types.raw;
                    default = pkgs;
                  };
                  extraSpecialArgs = mkOption {
                    type = types.attrsOf types.raw;
                    default = { };
                    apply =
                      x:
                      x
                      // {
                        util = hubutils;
                        inherit (config) username;
                        inherit inputs;
                      };
                  };
                  config = mkOption {
                    type = types.deferredModule;
                    default = { };
                  };
                  modules = mkOption {
                    type = types.listOf types.raw;
                    default = [ ];
                    apply =
                      x:
                      [
                        (
                          { pkgs, ... }:
                          {
                            home.username = config.username;
                            home.homeDirectory = lib.mkDefault (mkHMdir pkgs config.username);
                          }
                        )
                        config.config
                      ]
                      ++ x;
                  };
                };
              }
            )
          );
          default = { };
          description = ''
            `perSystem.homeConfigurations.<name> = flake.legacyPackages.$${system}.homeConfigurations.<name>`
            Warning: will conflict with existing `flake.legacyPackages.$${system}.homeConfigurations.<name>` definitions
          '';
        };
      }
    );
  };

  config = {
    flake.legacyPackages = genAttrs config.systems (system: {
      homeConfigurations = builtins.mapAttrs (
        n: v:
        v.home-manager.lib.homeManagerConfiguration (
          builtins.removeAttrs v [
            "home-manager"
            "username"
            "config"
          ]
        )
      ) (config.perSystem system).homeConfigurations;
      nixosConfigurations = builtins.mapAttrs (
        n: v:
        v.nixpkgs.lib.nixosSystem (
          builtins.removeAttrs v [
            "nixpkgs"
            "config"
            "extraSpecialArgs"
            "hostname"
            "username"
            "home-manager"
          ]
        )
      ) (config.perSystem system).nixosConfigurations;
    });
  };
}
