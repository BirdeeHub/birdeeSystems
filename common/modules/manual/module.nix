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
      config = {
        # Disable man pages and other documentation
        documentation.man.cache.enable = lib.mkIf cfg.disable false;
        documentation.man.enable = lib.mkIf cfg.disable false;
        documentation.doc.enable = lib.mkIf cfg.disable false;
        documentation.dev.enable = lib.mkIf cfg.disable false;
        documentation.info.enable = lib.mkIf cfg.disable false;
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
      config = {
        # Disable documentation for packages installed by home-manager
        programs.man.generateCaches = lib.mkIf cfg.disable false;
        # disable man pages for home manager options
        manual.html.enable = false;
        manual.manpages.enable = false;
        manual.json.enable = false;
      };
    };
}
