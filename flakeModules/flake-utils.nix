with builtins; rec {
  # flake-utils' main function, because its all I used
  # Builds a map from <attr>=value to <attr>.<system>=value for each system
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

  # REMEMBER: this is just lib.genAttrs so if you have lib, dont use this, it confuses people
  bySystems = systems: f: (let
    genAttrs =
      names:
      f:
      listToAttrs (map (n: nameValuePair n (f n)) names);

    nameValuePair =
      name:
      value:
      { inherit name value; };
  in
    genAttrs systems (system: f system));

}
