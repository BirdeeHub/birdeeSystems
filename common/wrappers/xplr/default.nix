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
  # luaInit.TESTFILE_2 = {
  #   opts = { haha = 2; };
  #   after = [ "TESTFILE_1" ];
  #   type = "fnl";
  #   data = ''
  #     (print "${placeholder "out"}" ((require "inspect") [...]))
  #   '';
  # };
  # luaInit.TESTFILE_1 = {
  #   opts = { haha = 1; };
  #   data = ''
  #     local opts, name = ...
  #     local inspect = require "inspect"
  #     local sh = require "TESTPLUGIN.sh"
  #     print(sh.cat "/home/birdee/birdeeSystems/flake.nix")
  #     print(name, inspect(opts), inspect(require "nix-info"))
  #   '';
  # };
}
