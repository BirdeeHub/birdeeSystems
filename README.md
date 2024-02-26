Just me learning how to use nix. I actually started making nixCats before using nixOS.

TODO:

nixos-anywhere or other provisioning solutions that I may find out about

figure out secret management

set up secure rdp config for desktop from remote machines

---

asus rog fx504gd and Mac 9,1

good nvim setup, but I want to make a notes profile for it since I have this whole "as many different nvim configs as you want" thing with [nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim)

so also, TODO: notes specific nvim setup

---

- display manager: lightdm which loads .xsession
- window manager: i3 loaded via home manager from .xsession
- text editor: neovim-nightly via [nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim)
- desktop manager: none but I have like half of xfce including the power manager
- browser: firefox
- file manager: ranger, but thunar when launched from firefox because im already using the mouse when it pops up from firefox
- terminal alacritty
- zsh
- shell themer is oh-my-posh, the theme is a mashup of emodipt-extend and atomic
- tmux with some keybinds and onedark theme

---
If you check out nothing else from this repo, this link is the thing to click.

It is a comprehensive format for importing your regular nvim configuration directly into nix.

While still allowing you do have as many configs in 1 file, flake, or module as you want for all the cool direnv stuff.

- editor: [nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim)

---

- monitor management:
    So I made this module for that at [./common/i3MonMemory](./common/i3MonMemory)

    Its an expression that returns a module, true for home manager false for system.

    System module has only an enable option.
    It creates a udev rule that echoes $RANDOM to a temp file on monitor hotplug

    Home module specifies service using inotify to run your xrandr scripts, and handles putting your i3 workspaces from whence they came when you plug the monitor back in.



---

installer only works for x86_64-linux
