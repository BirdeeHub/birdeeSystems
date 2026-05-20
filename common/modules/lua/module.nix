{ moduleNamespace, util, inputs, ... }: { lib, ... }: let
  mkLuaStuff = import ./mkLuaStuff.nix util;
  generated = let
    files = lib.pipe ./generated [
      lib.filesystem.listFilesRecursive
      (builtins.filter (lib.hasSuffix ".nix"))
      (map (v: { name = lib.removeSuffix ".nix" (baseNameOf v); value = v; }))
      builtins.listToAttrs
    ];
  in files;
  module = { config, pkgs, lib, _class, ... }: let
    packages = with pkgs; [
      inputs.self.packages.${system}.birdeeLua
      gcc
      antifennel
    ];
    cfg = config.${moduleNamespace}.birdeeLua;
  in {
    options.${moduleNamespace}.birdeeLua.enable = lib.mkEnableOption "birdee lua env";
    config = lib.mkIf cfg.enable {
      homeManager.home.packages = packages;
      nixos.environment.systemPackages = packages;
    }.${_class};
  };
in {
  overlays = {
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
  perSystem = { pkgs, ... }: let
    luaEnv = util.wlib.wrapPackage [
      { inherit pkgs; }
      ({ pkgs, config, wlib, lib, ... }: {
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
        config.wrapperVariants.lua-repl = {
          exePath = config.exePath;
          flags."-e" = ''require("birdee.repl-init").initRepl()'';
        };
        config.overrides = [
          {
            name = "SetupWithPackages";
            type = null;
            data = package:
              (util.wlib.makeCustomizable "withPackages" { mergeArgs = og: new: lp: og lp ++ new lp; } package.withPackages (
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
      })
    ];
  in {
    packages.birdeeLua = luaEnv;
  };
  flake.modules.homeManager.birdeeLua = module;
  flake.modules.nixos.birdeeLua = module;
}
