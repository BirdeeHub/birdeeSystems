I configure everything I have gotten around to converting so far via my biggest nix project so far:

[nix-wrapper-modules](https://github.com/nix-community/nix-wrapper-modules)

[website introduction and documentation](https://nix-community.github.io/nix-wrapper-modules/)

All packages wrapped in this manner may be reconfigured via calling `.wrap` on them, which takes a module as an argument. `.override` and `.overrideAttrs` will pass through to the actual package.

---

Dendritic common directory heavily utilizing flake parts.

The recursive import function is here at [util/import.nix](./util/import.nix), the util directory is basically just for that function and some random things I don't use.

There are 2 recursively imported directories:

[flake/ modules directory](./flake) has flake-parts modules, overlays, and other things which control the rest of the flake or really just get exported

[features/ modules directory has nixos, home-manager, wrappers, packages, etc](./features/)

The configs are in [homes](./homes) and [systems](./systems) and they are organized by base config, with several entry points which import it to be imported from [./default.nix](./default.nix)

[default.nix](./default.nix) imports stuff and sets up the system and home configuration outputs using [a custom flake parts module](./flake/flakeModules/configsPerSystem.nix) to set up the outputs.

My configs are output under `legacyPackages.${system}.{nixosConfigurations,homeConfigurations}` and there is also a `legacyPackages.${system}.diskoConfigurations` which contains wrapped disko packages with the disk configs of those configurations preloaded.

[flake.nix](./flake.nix) is just inputs.

---

- [display manager:](./features/lightdm/module.nix) lightdm which loads ~/.xsession
- [window manager:](./features/i3/module.nix) i3 loaded via home manager from .xsession
- [bars and notifications:](./features/quickshell) made via quickshell
- [text editor:](https://github.com/BirdeeHub/birdeevim) neovim-nightly via my personal configuration of nvim via nix-wrapper-modules.
- [browser:](./features/firefox) firefox
- [file manager:](./features/xplr/module.nix) xplr, but dolphin when launched from firefox because im already using the mouse when it pops up from firefox
- [terminal:](./features/wezterm/module.nix) wezterm
- [shell:](./features/zsh) zsh with vi mode plugin, themer is [starship](./features/starship/module.nix)
- [tmux:](./features/tmux/module.nix) with some keybinds and onedark theme

---

Cherry-pick stuff or import modules if you want to copy something. It's my computer get your own 🤣

Don't install the nixos-only configs on a fresh install, because unless you know how to use nixos-enter
with home-manager to install a home-manager config without booting, you wont have a user environment to boot into.

If you use disko to reformat your drives and lose all your data, I am not responsible.

If you grab something from my config, I do not guarantee that it will work.

Disclaimers aside, maybe you enjoy something in my organic slop pile.

Ever wanted to write derivations with a DAG instead of `____Phase` and write your build commands for your derivation in LUA instead of bash?

[No? Here it is anyway.](./features/lua/mkLuaDrv/)

Oh, you thought I was joking, but no I didn't cheat, it uses `builtins.derivation,` it has its own lua stdenv with no bash used to build it, and it supports `.overrideAttrs`. Don't use it probably. No I won't write documentation for it any time soon.

---
