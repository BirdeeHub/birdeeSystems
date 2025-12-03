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
      (let [ (opts name) ... ]
      (fn debugger [...] (let [ args [...] ]
        (for [i 1 (select "#" ...)]
          (print (.. i ":\n" ((require :inspect) (. args i))))
        )
      ))
      ;; (debugger name opts (require :nix-info))
      nil)
    '';
  };
}
