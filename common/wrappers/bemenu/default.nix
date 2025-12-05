{ pkgs, config, lib, wlib, ... }:
{
  options.settings = lib.mkOption {
    type =
      with lib.types;
      attrsOf (oneOf [
        str
        number
        bool
      ]);
    default = { };
    example = {
      line-height = 28;
      prompt = "open";
      ignorecase = true;
      fb = "#1e1e2e";
      ff = "#cdd6f4";
      nb = "#1e1e2e";
      nf = "#cdd6f4";
      tb = "#1e1e2e";
      hb = "#1e1e2e";
      tf = "#f38ba8";
      hf = "#f9e2af";
      af = "#cdd6f4";
      ab = "#1e1e2e";
      width-factor = 0.3;
    };
    description = "Configuration options for bemenu. See {manpage}`bemenu(1)`.";
  };
  imports = [ wlib.modules.default ];
  config.package = lib.mkDefault pkgs.bemenu;
  config.env.BEMENU_OPTS = lib.cli.toGNUCommandLineShell { } config.settings;
}
