{ inputs, birdeeutils, ... }:
{ config, pkgs, lib, wlib, ... }: let
  mkPluginCfg = cfg: cfg // {
    after = [ "MAIN_INIT" ] ++ cfg.after or [];
    data = "(local (opts name) ...)\n" + cfg.data or "";
    before = [ "AFTER_PLUGINS" ] ++ cfg.before or [];
  };
in {
  imports = [ wlib.wrapperModules.xplr ];
  # <c-k>*l = λ
  defaultConfigLang = "fnl";
  luaEnv = lp: [ lp.inspect ];
  luaInfo = {
  };
  luaInit.helpers = {
    before = [ "MAIN_INIT" ];
    data = /* fennel */ ''
      (set _G.nix-info (require "nix-info"))
      (set _G.nix-info.debug-print (fn [...] (let [ args [...] ]
        (for [i 1 (select "#" ...)]
          (print (.. i ":\n" ((require :inspect) (. args i))))
        )
      )))
      (set _G.nix-info.call-setup (λ [mod opts]
        ((. (require mod) :setup) opts)
      ))
    '';
  };
  luaInit.luaHacks = {
    before = [ "MAIN_INIT" ];
    after = [ "helpers" ];
    opts = {};
    type = "lua";
    data = /* lua */ ''
    '';
  };
  luaInit.MAIN_INIT = {
    opts = {};
    data = /* fennel */ ''
      (local (opts name) ...)
      (set xplr.config.modes.builtin.default.key_bindings.on_key.S {
        :help "serve $PWD"
        :messages [
          {
            :BashExec0 ${builtins.toJSON ''
              ${pkgs.python3}/bin/python3 -m http.server 1337
            ''}
          }
        ]
      })
      (set xplr.config.modes.builtin.go_to.key_bindings.on_key.h {
        :help "history"
        :messages [
          "PopMode"
          {
            :BashExec0 ${builtins.toJSON ''
              PTH=$(cat "''${XPLR_PIPE_HISTORY_OUT:?}" | sort -z -u | ${pkgs.fzf}/bin/fzf --read0)
              if [ "$PTH" ]; then
                "$XPLR" -m 'ChangeDirectory: %q' "$PTH"
              fi
            ''}
          }
        ]
      })
      (set xplr.config.modes.builtin.default.key_bindings.on_key.m {
        :help "bookmark"
        :messages [
          {
            :BashExecSilently0 ${builtins.toJSON ''
              PTH="''${XPLR_FOCUS_PATH:?}"
              PTH_ESC=$(printf %q "$PTH")
              if echo "''${PTH:?}" >> "''${XPLR_SESSION_PATH:?}/bookmarks"; then
                "$XPLR" -m 'LogSuccess: %q' "$PTH_ESC added to bookmarks"
              else
                "$XPLR" -m 'LogError: %q' "Failed to bookmark $PTH_ESC"
              fi
            ''}
          }
        ]
      })
      (tset xplr.config.modes.builtin.default.key_bindings.on_key "`" {
        :help "go to bookmark"
        :messages [
          {
            :BashExec0 ${builtins.toJSON ''
              PTH=$(cat "''${XPLR_SESSION_PATH:?}/bookmarks" | ${pkgs.fzf}/bin/fzf --no-sort)
              PTH_ESC=$(printf %q "$PTH")
              if [ "$PTH" ]; then
                "$XPLR" -m 'FocusPath: %q' "$PTH"
              fi
            ''}
          }
        ]
      })
      ;; (_G.nix-info.debug-print name opts (require :nix-info))
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
  luaInit.fzf = mkPluginCfg {
    plugin = inputs.fzf-xplr;
    opts = {
      mode = "default";
      key = "ctrl-f";
      bin = "${pkgs.fzf}/bin/fzf";
      args = "--preview '${pkgs.pistol}/bin/pistol {}'";
      recursive = false;  # If true, search all files under $PWD
      enter_dir = false;  # Enter if the result is directory
    };
    data = /* fennel */ ''
      (_G.nix-info.call-setup :fzf opts)
      nil
    '';
  };
  luaInit.tree-view = mkPluginCfg {
    plugin = inputs.tree-view-xplr;
    opts = {};
    data = /* fennel */ ''
      (_G.nix-info.call-setup :tree-view opts)
      nil
    '';
  };
  luaInit.dragon = mkPluginCfg {
    plugin = inputs.dragon-xplr;
    opts = {
      mode = "selection_ops";
      key = "D";
      drag_args = "";
      drop_args = "";
      keep_selection = false;
      bin = "${pkgs.dragon-drop}/bin/dragon";
    };
    data = /* fennel */ ''
      (_G.nix-info.call-setup :dragon opts)
      nil
    '';
  };
  luaInit.command-mode = mkPluginCfg {
    disabled = true;
    plugin = inputs.command-mode-xplr;
    opts = {};
    data = /* fennel */ ''
      (_G.nix-info.call-setup :command-mode opts)
      nil
    '';
  };
  luaInit.term = mkPluginCfg {
    plugin = inputs.term-xplr;
    opts = {};
    data = /* fennel */ ''
      (local term (require :term))
      (term.setup [ (term.profile_tmux_vsplit) (term.profile_tmux_hsplit) ])
      nil
    '';
  };
}
