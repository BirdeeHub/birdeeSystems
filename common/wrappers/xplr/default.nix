{ inputs, birdeeutils, ... }:
{ config, pkgs, lib, wlib, ... }:
{
  imports = [ ./xplr.nix ];
  # luaInfo = {
  #   testval = "blu";
  # };
  # # LOL impure plugins
  # plugins.TESTPLUGIN = "/home/birdee/Projects/shelua/lua";
  # luaEnv = lp: [ lp.inspect ];
  # luaInit.TESTFILE_1 = {
  #   opts = { testval = 1; };
  #   data = /* lua */''
  #     local opts, name = ...
  #     print(name, require("inspect")(opts), "${placeholder "out"}")
  #     return opts.hooks -- xplr configurations can return hooks
  #   '';
  # };
  # luaInit.TESTFILE_2 = {
  #   opts = { testval = 2; };
  #   after = [ "TESTFILE_1" ];
  #   type = "fnl";
  #   data = /* fennel */ ''
  #     (local (opts name) ...)
  #     (print name ((require "inspect") opts) "${placeholder "out"}")
  #     (. opts hooks) ;; xplr configurations can return hooks
  #   '';
  # };
}
