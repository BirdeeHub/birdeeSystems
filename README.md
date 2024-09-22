Just me learning how to use nix

I wouldn't suggest installing any of the final configurations on your own machine but most stuff is importable separately

---

If you check out nothing else from this repo, this link is the thing to click.

It is a comprehensive format for importing your regular nvim configuration directly into nix.

While still allowing you do have as many configs in 1 file, flake, or module as you want for all the cool direnv stuff.

- editor: [nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim)

---

monitor management:

  So I made this module for that at [./common/modules/i3MonMemory](./common/modules/i3MonMemory)

  Its an expression that returns a module, true for home manager false for system.

  System module has only an enable option.
  It creates a udev rule that echoes $RANDOM to a temp file on monitor hotplug.

  It is necessary for the user service to work.

  Home module specifies service using inotify to trigger when that temp file is written to and then run your xrandr scripts, and handle putting your i3 workspaces back from whence they came when you plug the monitor back in.

  If you had this repo as a flake input, you could access those via importing

    inputs.birdeeSystems.homeModules.i3MonMemory
    inputs.birdeeSystems.nixosModules.i3MonMemory

  In fact, all items [specified in this file](./common/modules/default.nix) can be imported in this way in other flakes.

  There are others too!
  Use `nix repl` followed by `:lf .` then type `outputs.` and hit `<tab>` to explore all the possible outputs.

---

common items are imported via [./common/default.nix](./common/default.nix) into the main [flake.nix](./flake.nix)

They are then sent to the [home-manager config](./homes/birdee.nix) and the chosen [system](./systems/PCs/aSUS/default.nix) [config](./systems/PCs/dustbook/default.nix) which both import the common system module [./systems/PCs/PCs.nix](./systems/PCs/PCs.nix)

---

- [display manager:](./common/modules/lightdm/default.nix) lightdm which loads ~/.xsession
- [window manager:](./common/modules/i3/default.nix) i3 loaded via home manager from .xsession
- desktop manager: none but I have like half of xfce including the power manager
- [text editor:](./common/birdeevim) neovim-nightly via my personal configuration of nvim via nixCats-nvim.
  - You can run it with `nix shell github:BirdeeHub/birdeeSystems#noAInvim` and then typing `vi`, `vim`, or `noAInvim`, keep in mind its going to download a lot of lsps and plugins.
  - You should use the noAI one because you dont have my key and also it wont download bitwarden cli + ai plugins for you.
  - completion keys are `<M-h>` = `<esc>` `<M-j>` = `next` `<M-k>` = `previous` `<M-l>` = `accept`
  - Also, I can't claim every language setup works perfectly or anything. This is not a distribution its mine.
- [browser:](./common/modules/firefox) firefox
- [file manager:](./common/modules/ranger/default.nix) ranger, but thunar when launched from firefox because im already using the mouse when it pops up from firefox
- [terminal:](./common/modules/alacritty/default.nix) alacritty
- [shell:](./common/modules/shell/home/zsh.nix) zsh with vi mode plugin, themer is oh-my-posh, the theme is a mashup of emodipt-extend and atomic
- [tmux:](./common/overlays/tmux) with some keybinds and onedark theme

---

asus rog fx504gd and Mac 9,1

only x86_64-linux

the asus is aSUS or nestOS and the mac is dustbook

If these happen to be your machines, then the configurations will probably work.

Otherwise, just cherry pick stuff or import modules. Its my computer get your own XD

Just dont install the nixos-only configs on a fresh install, because unless you know how to use nixos-enter
with home-manager to install a home-manager config without booting, you wont have a user environment to boot into.
Pick the combined options or home manager only

[Build Scripts](./scripts)

---

to do: change firefox config to use autoconf instead of copying prefs.js raw so that I dont have to reaccept terms and conditions every time I provision firefox from scratch.
