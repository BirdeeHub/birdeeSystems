{ inputs, moduleNamespace, ... }:
let
  name = "manuals";
in
{
  flake.modules.nixos.${name} =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.${moduleNamespace}.${name};
    in
    {
      options.${moduleNamespace}.${name}.disable = lib.mkEnableOption "make it faster to rebuild";
      config = lib.mkIf cfg.disable {
        # Disable man pages and other documentation
        documentation.man.cache.enable = false;
        documentation.man.enable = false;
        documentation.doc.enable = false;
        documentation.dev.enable = false;
        documentation.info.enable = false;
        # disable man pages for nixos options
        documentation.nixos.enable = false;
      };
    };
  flake.modules.homeManager.${name} =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.${moduleNamespace}.${name};
    in
    {
      options.${moduleNamespace}.${name}.disable = lib.mkEnableOption "make it faster to rebuild";
      config = lib.mkIf cfg.disable {
        # Disable documentation for packages installed by home-manager
        programs.man.generateCaches = false;
        # disable man pages for home manager options
        manual.html.enable = false;
        manual.manpages.enable = false;
        manual.json.enable = false;
      };
    };
}
