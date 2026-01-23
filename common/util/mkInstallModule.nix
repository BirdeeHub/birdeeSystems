wlib: {
  /**
    Produces a module for another module system,
    that can be imported to configure and/or install a wrapper module.

    *Arguments:*

    ```nix
    {
      name, # string
      value, # module or list of modules
      optloc ? [ "wrappers" ],
      loc ? [
        "environment"
        "systemPackages"
      ],
      as_list ? true,
      # Also accepts any valid top-level module attribute
      # other than `config` or `options`
      ...
    }: 
    ```

    Creates a `wlib.types.subWrapperModule` option with an extra `enable` option at
    the path indicated by `optloc ++ [ name ]`, with the default `optloc` being `[ "wrappers" ]`

    Defines a list value at the path indicated by `loc` containing the `.wrapper` value of the submodule,
    with the default `loc` being `[ "environment" "systemPackages" ]`

    If `as_list` is false, it will set the value at the path indicated by `loc` as it is,
    without putting it into a list.

    This means it will create a module that can be used like so:

    ```nix
    # in a nixos module
    { ... }: {
      imports = [
        (mkInstallModule { name = "?"; value = someWrapperModule; })
      ];
      config.wrappers."?" = {
        enable = true;
        env.EXTRAVAR = "TEST VALUE";
      };
    }
    ```

    ```nix
    # in a home-manager module
    { ... }: {
      imports = [
        (mkInstallModule { name = "?"; loc = [ "home" "packages" ]; value = someWrapperModule; })
      ];
      config.wrappers."?" = {
        enable = true;
        env.EXTRAVAR = "TEST VALUE";
      };
    }
    ```

    If needed, you can also grab the package directly with `config.wrappers."?".wrapper`

    NOTE: This function will only provide a `pkgs` to the `subWrapperModule` automatically,
    if the importing module evaluation provides a `pkgs` via its module arguments to use!
    Otherwise, you will need to supply it to the submodule yourself later.
  */
  mkInstallModule =
    {
      optloc ? [ "wrappers" ],
      loc ? [
        "environment"
        "systemPackages"
      ],
      as_list ? true,
      name,
      value,
      ...
    }@args:
    {
      pkgs ? null,
      lib,
      config,
      ...
    }:
    # https://github.com/NixOS/nixpkgs/blob/c171bfa97744c696818ca23d1d0fc186689e45c7/lib/modules.nix#L615C1-L623C25
    builtins.intersectAttrs {
      _class = null;
      _file = null;
      key = null;
      disabledModules = null;
      imports = null;
      meta = null;
      freeformType = null;
    } args
    // {
      options = lib.setAttrByPath (optloc ++ [ name ]) (
        lib.mkOption {
          default = { };
          type = wlib.types.subWrapperModule (
            (lib.toList value)
            ++ [
              {
                config.pkgs = lib.mkIf (pkgs != null) pkgs;
                options.enable = lib.mkEnableOption name;
              }
            ]
          );
        }
      );
      config = lib.setAttrByPath loc (
        lib.mkIf
          (lib.getAttrFromPath (
            optloc
            ++ [
              name
              "enable"
            ]
          ) config)
          (
            let
              res = lib.getAttrFromPath (
                optloc
                ++ [
                  name
                  "wrapper"
                ]
              ) config;
            in
            if as_list then [ res ] else res
          )
      );
    };
}
