{ inputs, birdeeutils, ... }:
{ config, pkgs, lib, wlib, ... }:
{
  imports = [ ./xplr.nix ];
  luaInfo = { };
  defaultConfigLang = "fnl";
  # LOL impure plugins
  plugins = {};
  luaEnv = lp: [ lp.inspect ];
  luaInit.MAIN_INIT = {
    opts = {};
    data = /* fennel */ ''
      (local (opts name) ...)
      nil
    '';
  };
}
