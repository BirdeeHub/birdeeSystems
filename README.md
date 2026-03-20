I configure everything I have gotten around to converting so far via:

[nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules)

[website introduction and documentation](https://birdeehub.github.io/nix-wrapper-modules/)

Currently Im doing that in this directory although that may change and I might forget to update this.

[./common/wrappers](./common/wrappers)

All packages wrapped in this manner may be reconfigured via calling `.wrap` on them, which takes a module as an argument. `.override` and `.overrideAttrs` will pass through to the actual package.

---

monitor management:

  So I made this module for that at [./common/modules/i3MonMemory](./common/modules/i3MonMemory)

  Its an expression that returns a module, true for home manager false for system.

  System module has only an enable option.
  It creates a udev rule that echoes $RANDOM to a temp file on monitor hotplug.

  It is necessary for the user service to work.

  Home module specifies service using inotify to trigger when that temp file is written to and then run your xrandr scripts, and handle putting your i3 workspaces back from whence they came when you plug the monitor back in.

---

Dendritic common directory heavily utilizing flake parts.

The common directory creates the stuff, and the configs consume it.

The configs are in [./homes](./systems) and [./systems](./systems) and they are organized by base config, with several entry points which import it to be imported from [./default.nix](./default.nix)

My configs are output under `legacyPackages.${system}.{nixosConfigurations,homeConfigurations}` and there is also a `legacyPackages.${system}.diskoConfigurations` which contains wrapped disko packages with the disk configs of those configurations preloaded.

The mapping of that too is also done via flake-parts

The modules that do the mappings are here:

[./common/flakeModules](./common/flakeModules/)

And the recursive import function is here

[./util/import.nix](./util/import.nix)

---

- [display manager:](./common/modules/lightdm/module.nix) lightdm which loads ~/.xsession
- [window manager:](./common/modules/i3/module.nix) i3 loaded via home manager from .xsession
- desktop manager: none but I have like half of xfce including the power manager
- [text editor:](https://github.com/BirdeeHub/birdeevim) neovim-nightly via my personal configuration of nvim via nix-wrapper-modules.
- [browser:](./common/modules/firefox) firefox
- [file manager:](./common/wrappers/xplr/module.nix) xplr, but dolphin when launched from firefox because im already using the mouse when it pops up from firefox
- [terminal:](./common/wrappers/wezterm/module.nix) wezterm
- [shell:](./common/wrappers/zsh) zsh with vi mode plugin, themer is [starship](./common/wrappers/starship/module.nix)
- [tmux:](./common/wrappers/tmux/module.nix) with some keybinds and onedark theme

---

Just cherry pick stuff or import modules if you want to copy something. Its my computer get your own XD

Dont install the nixos-only configs on a fresh install, because unless you know how to use nixos-enter
with home-manager to install a home-manager config without booting, you wont have a user environment to boot into.

If you use disko to reformat your drives and lose all your data, I am not responsible.

---

to do: change firefox config to use autoconf instead of copying prefs.js raw so that I dont have to reaccept terms and conditions every time I provision firefox from scratch.
