{
  lib,
  stdenv ? lua.stdenv or (throw "use callPackage or pass { lib, lua, stdenv ? lua.stdenv, ... }"),
  lua,
  shelua, # needed for now because shelua is not in nixpkgs
  ...
}: drvAttrs: let
  inherit (import ./util.nix lib) makeCustomizable topoSort normalizeDag;
in lib.fix (final: let
  args = if lib.isFunction drvAttrs then drvAttrs final else drvAttrs;
  lua-stdenv = import ./builder { lua = final.LUA or lua; inherit shelua; };
  mkdrv = fargs:
    derivation (let
      res = removeAttrs fargs [ "passthru" "meta" ];
    in res // {
      __structuredAttrs = true;
      build = topoSort (fargs.name or "<unknown>") (fargs.build or {});
    }) // {
      passthru = fargs.passthru or {};
      meta = fargs.meta or {};
    } // removeAttrs (fargs.passthru or {}) [ "passthru" ];
in makeCustomizable "overrideAttrs" {
  patches = [];
  mergeArgs = og: arg: let
    old = og // { build = normalizeDag (new.name or og.name or "<unknown>") (og.build or {}); };
    new = if lib.isFunction arg then arg old else arg;
    mergeChild = name: if builtins.isAttrs (new.${name} or null) then { ${name} = old.${name} or {} // new.${name} or {}; } else {};
    mergedBuild = lib.pipe {
      next = normalizeDag (new.name or og.name or "<unknown>") (new.build or {});
      prev = old.build or {};
    } [
      ({ next, prev, }: builtins.zipAttrsWith (_: vs: builtins.foldl' (a: v: a // v) {} vs) [ prev next ])
      (build: { inherit build; })
    ];
  in old // new // mergedBuild // mergeChild "env";
} mkdrv (
  {
    name = "${toString (final.pname or (throw "mkLuaDrv requires a pname or name attribute!"))}-${toString (final.version or "master")}";
    stdenv = final.LUA.stdenv or lua.stdenv or stdenv;
    LUA = lua;
    inherit ((final.stdenv or final.LUA.stdenv or lua.stdenv or stdenv).hostPlatform) system;
    args = [ lua-stdenv ];
    builder = final.LUA.interpreter or lua.interpreter;
  } // args
))
