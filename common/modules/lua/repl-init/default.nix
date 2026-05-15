{ toLuaModule, lua, util, ... }: toLuaModule (lua.stdenv.mkDerivation (finalAttrs: let
  luafinal = finalAttrs.passthru.luaModule or lua;
in {
  pname = "repl-init";
  version = "dev";
  src = ./.;
  dontUnpack = true;
  env.LUA_PATH_DIR = util.getLuaLoc luafinal.LuaPathSearchPaths;
  buildPhase = ''
    runHook preBuild;
    mkdir -p $out/$LUA_PATH_DIR/birdee
    mkdir -p $out/birdee
    cp $src/birdee/chaining.fnlm $out/birdee/chaining.fnlm
    cp $src/birdee/repl-init.lua $out/$LUA_PATH_DIR/birdee/repl-init.lua
    runHook postBuild;
  '';
}))
