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

common items are imported via [./common/default.nix](./common/default.nix) into the main [flake.nix](./flake.nix)

They are then sent to the [home-manager config](./homes/birdee.nix) and the chosen [system](./systems/PCs/aSUS/default.nix) [config](./systems/PCs/dustbook/default.nix) which both import the common system module [./systems/PCs/PCs.nix](./systems/PCs/PCs.nix)

---

- [display manager:](./common/modules/lightdm/default.nix) lightdm which loads ~/.xsession
- [window manager:](./common/modules/i3/default.nix) i3 loaded via home manager from .xsession
- desktop manager: none but I have like half of xfce including the power manager
- [text editor:](https://github.com/BirdeeHub/birdeevim) neovim-nightly via my personal configuration of nvim via nixCats-nvim.
  - You can run it with `nix shell github:BirdeeHub/birdeeSystems#noAInvim` and then typing `vi`, `vim`, or `noAInvim`, keep in mind its going to download a lot of lsps and plugins.
  - You should use the noAI one because you dont have my key and also it wont download bitwarden cli + ai plugins for you.
  - completion keys are `<M-h>` = `<esc>` `<M-j>` = `next` `<M-k>` = `previous` `<M-l>` = `accept`
  - Also, I can't claim every language setup works perfectly or anything. This is not a distribution its mine.
- [browser:](./common/modules/firefox) firefox
- [file manager:](./common/wrappers/ranger/default.nix) ranger, but dolphin when launched from firefox because im already using the mouse when it pops up from firefox
- [terminal:](./common/wrappers/wezterm/default.nix) wezterm
- [shell:](./common/modules/shell/home/zsh.nix) zsh with vi mode plugin, themer is oh-my-posh, the theme is a mashup of emodipt-extend and atomic
- [tmux:](./common/wrappers/tmux/default.nix) with some keybinds and onedark theme

---

only x86_64-linux

Just cherry pick stuff or import modules if you want to copy something. Its my computer get your own XD

Dont install the nixos-only configs on a fresh install, because unless you know how to use nixos-enter
with home-manager to install a home-manager config without booting, you wont have a user environment to boot into.

[Build Scripts](./scripts)

---

to do: change firefox config to use autoconf instead of copying prefs.js raw so that I dont have to reaccept terms and conditions every time I provision firefox from scratch.
