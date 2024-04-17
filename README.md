Just me learning how to use nix. I actually started making nixCats before using nixOS.

---

asus rog fx504gd and Mac 9,1

only x86_64-linux

---

If you check out nothing else from this repo, this link is the thing to click.

It is a comprehensive format for importing your regular nvim configuration directly into nix.

While still allowing you do have as many configs in 1 file, flake, or module as you want for all the cool direnv stuff.

- editor: [nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim)

---

monitor management:

  So I made this module for that at [./common/i3MonMemory](./common/i3MonMemory)

  Its an expression that returns a module, true for home manager false for system.

  System module has only an enable option.
  It creates a udev rule that echoes $RANDOM to a temp file on monitor hotplug.

  It is necessary for the user service to work.

  Home module specifies service using inotify to trigger when that temp file is written to and then run your xrandr scripts, and handle putting your i3 workspaces back from whence they came when you plug the monitor back in.

  If you had this repo as a flake input, you could access those via importing

    inputs.birdeeSystems.home-modules.i3MonMemory
    inputs.birdeeSystems.system-modules.i3MonMemory

  In fact, all items [specified in this file](./common/default.nix) can be imported in this way in other flakes.

---

common modules are imported via [./common/default.nix](./common/default.nix) into the main [flake.nix](./flake.nix)

They are then sent to the [home-manager config](./homes/birdee.nix) and the chosen [system](./systems/PCs/aSUS/default.nix) [config](./systems/PCs/dustbook/default.nix) which both import the common system module [./systems/PCs/PCs.nix](./systems/PCs/PCs.nix)

---

So I was going to try to do what it says after these links, but then on first install, no way to log in until I install via home manager, and no way to install via home manager without logging in...
- [display manager:](./common/lightdm/default.nix) lightdm which loads .xsession
- [window manager:](./common/i3/default.nix) i3 loaded via home manager from .xsession

So instead Im just doing i3 as a system module for now and having default session be none+i3
rather than trying to handle EVERYTHING about it from home manager

---

- desktop manager: none but I have like half of xfce including the power manager
- [text editor:](./common/birdeevim) neovim-nightly via my personal configuration of nvim via nixCats-nvim
- [browser:](./common/firefox) firefox
- [file manager:](./common/ranger/default.nix) ranger, but thunar when launched from firefox because im already using the mouse when it pops up from firefox
- [terminal:](./common/term/alacritty/default.nix) alacritty
- [shell:](./common/term/shell/home/zsh.nix) zsh with vi mode plugin, themer is oh-my-posh, the theme is a mashup of emodipt-extend and atomic
- [tmux:](./common/term/tmux/default.nix) with some keybinds and onedark theme

---

to do: change firefox config to use autoconf instead of copying prefs.js raw so that I dont have to reaccept terms and conditions every time I provision firefox from scratch.
