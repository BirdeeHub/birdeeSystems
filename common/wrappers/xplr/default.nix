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
  # <c-k>*l = λ
  luaInit.MAIN_INIT = {
    opts = {};
    data = /* fennel */ ''
      (local (opts name) ...)
      (fn debugger [...] (each [k v (ipairs [...])]
        (print (.. k ":\n" ((require :inspect) v)))
      ))
      ;; (debugger name opts (require :nix-info))
      nil
    '';
  };
}
