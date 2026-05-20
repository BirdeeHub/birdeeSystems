{ moduleNamespace, util, inputs, ... }: { lib, ... }: let
  mkLuaStuff = import ./mkLuaStuff.nix util;
in {
  flake.util.mkLuaStuff = mkLuaStuff;
  overlays = let
    generated = let
      files = lib.pipe ./generated [
        lib.filesystem.listFilesRecursive
        (builtins.filter (lib.hasSuffix ".nix"))
        (map (v: { name = lib.removeSuffix ".nix" (baseNameOf v); value = v; }))
        builtins.listToAttrs
      ];
    in files;
  in {
    antifennel = final: prev: { antifennel = final.callPackage ./antifennel.nix { inherit inputs; }; };
    shelua = inputs.shelua.overlays.default;
    tomlua = inputs.tomlua.overlays.default;
    lua-osenv = inputs.osenv.overlays.default;
    fn_finder = inputs.fn_finder.overlays.default;
    lua-embed = {
      data = null;
      lua = lself: lprev: {
        embed = lself.callPackage ./embed { inherit util; };
      };
    };
    croissant = {
      data = null;
      lua = lself: lprev: {
        croissant = lself.callPackage generated.croissant {};
        repl-init = lself.callPackage ./repl-init { inherit util; };
        sirocco = (lself.callPackage generated.sirocco {}).overrideAttrs (oa: {
          # fetchFromGitHub absolutely refuses to fetch submodules
          src = (lself.callPackage ({ fetchgit, }: fetchgit) {}) {
            url = "https://github.com/giann/sirocco";
            rev = "b2af2d336e808e763b424d2ea42e6a2c2b4aa24d";
            hash = "sha256-LcdHV+STHNZzRaw/aoIWi71Gx1t4+7uHVoP9w6Rrc9Y=";
            fetchSubmodules = true;
          };
        });
        hump = lself.callPackage generated.hump {};
        wcwidth = lself.callPackage generated.wcwidth {};
      };
    };
  };
  # NOTE: without the above overlays applied to the pkgs this won't work.
  flake.wrappers.birdeeLua = { pkgs, config, wlib, lib, ... }@top: let
    module = { config, pkgs, lib, _class, ... }: let
      cfg = top.config.install.getWrapperConfig config;
    in {
      config = lib.mkMerge [
        (
          lib.mkIf cfg.enableCompanionPackages {
            homeManager.home.packages = cfg.companionPackages;
            nixos.environment.systemPackages = cfg.companionPackages;
          }.${_class}
        )
        (top.config.install.mkWrapperExtension "birdee lua wrapper" {
          options.enableCompanionPackages = lib.mkEnableOption "a selection of packages to install alongside the lua env" // { default = true; };
          config.companionPackages = [ pkgs.gcc ];
          options.companionPackages = lib.mkOption {
            type = lib.types.listOf wlib.types.linkable;
          };
        })
      ];
    };
  in {
    config.install.modules.nixos = module;
    config.install.modules.homeManager = module;
    imports = [ wlib.modules.default ];
    options.withPackages = lib.mkOption {
      type = wlib.types.withPackagesType;
      default = lp: [];
    };
    config.package = pkgs.luajit;
    options.overrides = lib.mkOption {
      type = wlib.types.seriesOf (wlib.types.spec {
        after = lib.mkDefault [ "SetupWithPackages" ];
      });
    };
    config.wrapperImplementation = "binary";
    config.wrapperVariants.lua-repl = {
      inherit (config) exePath;
      flags."-e" = ''require("birdee.repl-init").initRepl()'';
    };
    config.wrapperVariants.antifennel = {
      config.package = pkgs.antifennel;
      config.mirror = false;
    };
    config.overrides = [
      {
        name = "SetupWithPackages";
        type = null;
        data = package:
          (wlib.makeCustomizable "withPackages" { mergeArgs = og: new: lp: og lp ++ new lp; } package.withPackages (
            lp: with lp; [
              luv
              shelua
              tomlua
              osenv
              cjson
              inspect
              lyaml
              luarocks-nix
              lpeg
              luaossl
              luazip
              lua-zlib
              luafilesystem
              luasocket
              fennel
              fn_finder
              repl-init
              embed
              croissant
            ]
          )).withPackages config.withPackages;
      }
    ];
  };
}
