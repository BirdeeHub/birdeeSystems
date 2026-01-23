wlib: {
  /**
    Produces a module for another module system,
    that can be imported to configure and/or install a wrapper module.

    *Arguments:*

    ```nix
    {
      optloc ? [ "wrapperModules" ],
      loc ? [
        "environment"
        "systemPackages"
      ],
      name, # string
      value, # module or list of modules
      ...
    }:
    ```

    Creates a `wlib.types.subWrapperModule` option with an extra `enable` option at
    the path indicated by `optloc ++ [ name ]`, with the default `optloc` being `[ "wrapperModules" ]`

    Defines a list value at the path indicated by `loc` containing the `.wrapper` value of the submodule,
    with the default `loc` being `[ "environment" "systemPackages" ]`

    This means it will create a module that can be used like so:

    ```nix
    # in a nixos module
    { ... }: {
      imports = [
        (mkInstallModule { name = "?"; value = someWrapperModule; })
      ];
      config.wrapperModules."?" = {
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
      config.wrapperModules."?" = {
        enable = true;
        env.EXTRAVAR = "TEST VALUE";
      };
    }
    ```
  */
  mkInstallModule =
    {
      optloc ? [ "wrapperModules" ],
      loc ? [
        "environment"
        "systemPackages"
      ],
      name,
      value,
      ...
    }:
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options = lib.setAttrByPath (optloc ++ [ name ]) (
        lib.mkOption {
          default = { };
          type = wlib.types.subWrapperModule (
            (lib.toList value)
            ++ [
              {
                config.pkgs = pkgs;
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
          [
            (lib.getAttrFromPath (
              optloc
              ++ [
                name
                "wrapper"
              ]
            ) config)
          ]
      );
    };
}
