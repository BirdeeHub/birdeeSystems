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
    mkdir -p $out/$LUA_PATH_DIR
    mkdir -p $out/fnl/birdee
    cp $src/chaining.fnlm $out/fnl/birdee/chaining.fnlm
    cp -r $src/birdee $out/$LUA_PATH_DIR/
    runHook postBuild;
  '';
}))
