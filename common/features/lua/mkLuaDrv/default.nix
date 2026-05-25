{
  lib,
  stdenv ? lua.stdenv or (throw "use callPackage or pass { lib, lua, stdenv ? lua.stdenv, ... }"),
  lua,
  shelua, # needed for now because shelua is not in nixpkgs
  makeCustomizable,
  ...
}: drvAttrs: let
  inherit (rec {
    # this is from the nix-wrapper-modules test lib
    toSanitizedJSON = value:
      if builtins.isAttrs value then
        builtins.toJSON (
          lib.mapAttrsRecursive (
            path: v: if builtins.isFunction v then
              let
                res = builtins.unsafeGetAttrPos (lib.last path) (lib.getAttrFromPath (lib.sublist 0 (builtins.length path - 1) path) value);
              in "<lambda${if builtins.isAttrs res then ":${res.file or ""}:${toString (res.line or "")}:${toString (res.column or "")}" else ""}>"
            else
              v
          ) value
        )
      else
        builtins.toJSON value;
    # these are close but not quite identical to their nix-wrapper-modules wlib.dag counterparts
    normalizeDag = name: dag:
      assert builtins.isAttrs dag || throw "topoSort: expected `build` derivation attribute provided to `${name}` to be an attribute set, but got a `${builtins.typeOf dag}` instead";
    builtins.mapAttrs (n: v: if builtins.isAttrs v then v else { data = v; }) dag;
    topoSort = name: dag:
      assert builtins.isAttrs dag || throw "topoSort: expected `build` derivation attribute provided to `${name}` to be an attribute set, but got a `${builtins.typeOf dag}` instead";
    let
      pushDownDagNames = builtins.mapAttrs (
        n: v: if builtins.isAttrs v then
          v // {
            name = if builtins.isString (v.name or null) then
              v.name
            else if builtins.isString n then
              n
            else
              null;
          }
        else
          { name = n; data = v; }
      );
      before = a: b: let
        aName = a.name or null;
        bName = b.name or null;
      in (aName != null && builtins.elem aName (b.after or [])) || (bName != null && builtins.elem bName (a.before or []));
      sorted = lib.toposort before (builtins.attrValues (pushDownDagNames dag));
    in sorted.result or (throw ''
      Cycle in `build` derivation attribute for `${name}`
      ${toSanitizedJSON sorted}
    '');
  }) topoSort normalizeDag;
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
