{ self }: 
let
  importedFileStructure = srcPath: 
  let
    recSetSearch = rec {
      filterFiles = absPth: (
        builtins.mapAttrs (name: value:
        if value != "directory" then
          { "${name}" = builtins.readFile "${absPth}/${name}"; }
        else filterFiles "${absPth}/${name}" { 
            "${name}" = builtins.readDir "${absPth}/${name}"; }
        )
      );
      next = filterFiles "${srcPath}" { "${srcPath}" = builtins.readDir srcPath; };
    };
  in
  recSetSearch.next;
in
importedFileStructure "${self}"
