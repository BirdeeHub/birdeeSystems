inputs:
let
  wlib = inputs.wrappers.lib;
  diskoflake = inputs.disko;
in
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
  diskos = config.flake.diskoConfigurations or { };
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
          type = types.lazyAttrsOf (
            types.submodule (
              { config, name, ... }:
              {
                _file = file;
                key = file;
                freeformType = wlib.types.attrsRecursive;
                options = {
                  home-manager = mkOption {
                    type = types.raw;
                    default = null;
                  };
                  nixpkgs = mkOption {
                    type = types.raw;
                    default = inputs.nixpkgs or null;
                  };
                  system = mkOption {
                    type = types.str;
                    readOnly = true;
                    default = system;
                  };
                  extraSpecialArgs = mkOption {
                    type = types.lazyAttrsOf types.raw;
                    default = { };
                  };
                  specialArgs = mkOption {
                    type = types.lazyAttrsOf types.raw;
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
                  disko = mkOption {
                    type = wlib.types.subWrapperModuleWith {
                      modules =
                        let
                          inherit (config) nixpkgs;
                        in
                        [
                          (
                            { config, wlib, ... }: let
                              diskoflakedir = "${placeholder "out"}/${config.binName}-${name}";
                            in
                            {
                              imports = [ wlib.modules.default ];
                              config.pkgs = nixpkgs.legacyPackages.${system} or (import nixpkgs { inherit system; });
                              options.diskoModule = mkOption {
                                type = types.nullOr (lib.types.either wlib.types.stringable (pkgs.formats.json {}).type);
                                default = null;
                                apply = x: if x == null then diskos.${name} or null else x; 
                              };
                              config.flags."--no-deps" = lib.mkDefault true;
                              config.drv.preBuild = lib.mkIf (!wlib.types.stringable.check config.diskoModule) ''
                                mkdir -p ${lib.escapeShellArg diskoflakedir}
                                echo ${lib.escapeShellArg (builtins.toJSON config.diskoModule)} > ${lib.escapeShellArg "${diskoflakedir}/disko.json"}
                                echo ${lib.escapeShellArg ''
                                  {
                                    outputs = _: {
                                      diskoConfigurations = {
                                        ${wlib.escapeShellArgWithEnv name} = builtins.fromJSON (builtins.readFile "''${./.}/disko.json");
                                      };
                                    };
                                  }
                                ''} > ${lib.escapeShellArg "${diskoflakedir}/flake.nix"}
                              '';
                              config.appendFlag = [
                                {
                                  name = "CallMod";
                                  data = if wlib.types.stringable.check config.diskoModule then config.diskoModule else [ "--flake" "${diskoflakedir}#${name}" ];
                                }
                              ];
                              config.package = lib.mkDefault (
                                inputs.disko.packages.${system}.disko or diskoflake.packages.${system}.disko or null
                              );
                            }
                          )
                        ];
                    };
                    default = { };
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
                  module = mkOption {
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
                      ++ lib.optionals (config.disko.diskoModule != null) [
                        (inputs.disko.nixosModules.disko or diskoflake.nixosModules.disko or { })
                        config.disko.diskoModule
                      ]
                      ++ [ config.module ]
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
          type = types.lazyAttrsOf (
            types.submodule (
              { config, name, ... }:
              {
                freeformType = wlib.types.attrsRecursive;
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
                    type = types.pkgs;
                    default = pkgs;
                  };
                  extraSpecialArgs = mkOption {
                    type = types.lazyAttrsOf types.raw;
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
                  module = mkOption {
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
                        config.module
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
            "module"
          ]
        )
      ) (config.perSystem system).homeConfigurations;
      nixosConfigurations = builtins.mapAttrs (
        n: v:
        v.nixpkgs.lib.nixosSystem (
          builtins.removeAttrs v [
            "nixpkgs"
            "module"
            "disko"
            "extraSpecialArgs"
            "hostname"
            "username"
            "home-manager"
          ]
        )
      ) (config.perSystem system).nixosConfigurations;
      diskoConfigurations = lib.filterAttrs (n: v: v != null) (
        builtins.mapAttrs (
          n: v: if v.disko.diskoModule == null then null else v.disko.wrapper
        ) (config.perSystem system).nixosConfigurations
      );
    });
  };
}
