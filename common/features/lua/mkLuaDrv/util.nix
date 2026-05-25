lib: let
  # SOURCE: https://github.com/BirdeeHub/nix-wrapper-modules/blob/e7ed7a1205945befdf2e0d73ba7df91d935e5af1/lib/lib.nix#L414
  makeCustomizable = name: {
    patches ? [], # I removed the default patches (and the comments, to see them, go there)
    mergeArgs ? origArgs: newArgs: origArgs // (if lib.isFunction newArgs then newArgs origArgs else newArgs),
  }@opts: f: let
    mkOver = makeCustomizable name opts;
    mirrorArgs = lib.mirrorFunctionArgs f;
    recoverMetadata = if builtins.isAttrs f then
      fDecorated: f // fDecorated // {
        ${if builtins.isString name && f ? "${name}" then name else null} = fdrv: mkOver (f.${name} fdrv);
      }
    else
      (x: x);
    decorate = f': recoverMetadata (mirrorArgs f');
  in decorate (origArgs: let
    result = f origArgs;
    overrideArgs = mirrorArgs (newArgs: mkOver f (mergeArgs origArgs newArgs));
    overrideResult = g: mkOver (mirrorArgs (args: g (f args))) origArgs;
  in if builtins.isAttrs result then
    result // lib.pipe patches [
      (map (patch: {
        ${if result ? "${patch}" then patch else null} = fdrv: overrideResult (x: x.${patch} fdrv);
      }))
      (builtins.foldl' (acc: v: acc // v) {})
    ] // {
      ${name} = overrideArgs;
    }
  else if builtins.isFunction result then
    lib.setFunctionArgs result (lib.functionArgs result) // {
      ${name} = overrideArgs;
    }
  else
    result);
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
in { inherit normalizeDag topoSort makeCustomizable; }
