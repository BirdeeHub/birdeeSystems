{ toLuaModule, lua, ... }: toLuaModule (lua.stdenv.mkDerivation (finalAttrs: let
  luafinal = finalAttrs.passthru.luaModule or lua;
  inherit (builtins) head split foldl';
  pipe = foldl' (v: f: f v);
in {
  pname = "embed";
  version = "dev";
  src = ./embed.c;
  dontUnpack = true;
  env.LUA_INC = "${luafinal}/include";
  env.LUA_CPATH_DIR = pipe luafinal.LuaPathSearchPaths [ head (split "[?]") head dirOf ];
  buildPhase = ''
    runHook preBuild;
    mkdir -p $out/$LUA_CPATH_DIR
    $CC -x c -O2 -fPIC -shared -I$LUA_INC -o $out/$LUA_CPATH_DIR/embed.so $src
    runHook postBuild;
  '';
}))
