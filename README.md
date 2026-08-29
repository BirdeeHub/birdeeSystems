I configure everything I have gotten around to converting so far via:

[nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules)

[website introduction and documentation](https://birdeehub.github.io/nix-wrapper-modules/)

All packages wrapped in this manner may be reconfigured via calling `.wrap` on them, which takes a module as an argument. `.override` and `.overrideAttrs` will pass through to the actual package.

---

Dendritic common directory heavily utilizing flake parts.

The common directory creates the stuff, and the configs consume it.

The configs are in [./homes](./homes) and [./systems](./systems) and they are organized by base config, with several entry points which import it to be imported from [./default.nix](./default.nix)

My configs are output under `legacyPackages.${system}.{nixosConfigurations,homeConfigurations}` and there is also a `legacyPackages.${system}.diskoConfigurations` which contains wrapped disko packages with the disk configs of those configurations preloaded.

The mapping of that too is also done via flake-parts

The modules that do the mappings are here:

[./common/flakeModules](./common/flakeModules/)

And the recursive import function is here

[./util/import.nix](./util/import.nix)

---

- [display manager:](./common/features/lightdm/module.nix) lightdm which loads ~/.xsession
- [window manager:](./common/features/i3/module.nix) i3 loaded via home manager from .xsession
- [bars and notifications:](./common/features/quickshell/module.nix)
- [text editor:](https://github.com/BirdeeHub/birdeevim) neovim-nightly via my personal configuration of nvim via nix-wrapper-modules.
- [browser:](./common/features/firefox) firefox
- [file manager:](./common/features/xplr/module.nix) xplr, but dolphin when launched from firefox because im already using the mouse when it pops up from firefox
- [terminal:](./common/features/wezterm/module.nix) wezterm
- [shell:](./common/features/zsh) zsh with vi mode plugin, themer is [starship](./common/features/starship/module.nix)
- [tmux:](./common/features/tmux/module.nix) with some keybinds and onedark theme

---

Cherry-pick stuff or import modules if you want to copy something. Its my computer get your own XD

Dont install the nixos-only configs on a fresh install, because unless you know how to use nixos-enter
with home-manager to install a home-manager config without booting, you wont have a user environment to boot into.

If you use disko to reformat your drives and lose all your data, I am not responsible.

---
