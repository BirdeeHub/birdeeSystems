let
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
    (
      if entries ? "${target-name}" && !skip then
        [
          {
            imports = [ (import (dir + "/${target-name}") staticArgs) ];
            _file = dir + "/${target-name}";
          }
        ]
      else
        [ ]
    )
    ++ (
      if !entries ? "${target-name}" || deep then
        (builtins.concatMap (
          name:
          if entries.${name} == "directory" then
            basefunc (args // { skip = false; }) target-name staticArgs (dir + "/${name}")
          else
            [ ]
        ) (builtins.attrNames entries))
      else
        [ ]
    );
in
{
  findModulesWith = basefunc { };

  recImportApplyNamed = basefunc { deep = true; };

  recImportApplyNamedIn = basefunc { deep = true; skip = true; };

  findModulesIn = basefunc { skip = true; };
}
