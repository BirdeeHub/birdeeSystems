{ inputs, birdeeutils, ... }:
{ config, pkgs, lib, wlib, ... }:
{
  imports = [ ./xplr.nix ];
  luaEnv = lp: [ lp.inspect ];
  luaInit.TESTFILE_2 = {
    opts = { haha = 2; };
    after = [ "TESTFILE_1" ];
    type = "fnl";
    data = ''
      (print ((require "inspect") [...]))
    '';
  };
  luaInit.TESTFILE_1 = {
    opts = { haha = 1; };
    data = ''
      local opts, name = ...
      print(name, require("inspect")(opts))
    '';
  };
}
