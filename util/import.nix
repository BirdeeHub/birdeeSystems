let
  importApply = p: a: {
    imports = [ (import p a) ];
    _file = p;
  };
  optionals = c: v: if c then v else [ ];
  pipe = builtins.foldl' (x: f: f x);
  filterAttrs =
    pred: set:
    removeAttrs set (builtins.filter (name: !pred name set.${name}) (builtins.attrNames set));
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
        if entries.${name} == "directory" then
          basefunc (args // { skip = false; }) target-name staticArgs (dir + "/${name}")
        else
          [ ]
      ) (builtins.attrNames entries)
    );
in
{
  inherit
    importApply
    filterAttrs
    pipe
    optionals
    ;

  mapModDirs =
    staticArgs: applyfirst: dir:
    pipe (builtins.readDir dir) [
      (filterAttrs (n: v: v == "directory"))
      builtins.attrNames
      (map (n: {
        name = n;
        value = "${dir}/${n}";
      }))
      builtins.listToAttrs
      (builtins.mapAttrs (n: v: if applyfirst.${n} or null != null then importApply v staticArgs else v))
    ];

  findModulesWith = basefunc { };

  recImportApplyNamed = basefunc { deep = true; };

  recImportApplyNamedIn = basefunc {
    deep = true;
    skip = true;
  };

  findModulesIn = basefunc { skip = true; };
}
