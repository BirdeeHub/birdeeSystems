{ mkRecBuilder, inputs, ... }: with builtins; rec {
  compile_lua_modules = {
    lib, stdenv, n2l ? inputs.nixToLua,
    runLuaCommand ? import "${inputs.shelua}/nix" { inherit lib stdenv n2l; },
    lua5_2,
    ...
    }: {
    name,
    src,
    luaDrv ? lua5_2,
    luaPackages ? (_:[]),
    LUA_DIR ? "lua",
    C_DIR ? "c",
    FNL_DIR ? "fnl",
    nix_info ? {},
  }@args: let
  in
  runLuaCommand.runLuaCommand name luaEnv.interpreter ({
      passthru = (args.passthru or {}) // (if lib.isFunction nix_info then nix_info n2l else nix_info);
    } // (removeAttrs args [ "nix_info" "name" "passthru" "luaEnv" ])
  ) /*lua*/ ''
    _G.src = os.env.src
    local lutil = dofile('${./lutil.lua}')
  '';

  mkLuaApp = callPackage: arguments: let
    mkLuaAppWcallPackage = {
      lib
      , stdenv
      , makeWrapper
      , lua5_2
      # args below:
      , LUA_SRC
      , CPATH_DIR ? null
      , lua_interpreter ? lua5_2
      , lua_packages ? (_:[])
      , extraLuaPackages ? (_:[])
      , APPNAME ? "REPLACE_ME"
      , wrapperArgs ? []
      , miscNixVals ? {}
      , ...
    }: let
      inherit (inputs.nixToLua) toLua;
      compiled = lib.makeOverridable compile_lua_dir {
        name = APPNAME;
        inherit (stdenv) mkDerivation;
        inherit lua_interpreter lua_packages extraLuaPackages LUA_SRC CPATH_DIR miscNixVals toLua;
      };
      app_final = stdenv.mkDerivation (let
        luaEnv = compiled.luaModule.withPackages (_: [ compiled ]);
      in {
        name = APPNAME;
        src = compiled;
        nativeBuildInputs = [ makeWrapper ];
        propagatedBuildInputs = [ compiled ];
        passthru = {
          inherit luaEnv;
          unwrapped = compiled;
        };
        buildPhase = /*bash*/''
          runHook preBuild
          mkdir -p $out/bin
          echo '#!${luaEnv.interpreter}' > $out/bin/${APPNAME}
          echo ${lib.escapeShellArg "require(${toLua APPNAME})"} >> $out/bin/${APPNAME}
          chmod +x $out/bin/${APPNAME}
          runHook postBuild
        '';
        postFixup = /*bash*/''
          wrapProgram $out/bin/${APPNAME} ${concatStringsSep " " wrapperArgs}
        '';
      });
    in
    lua_interpreter.pkgs.luaLib.toLuaModule app_final;
  in callPackage mkLuaAppWcallPackage arguments;

  mkLuaEmbed = callPackage: arguments: let
    mkLuaEmbedWcallPackage = {
      runCommandCC,
      luajit,
      LUA ? luajit,
      ...
    }: let
    in runCommandCC "lua_embed" {
      inherit LUA;
      src = ./lua_embed.c;
    } ''
      mkdir -p $out
      $CC -x c -fPIC -shared -I"$LUA/include" -o $out/embed.so $src
    '';
  in callPackage mkLuaEmbedWcallPackage arguments;

}
