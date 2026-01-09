{ inputs, util, ... }:
{ config, pkgs, lib, wlib, ... }: {
  _file = ./default.nix;
  key = ./default.nix;
  imports = [ wlib.modules.default ];
  options.lua = lib.mkOption {
    type = lib.types.package;
    default = pkgs.luajit;
  };
  options.luaEnv = lib.mkOption {
    type = with lib.types; functionTo (listOf package);
    default = (lp: []);
    apply = v: config.lua.withPackages v;
  };
  options.configDir = lib.mkOption {
    type = wlib.types.stringable;
    default = ./config;
  };
  options.luaInfo = lib.mkOption {
    type = wlib.types.attrsRecursive;
    default = {};
  };
  options.init = lib.mkOption {
    type = wlib.types.stringable;
    default = ./init.lua;
  };
  options.theme = lib.mkOption {
    type = wlib.types.stringable;
    default = ./theme.lua;
  };
  config.package = pkgs.luakit;
  config.drv.src = config.configDir;
  config.drv.passAsFile = [ "nixInfo" ];
  config.drv.nixInfo = /* lua */ ''
    package.preload.nixInfo = function(...)
      return ${lib.generators.toLua {} (config.luaInfo // { outDir = "${placeholder "out"}"; })}
    end
    dofile('${placeholder "out"}/init.lua')
  '';
  config.drv.postBuild = ''
    ln -s "${config.theme}" "${placeholder "out"}/theme.lua"
    ln -s "${config.init}" "${placeholder "out"}/init.lua"
    { [ -e "$nixInfoPath" ] && cat "$nixInfoPath" || echo "$nixInfo"; } > ${lib.escapeShellArg "${placeholder "out"}/rc.lua"}
    ${util.mkRecBuilder {
      src = "$src";
      out = "$out/cfg";
      action = /*bash*/''
        if [[ "$1" == *.c ]]; then
          $CC -O2 -fPIC -shared -I"${config.luaEnv}/include" -o "$2/$(basename "$1" .c).so" "$1"
        else
          ln -s "$1" "$2"
        fi
      '';
    }}
  '';
  config.flags = {
    "-c" = "${placeholder "out"}/rc.lua";
  };
  config.prefixVar = [
    [ "LUA_PATH" ":" "${config.luaEnv.pkgs.luaLib.genLuaPathAbsStr config.luaEnv}" ]
    [ "LUA_CPATH" ":" "${config.luaEnv.pkgs.luaLib.genLuaCPathAbsStr config.luaEnv}" ]
    [ "LUA_PATH" ":" "${placeholder "out"}/cfg/?.lua;${placeholder "out"}/cfg/?/init.lua" ]
    [ "LUA_CPATH" ":" "${placeholder "out"}/cfg/?.so" ]
  ];
}
