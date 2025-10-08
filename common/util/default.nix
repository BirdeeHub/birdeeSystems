inputs: with builtins; rec {

  linkFarmPair =
    name:
    path:
    { inherit name path; };

  pipe = foldl' (x: f: f x);

  flip = f: a: b: f b a;

  mapAttrsToList = f: attrs: map (name: f name attrs.${name}) (attrNames attrs);

  isDerivation = value: value.type or null == "derivation";

  isFunctor = value: isFunction (value.__functor or null);

  hasOutPath = value: value.outPath or null != null;

  birdIsAttrs = v: isAttrs v.value && ! isDerivation v.value && ! isFunctor v.value && ! hasOutPath v.value;

  recAttrsToList = here: flip pipe [
    (mapAttrsToList (n: value: {
      path = here ++ [n];
      inherit value;
    }))
    (foldl' (a: v: if birdIsAttrs v.value
      then a ++ (recAttrsToList v.path v.value)
      else a ++ [v]
    ) [])
  ];

  pickyRecUpdateUntil = {
    pred ? (path: lh: rh: ! birdIsAttrs lh || ! birdIsAttrs rh),
    pick ? (path: l: r: r)
  }: lhs: rhs: let
    f = attrPath:
      zipAttrsWith (n: values:
        let here = attrPath ++ [n]; in
        if length values == 1 then
          head values
        else if pred here (elemAt values 1) (head values) then
          pick here (elemAt values 1) (head values)
        else
          f here values
      );
  in f [] [rhs lhs];

  eachSystem = systems: f: let
    # get function result and insert system variable
    op = attrs: system: let
      ret = f system;
      op = attrs: key: attrs // {
        ${key} = (attrs.${key} or { })
          // { ${system} = ret.${key}; };
      };
    in foldl' op attrs (attrNames ret);
  # Merge together the outputs for all systems.
  in foldl' op { } (systems ++
    (if builtins ? currentSystem && ! elem builtins.currentSystem systems
    # add the current system if --impure is used
    then [ builtins.currentSystem ]
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

  inherit (import ./mkLuaStuff.nix { inherit mkRecBuilder inputs pipe; }) compile_lua_dir mkLuaApp;

  inherit (inputs.nixToLua) mkEnum;

  addLuarocksTree = /*bash*/ ''
    # addPathForLuarocksTree "luarocks" LUA_PATH "$LUAROCKS_TREE_PATH"
    # addPathForLuarocksTree "luarocks" LUA_CPATH "$LUAROCKS_TREE_PATH"
    # addPathForLuarocksTree "luarocks" PATH "$LUAROCKS_TREE_PATH"
    addPathForLuarocksTree() {
      local luarocks_cmd="$1"
      local which_path="$2"
      local tree="$3"
      if [[ "$tree" != /* ]]; then
        echo "Error: luarocks tree '$tree' must be an absolute path" >&2
        return 1
      fi
      local pathcmd entries entry
      case "$which_path" in
        LUA_PATH) pathcmd=--lr-path ;;
        LUA_CPATH) pathcmd=--lr-cpath ;;
        PATH) pathcmd=--lr-bin ;;
        *)
          echo "Error: unsupported second arg '$which_path'. Supported: LUA_PATH, LUA_CPATH, PATH" >&2
          return 1
          ;;
      esac
      # split path to entries
      local IFS_split=';'
      [[ "$which_path" == PATH ]] && IFS_split=':'
      IFS="$IFS_split" read -ra entries <<< "$("$luarocks_cmd" path --tree="$tree" $pathcmd)"
      # find our new entries and add them to relevant variable
      for entry in "''${entries[@]}"; do
        if [[ "$entry" == "$tree"* ]]; then
          export $which_path="''${!which_path:+''${!which_path}$IFS_split}$entry"
        fi
      done
    }
  '';

}
