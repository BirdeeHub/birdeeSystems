let
  importApply = p: a: {
    imports = [ (import p a) ];
    _file = p;
  };
  optionals = c: v: if c then v else [ ];
  recImport =
    {
      deep ? false,
      skip ? false,
      name,
      dir,
      ...
    }@opts:
    let
      entries = builtins.readDir dir;
    in
    optionals (entries ? "${name}" && !skip) [
      (if opts ? args then (importApply (dir + "/${name}") opts.args) else (dir + "/${name}"))
    ]
    ++ optionals (!entries ? "${name}" || deep) (
      builtins.concatMap (
        name:
        optionals (entries.${name} == "directory") (
          recImport (
            opts
            // {
              skip = false;
              dir = (dir + "/${name}");
            }
          )
        )
      ) (builtins.attrNames entries)
    );
  importTree =
    { dir, ... }@opts:
    builtins.concatLists (
      builtins.attrValues (
        builtins.mapAttrs (
          n: v:
          if v == "directory" then
            importTree (opts // { dir = (dir + "/${n}"); })
          else if
            let
              len = builtins.stringLength n;
            in
            v == "regular"
            && len > 3
            && builtins.substring 0 1 n != "_"
            && builtins.substring (len - 4) 4 n == ".nix"
          then
            [
              (if opts ? args then (importApply (dir + "/${n}") opts.args) else (dir + "/${n}"))
            ]
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
    importTree
    recImport
    ;
}
