{ inputs, birdeeutils, ... }:
{ config, pkgs, lib, wlib, ... }:
{
  imports = [ ./xplr.nix ];
  luaInfo = { };
  defaultConfigLang = "fnl";
  plugins = {
    # require_name = plugin_path;
  };
  luaEnv = lp: [ lp.inspect ];
  luaInit.MAIN_INIT = {
    opts = {};
    data = /* fennel */ ''
      (local (opts name) ...)
      nil
    '';
  };
}
