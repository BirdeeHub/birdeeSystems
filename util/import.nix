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
    optionals
    ;

  findModulesWith = basefunc { };

  recImportApplyNamed = basefunc { deep = true; };

  recImportApplyNamedIn = basefunc {
    deep = true;
    skip = true;
  };

  findModulesIn = basefunc { skip = true; };
}
