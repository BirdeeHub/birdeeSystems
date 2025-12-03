{ inputs, birdeeutils, ... }:
{ config, pkgs, lib, wlib, ... }: let
  mkPluginCfg = cfg: cfg // {
    after = [ "MAIN_INIT" ] ++ cfg.after or [];
    data = "(local (opts name) ...)\n" + cfg.data or "";
    before = [ "AFTER_PLUGINS" ] ++ cfg.before or [];
  };
in {
  imports = [ wlib.wrapperModules.xplr ];
  defaultConfigLang = "fnl";
  plugins = {
    command-mode = inputs.command-mode-xplr;
    fzf = inputs.fzf-xplr;
  };
  luaEnv = lp: [ lp.inspect ];
  # <c-k>*l = λ
  luaInfo = { };
  luaInit.MAIN_INIT = {
    opts = {};
    data = /* fennel */ ''
      (local (opts name) ...)
      (set _G.nix-info (require "nix-info"))
      (set _G.nix-info.debug_print (fn [...] (let [ args [...] ]
        (for [i 1 (select "#" ...)]
          (print (.. i ":\n" ((require :inspect) (. args i))))
        )
      )))
      (set _G.nix-info.call_setup (λ [mod opts]
        ((. (require mod) :setup) opts)
      ))
      ;; (_G.nix-info.debug_print name opts (require :nix-info))
      nil
    '';
  };
  luaInit.fzf = mkPluginCfg {
    opts = {};
    data = /* fennel */ ''
      (_G.nix-info.call_setup :fzf opts)
      nil
    '';
  };
  luaInit.command-mode = mkPluginCfg {
    opts = {};
    data = /* fennel */ ''
      (_G.nix-info.call_setup :command-mode opts)
      nil
    '';
  };
  luaInit.AFTER_PLUGINS = {
    after = [ "MAIN_INIT" ];
    opts = {};
    data = /* fennel */ ''
      (local (opts name) ...)
      nil
    '';
  };
}
