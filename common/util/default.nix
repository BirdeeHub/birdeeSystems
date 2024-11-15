inputs: with builtins; rec {

  linkFarmPair =
    name:
    path:
    { inherit name path; };

  eachSystem = with builtins; systems: f:
    let
      # Merge together the outputs for all systems.
      op = attrs: system:
        let
          ret = f system;
          op = attrs: key: attrs //
              {
                ${key} = (attrs.${key} or { })
                  // { ${system} = ret.${key}; };
              }
          ;
        in
        foldl' op attrs (attrNames ret);
    in
    foldl' op { }
      (systems
        ++ # add the current system if --impure is used
          (if builtins ? currentSystem then
             if elem currentSystem systems
             then []
             else [ currentSystem ]
          else []));

  mkRecBuilder = { src ? "$src", outdir ? "$out", action ? "cp $1 $2", ... }: /* bash */''
    builder_file_action() {
      ${action}
    }
    dirloop() {
      local dir=$1
      local outdir=$2
      local action=$3
      shift 3
      local dirnames=("$@")
      local file=""
      mkdir -p "$outdir"
      for file in "$dir"/*; do
        if [ -d "$file" ]; then
          dirloop "$file" "$outdir/$(basename "$file")" $action "''${dirnames[@]}" "$(basename "$file")"
        else
          $action "$file" "$outdir" "''${dirnames[@]}"
        fi
      done
    }
    dirloop ${src} ${outdir} builder_file_action
  '';

  # use callPackage
  backup_rotator = ./backup_rotator.nix;

  inherit (import ./mkLuaStuff.nix { inherit mkRecBuilder inputs; }) compile_lua_dir mkLuaApp;

  inherit (inputs.nixToLua) mkEnum;

}
