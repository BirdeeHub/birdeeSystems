let
  importApply = p: a: {
    imports = [ (import p a) ];
    _file = p;
  };
  optionals = c: v: if c then v else [ ];
  basefunc =
    {
      deep ? false,
      skip ? false,
      ...
    }@args:
    target-name: staticArgs: dir:
    let
      entries = builtins.readDir dir;
    in
    optionals (entries ? "${target-name}" && !skip) [
      (importApply (dir + "/${target-name}") staticArgs)
    ]
    ++ optionals (!entries ? "${target-name}" || deep) (
      builtins.concatMap (
        name:
        optionals (entries.${name} == "directory") (
          basefunc (args // { skip = false; }) target-name staticArgs (dir + "/${name}")
        )
      ) (builtins.attrNames entries)
    );
  import-tree =
    dir:
    builtins.concatLists (
      builtins.attrValues (
        builtins.mapAttrs (
          n: v:
          let
            len = builtins.stringLength n;
          in
          if v == "directory" then
            import-tree (dir + "/" + n)
          else if
            v == "regular"
            && len > 3
            && builtins.substring 0 1 n != "_"
            && builtins.substring (len - 4) 4 n == ".nix"
          then
            [ (dir + "/" + n) ]
          else
            [ ]
        ) (builtins.readDir dir)
      )
    );
in
{
  inherit
    importApply
    optionals
    import-tree
    ;

  findModulesWith = basefunc { };

  recImportApplyNamed = basefunc { deep = true; };

  recImportApplyNamedIn = basefunc {
    deep = true;
    skip = true;
  };

  findModulesIn = basefunc { skip = true; };
}
