{ toLuaModule, lua, ... }: toLuaModule (lua.stdenv.mkDerivation (finalAttrs: let
  luafinal = finalAttrs.passthru.luaModule or lua;
in {
  pname = "embed";
  version = "dev";
  src = ./embed.c;
  dontUnpack = true;
  env.LUA_INC = "${luafinal}/include";
  env.LUA_CPATH_DIR = dirOf (builtins.head luafinal.pkgs.luaLib.luaCPathList);
  buildPhase = ''
    runHook preBuild;
    mkdir -p $out/$LUA_CPATH_DIR
    $CC -x c -O2 -fPIC -shared -I$LUA_INC -o $out/$LUA_CPATH_DIR/embed.so $src
    runHook postBuild;
  '';
}))
